//
//  FavoritesViewController.m
//  OnTap
//
//  Created by Andrea Martinez de Castro on 05/11/14.
//  Copyright (c) 2014 Appvertising. All rights reserved.
//

#import "FavoritesViewController.h"
#import "Util.h"
#import "RestaurantsAPI.h"
#import "RestaurantDetailViewController.h"

@interface FavoritesViewController ()

@end

@implementation FavoritesViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.parseClassName = @"Restaurant";
        self.textKey = @"nombre";
        self.imageKey = @"imagen";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    
    UIImage *iconFav = [UIImage imageNamed:@"favorite.png"];
    UIImage *selectedIconFav = [UIImage imageNamed:@"favorite_selected.png"];
    
    [self.navigationController.tabBarItem setImage:iconFav];
    [self.navigationController.tabBarItem setSelectedImage:selectedIconFav];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIColor* barColor = [UIColor colorWithRed:255.0/255.0 green:144.0/255.0 blue:66.0/255.0 alpha:0.9f];
    
    if ([Util isVersion7])
    {
        [self.navigationController.navigationBar setBarTintColor:barColor];
        [self.navigationController.navigationBar setTranslucent:YES];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    }
    else
    {
        [self.navigationController.navigationBar setTintColor:barColor];
        [self.navigationController.navigationBar setTranslucent:NO];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (PFQuery *)queryForTable
{
    RestaurantsAPI* api = [RestaurantsAPI sharedInstance];
    NSArray* favorites = [api getFavoriteRestaurants];
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    if (self.objects.count == 0)
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [query whereKey:@"objectId" containedIn:favorites];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *cellIdentifier = @"FavoriteCell";
    
    PFTableViewCell* cell = (PFTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.textLabel.text = object[@"nombre"];
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        RestaurantsAPI* api = [RestaurantsAPI sharedInstance];
        [api removeFavoriteRestaurant:indexPath.row];
        
        [self loadObjects];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        PFObject* object = [self.objects objectAtIndex:indexPath.row];
        
        [[segue destinationViewController] setRestaurantObj:object];
        [[segue destinationViewController] setParentView:@"Favoritos"];
    }
}

@end
