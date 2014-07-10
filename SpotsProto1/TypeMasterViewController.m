//
//  TypeMasterViewController.m
//  On Tap
//
//  Created by Jose Carlos Rodriguez on 03/07/14.
//  Copyright (c) 2014 On Tap. All rights reserved.
//

#import "TypeMasterViewController.h"
#import "Restaurant.h"
#import "RestaurantsAPI.h"
#import "RestaurantDetailViewController.h"
#import "Mixpanel.h"

@interface TypeMasterViewController ()
{
}
@end

@implementation TypeMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIImage *iconType = [UIImage imageNamed:@"type.png"];
    UIImage *selectedIconType = [UIImage imageNamed:@"type_selected.png"];
    
    [self.navigationController.tabBarItem setImage:iconType];
    [self.navigationController.tabBarItem setSelectedImage:selectedIconType];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    Mixpanel* mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Lista Por Tipo"];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[RestaurantsAPI sharedInstance] getRestaurantsByType] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString* sectionKey = [[[RestaurantsAPI sharedInstance] getTypeKeys] objectAtIndex:section];
    NSArray* restaurantsBySection = [[[RestaurantsAPI sharedInstance] getRestaurantsByType] objectForKey:sectionKey];
    return [restaurantsBySection count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[RestaurantsAPI sharedInstance] getTypeKeys] objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString* sectionKey = [[[RestaurantsAPI sharedInstance] getTypeKeys] objectAtIndex:indexPath.section];
    NSArray* restaurantsBySection = [[[RestaurantsAPI sharedInstance] getRestaurantsByType] objectForKey:sectionKey];
    Restaurant* restaurant = [restaurantsBySection objectAtIndex:indexPath.row];
    
    cell.textLabel.text = restaurant.nombre;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray* sectionTitles = [[NSMutableArray alloc] init];
    for (NSString* item in [[RestaurantsAPI sharedInstance] getTypeKeys])
    {
        if ([item isEqualToString:@"Barbeque"])
            [sectionTitles addObject:@"Bbq"];
        else
            [sectionTitles addObject:[item substringToIndex:3]];
    }
    return sectionTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        NSString* sectionKey = [[[RestaurantsAPI sharedInstance] getTypeKeys] objectAtIndex:indexPath.section];
        NSArray* restaurantsBySection = [[[RestaurantsAPI sharedInstance] getRestaurantsByType] objectForKey:sectionKey];
        
        Restaurant* restaurant =[restaurantsBySection objectAtIndex:indexPath.row];
        [[segue destinationViewController] setDetailItem:restaurant];
    }
}

@end
