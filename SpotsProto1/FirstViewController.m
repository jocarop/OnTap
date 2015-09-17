//
//  FirstViewController.m
//  On Tap
//
//  Created by Jose Carlos Rodriguez on 03/07/14.
//  Copyright (c) 2014 On Tap. All rights reserved.
//

#import "FirstViewController.h"
#import "Util.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    if ([Util isVersion7])
    {
        UIColor* barColor = [UIColor colorWithRed:255.0/255.0 green:144.0/255.0 blue:66.0/255.0 alpha:1];
        [self.tabBar setTintColor:barColor];
    }
    else
    {
        UIColor* gray = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1];
        [self.tabBar setTintColor:gray];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
