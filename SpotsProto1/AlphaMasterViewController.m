//
//  MasterViewController.m
//  On Tap
//
//  Created by Jose Carlos Rodriguez on 03/07/14.
//  Copyright (c) 2014 On Tap. All rights reserved.
//

#import "AlphaMasterViewController.h"
#import "Restaurant.h"
#import "RestaurantsAPI.h"
#import "RestaurantDetailViewController.h"
#import "Mixpanel.h"
#import "TSMessage.h"

@interface AlphaMasterViewController ()
{
    NSMutableArray* filteredRestaurants;
}
@end

@implementation AlphaMasterViewController

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
 
    CGRect bounds = self.tableView.bounds;
    bounds.origin.y = bounds.origin.y + self.searchBar.bounds.size.height;
    self.tableView.bounds = bounds;
    
    filteredRestaurants = [[NSMutableArray alloc] init];
    
    Mixpanel* mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Lista Por Nombre"];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return 1;
    }
    else
    {
        return [[[RestaurantsAPI sharedInstance] getRestaurantsAlphabetically] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [filteredRestaurants count];
    }
    else
    {
        NSString* sectionKey = [[[RestaurantsAPI sharedInstance] getAlphaKeys] objectAtIndex:section];
        NSArray* restaurantsBySection = [[[RestaurantsAPI sharedInstance] getRestaurantsAlphabetically] objectForKey:sectionKey];
        return [restaurantsBySection count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return nil;
    }
    else
    {
        return [[[RestaurantsAPI sharedInstance] getAlphaKeys] objectAtIndex:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    Restaurant* restaurant;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        restaurant = [filteredRestaurants objectAtIndex:indexPath.row];
    }
    else
    {
        NSString* sectionKey = [[[RestaurantsAPI sharedInstance] getAlphaKeys] objectAtIndex:indexPath.section];
        NSArray* restaurantsBySection = [[[RestaurantsAPI sharedInstance] getRestaurantsAlphabetically] objectForKey:sectionKey];
        restaurant = [restaurantsBySection objectAtIndex:indexPath.row];
    }

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
    return [[RestaurantsAPI sharedInstance] getAlphaKeys];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        Restaurant* restaurant;
        if (self.searchDisplayController.active)
        {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            restaurant = [filteredRestaurants objectAtIndex:indexPath.row];
        }
        else
        {
            NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
            NSString* sectionKey = [[[RestaurantsAPI sharedInstance] getAlphaKeys] objectAtIndex:indexPath.section];
            NSArray* restaurantsBySection = [[[RestaurantsAPI sharedInstance] getRestaurantsAlphabetically] objectForKey:sectionKey];
            restaurant = [restaurantsBySection objectAtIndex:indexPath.row];
        }
        
        [[segue destinationViewController] setDetailItem:restaurant];
    }
}

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [filteredRestaurants removeAllObjects];
    NSArray* allRestaurants = [[RestaurantsAPI sharedInstance] getAllRestaurants];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF.nombre contains[c] %@", searchText];
    filteredRestaurants = [NSMutableArray arrayWithArray:[allRestaurants filteredArrayUsingPredicate:predicate]];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

@end
