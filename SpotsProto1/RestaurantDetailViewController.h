//
//  RestaurantDetailViewController.h
//  On Tap
//
//  Created by Jose Carlos Rodriguez on 03/07/14.
//  Copyright (c) 2014 On Tap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Restaurant.h"
#import "iCarousel.h"

@interface RestaurantDetailViewController : UIViewController <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) IBOutlet iCarousel *carousel;
@property (strong, nonatomic) PFObject* restaurantObj;
@property (strong, nonatomic) NSString* parentView;

@end
