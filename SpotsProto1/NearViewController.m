//
//  NearViewController.m
//  OnTap
//
//  Created by Andrea Martinez de Castro on 04/11/14.
//  Copyright (c) 2014 Appvertising. All rights reserved.
//

#import "NearViewController.h"
#import "TSMessage.h"
#import "Util.h"
#import "Mixpanel.h"
#import "RestaurantsAPI.h"
#import "RestaurantDetailViewController.h"

@interface NearViewController ()
{
    CLLocationManager* locationManager;
}
@end

@implementation NearViewController

- (CLLocationManager*)locationManager
{
    if (locationManager != nil)
    {
        return locationManager;
    }
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    locationManager.delegate = self;
    
    return locationManager;
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
    
    UIImage *iconName = [UIImage imageNamed:@"name.png"];
    UIImage *selectedIconName = [UIImage imageNamed:@"name_selected.png"];
    
    [self.navigationController.tabBarItem setImage:iconName];
    [self.navigationController.tabBarItem setSelectedImage:selectedIconName];
    
    [TSMessage setDefaultViewController:self];
    
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
    [mixpanel track:@"Cerca de Mi"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    CLLocation* location = [locations lastObject];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        if ([placemarks count] > 0 && error == nil)
        {
            [RestaurantsAPI sharedInstance].placemark = [placemarks objectAtIndex:0];
        }
    }];
}

- (void)objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    
    if (error == nil && [CLLocationManager locationServicesEnabled])
    {
        [[self locationManager] startMonitoringSignificantLocationChanges];
    }
}

- (PFQuery *)queryForTable
{
    CLPlacemark* placemark = [RestaurantsAPI sharedInstance].placemark;
    if (placemark == nil)
        return nil;
    
    NSString* ciudad = placemark.locality;
    if ([ciudad isEqual:@"Cupertino"])
        ciudad = @"Sunnyvale";
    
    PFGeoPoint* geoPoint = [PFGeoPoint geoPointWithLocation:placemark.location];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Restaurant"];
    [query whereKey:@"ciudad" equalTo:ciudad];
    [query whereKey:@"geolocation" nearGeoPoint:geoPoint withinKilometers:1.0f];
    
    if (self.objects.count == 0)
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *cellIdentifier = @"NearCell";
    
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
        [[segue destinationViewController] setParentView:@"Cerca de Mi"];
    }
}

@end
