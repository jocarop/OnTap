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

@synthesize delegate;
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

/*- (void)updateLocation:(CLLocation*)newLocation
{
    self.location = newLocation;
    
    CLLocationDegrees latDelta = newLocation.coordinate.latitude - location.coordinate.latitude;
    CLLocationDegrees lonDelta = newLocation.coordinate.longitude - location.coordinate.longitude;
    
    if (fabsf(latDelta) >= 0.225 || fabsf(lonDelta) >= 0.225)
    {
        CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
        {
             if ([placemarks count] > 0 && error == nil)
             {
                 CLPlacemark* placemark = [placemarks objectAtIndex:0];
                 self.locality = placemark.locality;
             }
        }];
    }
    
    [self.delegate updateNearRestaurants];
}*/

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
