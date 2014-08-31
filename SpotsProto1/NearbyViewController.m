//
//  NearbyViewController.m
//  OnTap
//
//  Created by Andrea Martinez de Castro on 30/08/14.
//  Copyright (c) 2014 Appvertising. All rights reserved.
//

#import "NearbyViewController.h"
#import "RestaurantsAPI.h"
#import "Mixpanel.h"
#import "Util.h"
#import "RestaurantDetailViewController.h"
#import "TSMessage.h"

@interface NearbyViewController ()

@end

@implementation NearbyViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIImage *iconName = [UIImage imageNamed:@"name.png"];
    UIImage *selectedIconName = [UIImage imageNamed:@"name_selected.png"];
    
    [self.navigationController.tabBarItem setImage:iconName];
    [self.navigationController.tabBarItem setSelectedImage:selectedIconName];
    
    [TSMessage setDefaultViewController:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:[RestaurantsAPI sharedInstance].placemark.locality];
    
    UIColor* barColor = [UIColor colorWithRed:255.0/255.0 green:144.0/255.0 blue:66.0/255.0 alpha:0.9f];
    UIColor* gray = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1];
    
    if ([Util isVersion7])
    {
        [self.navigationController.navigationBar setBarTintColor:barColor];
        [self.navigationController.navigationBar setTranslucent:YES];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        
        self.tableView.sectionIndexColor = gray;
    }
    else
    {
        [self.navigationController.navigationBar setTintColor:barColor];
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    Mixpanel* mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Cerca de Mi"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray* restaurants = [[RestaurantsAPI sharedInstance] getNearbyRestaurants];
    return [restaurants count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Restaurant* restaurant = [[[RestaurantsAPI sharedInstance] getNearbyRestaurants] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = restaurant.nombre;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        Restaurant* restaurant = [[[RestaurantsAPI sharedInstance] getNearbyRestaurants] objectAtIndex:indexPath.row];
        
        [[segue destinationViewController] setParentView:@"Cerca de Mi"];
        [[segue destinationViewController] setDetailItem:restaurant];
    }
}

@end
