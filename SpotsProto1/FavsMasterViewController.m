//
//  FavsMasterViewController.m
//  On Tap
//
//  Created by Jose Carlos Rodriguez on 03/07/14.
//  Copyright (c) 2014 On Tap. All rights reserved.
//

#import "FavsMasterViewController.h"
#import "Restaurant.h"
#import "RestaurantDetailViewController.h"
#import "MBProgressHUD.h"
#import "Util.h"

@interface FavsMasterViewController ()
{
    NSMutableArray* favorites;
}
@end

@implementation FavsMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [super awakeFromNib];
    UIImage *iconFav = [UIImage imageNamed:@"favorite.png"];
    UIImage *selectedIconFav = [UIImage imageNamed:@"favorite_selected.png"];
    
    [self.navigationController.tabBarItem setImage:iconFav];
    [self.navigationController.tabBarItem setSelectedImage:selectedIconFav];
    
    RestaurantsAPI* api = [RestaurantsAPI sharedInstance];
    api.delegate = self;
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
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("loadFavorites", NULL);
    dispatch_async(downloadQueue, ^{
        
        // do our long running process here
        RestaurantsAPI* api = [RestaurantsAPI sharedInstance];
        favorites = [api getFavoriteRestaurants];
        
        // do any UI stuff on the main UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        
    });
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [favorites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Restaurant* restaurant = [favorites objectAtIndex:indexPath.row];
    cell.textLabel.text = restaurant.nombre;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        RestaurantsAPI* api = [RestaurantsAPI sharedInstance];
        [api removeFavoriteRestaurant:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        Restaurant* restaurant =[favorites objectAtIndex:indexPath.row];
        
        [[segue destinationViewController] setParentView:@"Favoritos"];
        [[segue destinationViewController] setDetailItem:restaurant];
    }
}

- (void)refreshFavoritesList
{
    [self.tableView reloadData];
}

@end
