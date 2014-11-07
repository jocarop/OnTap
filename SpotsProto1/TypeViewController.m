//
//  TypeViewController.m
//  OnTap
//
//  Created by Jose Carlos Rodriguez on 30/08/14.
//  Copyright (c) 2014 Appvertising. All rights reserved.
//

#import "TypeViewController.h"
#import "RestaurantsAPI.h"
#import "Util.h"
#import "Mixpanel.h"
#import "RestaurantTypeCell.h"
#import "TypeListViewController.h"

@interface TypeViewController ()

@end

@implementation TypeViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.parseClassName = @"RestaurantType";
        self.textKey = @"type";
        self.imageKey = @"image";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }

    UIImage *iconType = [UIImage imageNamed:@"type.png"];
    UIImage *selectedIconType = [UIImage imageNamed:@"type_selected.png"];
    
    [self.navigationController.tabBarItem setImage:iconType];
    [self.navigationController.tabBarItem setSelectedImage:selectedIconType];
    
    return self;
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
    [mixpanel track:@"Explora"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    if (self.objects.count == 0)
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [query orderByAscending:@"type"];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *cellIdentifier = @"TypeCell";
    
    RestaurantTypeCell* cell = (RestaurantTypeCell*)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (!cell)
        cell = [[RestaurantTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.theLabel.text = object[@"type"];
    PFFile *thumbnail = object[@"image"];
    
    cell.theImageView.image = [UIImage imageNamed:@"AppIcon58x58.png"];
    cell.theImageView.file = thumbnail;

    [cell.theImageView loadInBackground];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
    PFObject* selectedType = [self.objects objectAtIndex:indexPath.row];
    
    if ([[segue identifier] isEqualToString:@"showRestaurants"])
    {
        [[segue destinationViewController] setRestaurantType:selectedType];
    }
}

@end
