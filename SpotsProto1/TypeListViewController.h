//
//  TypeListViewController.h
//  OnTap
//
//  Created by Jose Carlos Rodriguez on 31/10/14.
//  Copyright (c) 2014 Appvertising. All rights reserved.
//

#import <Parse/Parse.h>

@interface TypeListViewController : PFQueryTableViewController

@property (strong, nonatomic) PFObject* restaurantType;

@end
