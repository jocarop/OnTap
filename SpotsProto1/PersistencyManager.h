//
//  PersistencyManager.h
//  SpotsProto1
//
//  Created by Andrea Martinez de Castro on 16/06/14.
//  Copyright (c) 2014 Appvertising. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface PersistencyManager : NSObject

- (void)loadRestaurants;
- (NSMutableDictionary*)getRestaurantsGroupedAlphabetically;
- (NSArray*)getAlphaKeys;
- (NSMutableDictionary*)getRestaurantsGroupedByType;
- (NSArray*)getTypeKeys;
- (NSMutableArray*)getFavoriteRestaurants;
- (void)removeFavoriteRestaurant:(NSInteger)index;
- (void)addFavoriteRestaurant:(NSNumber*)spot_id;

@end
