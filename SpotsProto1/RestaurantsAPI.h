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
- (BOOL)isCityInCatalogue:(CLPlacemark*)placemark;
- (NSArray*)getFavoriteRestaurants;
- (void)removeFavoriteRestaurant:(NSInteger)index;
- (void)addFavoriteRestaurant:(PFObject*)restaurantObj;

@end
