//
//  RestaurantTypeCell.h
//  OnTap
//
//  Created by Andrea Martinez de Castro on 28/10/14.
//  Copyright (c) 2014 Appvertising. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface RestaurantTypeCell : PFTableViewCell

@property IBOutlet PFImageView* theImageView;
@property IBOutlet UILabel* theLabel;

@end
