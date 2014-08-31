//
//  TypeViewController.m
//  OnTap
//
//  Created by Andrea Martinez de Castro on 30/08/14.
//  Copyright (c) 2014 Appvertising. All rights reserved.
//

#import "TypeViewController.h"
#import "RestaurantsAPI.h"
#import "Util.h"
#import "Mixpanel.h"

@interface TypeViewController ()

@end

@implementation TypeViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.parseClassName = @"RestaurantType";
    self.pullToRefreshEnabled = YES;
    self.paginationEnabled = YES;
    self.objectsPerPage = 25;
    
    UIImage *iconType = [UIImage imageNamed:@"type.png"];
    UIImage *selectedIconType = [UIImage imageNamed:@"type_selected.png"];
    
    [self.navigationController.tabBarItem setImage:iconType];
    [self.navigationController.tabBarItem setSelectedImage:selectedIconType];
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
    [mixpanel track:@"Lista Por Tipo"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    static NSString *cellIdentifier = @"Cell";
    
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.textLabel.text = object[@"type"];
    
    PFFile *thumbnail = object[@"image"];
    cell.imageView.file = thumbnail;

    return cell;
}

@end
