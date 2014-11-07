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

@protocol LocationDelegate <NSObject>
- (void) updateNearRestaurants;
@end

@interface RestaurantsAPI : NSObject

@property (nonatomic, retain) id <LocationDelegate> delegate;
@property (nonatomic, strong) NSString* locality;
@property (nonatomic, strong) CLLocation* location;

+ (RestaurantsAPI*)sharedInstance;
- (BOOL)isCityInCatalogue:(NSString*)city;
- (NSArray*)getFavoriteRestaurants;
- (void)removeFavoriteRestaurant:(NSInteger)index;
- (void)addFavoriteRestaurant:(PFObject*)restaurantObj;
- (void)updateLocation:(CLLocation*)newLocation;

@end
