//
//  Restaurants.h
//  On Tap
//
//  Created by Jose Carlos Rodriguez on 03/07/14.
//  Copyright (c) 2014 On Tap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Restaurant.h"

@protocol RestaurantsListDelegate <NSObject>
- (void) refreshFavoritesList;
@end

@interface RestaurantsAPI : NSObject

@property (nonatomic, retain) id <RestaurantsListDelegate> delegate;
@property (nonatomic, strong) CLPlacemark* placemark;

+ (RestaurantsAPI*)sharedInstance;
- (BOOL)loadRestaurants:(CLPlacemark*)placemark;
- (NSMutableArray*)getAllRestaurants;
- (NSMutableDictionary*)getRestaurantsAlphabetically;
- (NSArray*)getAlphaKeys;
- (NSMutableDictionary*)getRestaurantsByType;
- (NSArray*)getTypeKeys;
- (void)loadFavoriteRestaurants;
- (NSMutableArray*)getFavoriteRestaurants;
- (void)removeFavoriteRestaurant:(NSInteger)index;
- (void)addFavoriteRestaurant:(NSString*)objectId;
- (void)getRestaurantDetails;
- (void)getRestaurantDetails:(Restaurant*)restaurant;

@end
