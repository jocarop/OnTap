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
}

@end

@implementation RestaurantsAPI

@synthesize locality;
@synthesize location;

+ (RestaurantsAPI*)sharedInstance
{
    static RestaurantsAPI* _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[RestaurantsAPI alloc] init];
    });
    
    return _sharedInstance;
}

- (BOOL)isCityInCatalogue:(NSString*)city
{    
    if ([city isEqual:@"Cupertino"])
        city = @"Sunnyvale";
    
    PFQuery *query = [PFQuery queryWithClassName:@"Restaurant"];
    [query whereKey:@"ciudad" equalTo:city];
    NSInteger count = [query countObjects];
    
    if (count > 0)
        return YES;
    
    return NO;
}

- (void)addSucursales
{
    PFQuery *query = [PFQuery queryWithClassName:@"Restaurant"];
    [query whereKey:@"ciudad" containsString:@"Sunnyvale"];
    NSArray* objects = [query findObjects];
    
    for (PFObject* object in objects)
    {
        PFObject* sucursal = [PFObject objectWithClassName:@"Sucursal"];
        if (object[@"direccion"] != nil)
        {
            sucursal[@"direccion"] = object[@"direccion"];
        }
        if (object[@"geolocation"] != nil)
        {
            sucursal[@"geolocation"] = object[@"geolocation"];
        }
        if (object[@"telefono"] != nil)
        {
            sucursal[@"telefono"] = object[@"telefono"];
        }
        if (object[@"horario"] != nil)
        {
            sucursal[@"horario"] = object[@"horario"];
        }
        sucursal[@"restaurant"] = [PFObject objectWithoutDataWithClassName:@"Restaurant" objectId:object.objectId];
        
        [sucursal save];
        
        NSString* id = sucursal.objectId;
        NSArray* array = [NSArray arrayWithObjects:sucursal, nil];
        object[@"sucursales"] = array;
                
        [object save];
    }
    
    /*PFObject* object = [query getFirstObject];
    PFObject* s1 = [PFObject objectWithoutDataWithClassName:@"Sucursal" objectId:@"O0D7JrKX95"];
    PFObject* s2 = [PFObject objectWithoutDataWithClassName:@"Sucursal" objectId:@"WR8G0SErio"];
    
    NSArray* array = [NSArray arrayWithObjects:s1, nil];
    
    object[@"sucursales"] = array;
    [object save];*/
}

- (NSArray*)getFavoriteRestaurants
{
    NSArray* favoritesIdList = [[NSUserDefaults standardUserDefaults] objectForKey:@"OnTap_Favorites"];
    return favoritesIdList;
}

- (void)addFavoriteRestaurant:(PFObject*)restaurantObj
{
    NSMutableArray* favoritesIdList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"OnTap_Favorites"] mutableCopy];
    if (favoritesIdList == nil)
        favoritesIdList = [[NSMutableArray alloc] init];

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF = %@", restaurantObj.objectId];
    NSArray* results = [favoritesIdList filteredArrayUsingPredicate:predicate];
    
    if (results.count == 0)
    {
        [favoritesIdList addObject:restaurantObj.objectId];
        
        Mixpanel* mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Agrego a Favoritos" properties:@{
                                                           @"id": restaurantObj.objectId,
                                                           @"nombre": restaurantObj[@"nombre"]
                                                           }];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:favoritesIdList forKey:@"OnTap_Favorites"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeFavoriteRestaurant:(NSInteger)index
{
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

@end
