//
//  Restaurants.m
//  On Tap
//
//  Created by Jose Carlos Rodriguez on 03/07/14.
//  Copyright (c) 2014 On Tap. All rights reserved.
//

#import "RestaurantsAPI.h"
#import "Restaurant.h"
#import "Mixpanel.h"

@interface RestaurantsAPI ()
{
    NSMutableArray* restaurants;
    NSMutableArray* nearbyRestaurants;
    NSMutableDictionary* restaurantsAlphabetically;
    NSArray* alphaKeys;
    NSMutableDictionary* restaurantsByType;
    NSArray* typeKeys;
    NSMutableArray* favorites;
}

@end

@implementation RestaurantsAPI

@synthesize delegate;

+ (RestaurantsAPI*)sharedInstance
{
    static RestaurantsAPI* _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[RestaurantsAPI alloc] init];
    });
    
    return _sharedInstance;
}

- (BOOL)isCityInCatalogue:(CLPlacemark *)placemark
{
    NSString* ciudad = placemark.locality;

    if ([ciudad isEqual:@"Cupertino"])
        ciudad = @"Sunnyvale";
    
    PFQuery *query = [PFQuery queryWithClassName:@"Restaurant"];
    [query whereKey:@"ciudad" equalTo:ciudad];
    NSInteger count = [query countObjects];
    
    if (count > 0)
        return YES;
    
    return NO;
}

- (void)getRestaurantDetails
{
    PFQuery* query = [PFQuery queryWithClassName:@"Restaurant"];
    [query selectKeys:@[@"sucursales"]];
    [query whereKey:@"ciudad" equalTo:self.placemark.locality];
    [query whereKey:@"tieneSucursales" equalTo:@YES];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *sucursales, NSError *error) {
        if (!error && [sucursales count] > 0)
        {
            for (PFObject* object in sucursales)
            {
                NSString* id = object.objectId;
                Restaurant* restaurant = [self findRestaurantBySpotId:id];
                
                if ([restaurant.sucursales count] == 0)
                {
                    restaurant.sucursales = object[@"sucursales"];
                }
            }
        }
        
        
    }];
    
}

- (void)getRestaurantDetails:(Restaurant*)restaurant
{
    PFQuery *query = [PFQuery queryWithClassName:@"Restaurant"];
    [query selectKeys:@[@"sucursales"]];
    PFObject* object = [query getObjectWithId:restaurant.objectId];
    
    restaurant.sucursales = object[@"sucursales"];
}

- (void)getRestaurantImage:(Restaurant*)restaurant
{
    PFQuery* query = [PFQuery queryWithClassName:@"Restaurant"];
    [query selectKeys:@[@"imagen"]];
    
    PFObject* object = [query getObjectWithId:restaurant.objectId];
    PFFile *imageFile = object[@"imagen"];
    NSData* imageData = [imageFile getData];
    restaurant.imagen = [UIImage imageWithData:imageData];
}

- (void)loadFavoriteRestaurants
{
    NSMutableArray* favoritesIdList = [[NSUserDefaults standardUserDefaults] objectForKey:@"OnTap_Favorites"];
    if (favoritesIdList == nil)
        favoritesIdList = [[NSMutableArray alloc] init];
 
    favorites = [NSMutableArray array];
    
    for (int i=0; i<favoritesIdList.count; i++)
    {
        Restaurant* restaurant = [self findRestaurantBySpotId:favoritesIdList[i]];
        if (restaurant)
            [favorites addObject:restaurant];
    }
}

- (NSMutableArray*)getFavoriteRestaurants
{
    if (favorites.count == 0)
    {
        [self loadFavoriteRestaurants];
    }
    
    return favorites;
}

- (void)addFavoriteRestaurant:(NSString*)objectId
{
    NSMutableArray* favoritesIdList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"OnTap_Favorites"] mutableCopy];
    if (favoritesIdList == nil)
        favoritesIdList = [[NSMutableArray alloc] init];
    
    Restaurant* restaurant = [self findRestaurantBySpotId:objectId];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF = %@", objectId];
    NSArray* results = [favoritesIdList filteredArrayUsingPredicate:predicate];
    
    if (results.count == 0)
    {
        [favoritesIdList addObject:objectId];
        [favorites addObject:restaurant];
        
        Mixpanel* mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Agrego a Favoritos" properties:@{
                                                           @"id": restaurant.objectId,
                                                           @"nombre": restaurant.nombre
                                                           }];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:favoritesIdList forKey:@"OnTap_Favorites"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.delegate refreshFavoritesList];
}

- (void)removeFavoriteRestaurant:(NSInteger)index
{
    [favorites removeObjectAtIndex:index];
    
    NSMutableArray* favoritesIdList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"OnTap_Favorites"] mutableCopy];
    if (favoritesIdList == nil)
        return;
    
    if (index < favoritesIdList.count)
    {
        [favoritesIdList removeObjectAtIndex:index];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:favoritesIdList forKey:@"OnTap_Favorites"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (Restaurant*)findRestaurantBySpotId:(NSString*)objectId
{
    Restaurant* restaurant;
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"(objectId = %@)", objectId];
    
    NSArray* results = [restaurants filteredArrayUsingPredicate:pred];
    if (results.count > 0)
        restaurant = [results objectAtIndex:0];
    
    return restaurant;
}

@end
