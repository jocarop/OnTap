//
//  PersistencyManager.m
//  SpotsProto1
//
//  Created by Andrea Martinez de Castro on 16/06/14.
//  Copyright (c) 2014 Appvertising. All rights reserved.
//

#import "PersistencyManager.h"
#import "Restaurant.h"

@interface PersistencyManager ()
{
    NSMutableDictionary* restaurantsAlphabetically;
    NSArray* alphaKeys;
    NSMutableDictionary* restaurantsByType;
    NSArray* typeKeys;
    NSMutableArray* favorites;
}

@end

@implementation PersistencyManager

- (id)init
{
    self = [super init];
    
    if (self)
    {
        //[self loadRestaurants];
        [self loadFavorites];
    }
    
    return self;
}

- (void)loadRestaurants
{
    /*NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"restaurants" ofType:@"plist"];
    NSArray* list = [NSArray arrayWithContentsOfFile:plistPath];
    NSMutableArray* restaurants = [NSMutableArray array];
    
    for (NSDictionary* item in list)
    {
        Restaurant* rest = [[Restaurant alloc] initFromDictionary:item];
        [restaurants addObject:rest];
    }*/

    NSMutableArray* restaurants = [NSMutableArray array];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Restaurant"];
    [query whereKey:@"ciudad" equalTo:@"Hermosillo"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
            NSLog(@"%d restaurants cargados de la nube exitosamente.", objects.count);

            for (PFObject* object in objects)
            {
                Restaurant* rest = [[Restaurant alloc] initFromParseObject:object];
                [restaurants addObject:rest];
            }
            
            NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"nombre" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            [restaurants sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
            
            restaurantsAlphabetically = [NSMutableDictionary dictionary];
            restaurantsByType = [NSMutableDictionary dictionary];
            
            for (Restaurant* restaurant in restaurants)
            {
                NSString* letter = [restaurant.nombre substringToIndex:1];
                NSMutableArray* restaurantGroup = [restaurantsAlphabetically objectForKey:letter];
                if (restaurantGroup == nil)
                {
                    restaurantGroup = [NSMutableArray array];
                    [restaurantsAlphabetically setObject:restaurantGroup forKey:letter];
                }
                
                [restaurantGroup addObject:restaurant];
                
                restaurantGroup = [restaurantsByType objectForKey:restaurant.tipo];
                if (restaurantGroup == nil)
                {
                    restaurantGroup = [NSMutableArray array];
                    [restaurantsByType setObject:restaurantGroup forKey:restaurant.tipo];
                }
                
                [restaurantGroup addObject:restaurant];
            }
            
            NSArray *unsortedKeys = [restaurantsAlphabetically allKeys];
            alphaKeys = [unsortedKeys sortedArrayUsingSelector:@selector(compare:)];
            
            unsortedKeys = [restaurantsByType allKeys];
            typeKeys = [unsortedKeys sortedArrayUsingSelector:@selector(compare:)];

        }
        else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (NSMutableDictionary*)getRestaurantsGroupedAlphabetically
{
    return restaurantsAlphabetically;
}

- (NSArray*)getAlphaKeys
{
    return alphaKeys;
}

- (NSMutableDictionary*)getRestaurantsGroupedByType
{
    return restaurantsByType;
}

- (NSArray*)getTypeKeys
{
    return typeKeys;
}

- (void)loadFavorites
{
    NSString* appSupportDirectory = [self getApplicationSupportDirectory];
    NSString* filePath = [appSupportDirectory stringByAppendingPathComponent:@"favorites.plist"];

    NSArray* favoritesList = [NSArray arrayWithContentsOfFile:filePath];
    if (favoritesList == nil)
        return;
    
    favorites = [NSMutableArray array];
    
    for (int i=0; i<favoritesList.count; i++)
    {
        Restaurant* restaurant = [self findRestaurantBySpotId:favoritesList[i]];
        if (restaurant)
            [favorites addObject:restaurant];
    }
 }

- (NSMutableArray*)getFavoriteRestaurants
{
    return favorites;
}

- (void)addFavoriteRestaurant:(NSNumber*)spot_id
{
    Restaurant* restaurant = [self findRestaurantBySpotId:spot_id];
    [favorites addObject:restaurant];
    
    NSString* appSupportDirectory = [self getApplicationSupportDirectory];
    NSString* filePath = [appSupportDirectory stringByAppendingPathComponent:@"favorites.plist"];
    
    NSMutableArray* favoritesList = [NSMutableArray arrayWithContentsOfFile:filePath];
    if (favoritesList == nil)
        favoritesList = [[NSMutableArray alloc] init];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF = %@", spot_id];
    NSArray* results = [favoritesList filteredArrayUsingPredicate:predicate];

    if (results.count == 0)
    {
        [favoritesList addObject:spot_id];
        [favoritesList writeToFile:filePath atomically:YES];
    }
}

- (void)removeFavoriteRestaurant:(NSInteger)index
{
    [favorites removeObjectAtIndex:index];
    
    NSString* appSupportDirectory = [self getApplicationSupportDirectory];
    NSString* filePath = [appSupportDirectory stringByAppendingPathComponent:@"favorites.plist"];
    
    NSMutableArray* favoritesList = [NSMutableArray arrayWithContentsOfFile:filePath];
    if (favoritesList == nil)
        return;
    
    if (index < favoritesList.count)
    {
        [favoritesList removeObjectAtIndex:index];
        [favoritesList writeToFile:filePath atomically:YES];
    }
}

- (Restaurant*)findRestaurantBySpotId:(NSNumber*)spot_id
{
    Restaurant* restaurant;
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"(spot_id = %@)", spot_id];
    
    NSArray* allRestaurants = [restaurantsAlphabetically allValues];
    for (NSArray* items in allRestaurants)
    {
        NSArray* results = [items filteredArrayUsingPredicate:pred];
        if (results.count > 0)
        {
            restaurant = [results objectAtIndex:0];
        }
    }
    
    return restaurant;
}

- (NSString*)getApplicationSupportDirectory
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    if (paths == nil || paths.count == 0)
        return nil;
    
    NSString* appSupportDir = [paths objectAtIndex:0];
    return appSupportDir;
}

@end
