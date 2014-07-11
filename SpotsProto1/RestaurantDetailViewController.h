//
//  RestaurantDetailViewController.h
//  On Tap
//
//  Created by Jose Carlos Rodriguez on 03/07/14.
//  Copyright (c) 2014 On Tap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Restaurant.h"

@interface RestaurantDetailViewController : UITableViewController

@property (strong, nonatomic) Restaurant* detailItem;
@property (strong, nonatomic) NSString* parentView;

@end
