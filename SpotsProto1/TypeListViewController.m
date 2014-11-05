//
//  TypeListViewController.m
//  OnTap
//
//  Created by Jose Carlos Rodriguez on 31/10/14.
//  Copyright (c) 2014 Appvertising. All rights reserved.
//

#import "TypeListViewController.h"
#import "RestaurantsAPI.h"
#import "Restaurant.h"
#import "RestaurantDetailViewController.h"
#import "Util.h"

@interface TypeListViewController ()

@end

@implementation TypeListViewController
{
    UIView* headerView;
}

- (void)setDetailItem:(PFObject *)restaurantType
{
    if (_restaurantType != restaurantType)
    {
        _restaurantType = restaurantType;
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.parseClassName = @"Restaurant";
        self.textKey = @"nombre";
        self.imageKey = @"image";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([Util isVersion7])
    {
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (headerView == nil)
    {
        headerView = [[UIView alloc] init];
    
        CGFloat width = self.view.frame.size.width;
    
        PFImageView* imageView = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, width, 195)];
        PFFile* imageFile = _restaurantType[@"image"];
        imageView.file = imageFile;
    
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 4, width, 25)];
        titleLabel.text = _restaurantType[@"type"];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:22.0];
        titleLabel.opaque = YES;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.shadowColor = [UIColor blackColor];
        titleLabel.shadowOffset = CGSizeMake(1, 1);
  
        [headerView addSubview:imageView];
        [headerView addSubview:titleLabel];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 195.0f;
}

- (PFQuery *)queryForTable
{
    NSString* ciudad = [RestaurantsAPI sharedInstance].placemark.locality;
    if ([ciudad isEqual:@"Cupertino"])
        ciudad = @"Sunnyvale";
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    if (self.objects.count == 0)
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [query whereKey:@"type" equalTo:_restaurantType];
    [query whereKey:@"ciudad" equalTo:ciudad];
    [query orderByAscending:@"nombre"];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *cellIdentifier = @"RestaurantCell";
    
    PFTableViewCell* cell = (PFTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.textLabel.text = object[@"nombre"];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        PFObject* object = [self.objects objectAtIndex:indexPath.row];
        
        [[segue destinationViewController] setRestaurantObj:object];
        [[segue destinationViewController] setParentView:@"Explora"];
    }
}

@end
