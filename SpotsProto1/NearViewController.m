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
#import "RestaurantAnnotation.h"

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
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
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
        
        PFObject* farthestRest = [self.objects lastObject];
        PFGeoPoint* geoPoint = farthestRest[@"geolocation"];
        
        CLPlacemark* placemark = [RestaurantsAPI sharedInstance].placemark;
    
        CLLocationDegrees latDelta = placemark.location.coordinate.latitude - geoPoint.latitude;
        CLLocationDegrees lonDelta = placemark.location.coordinate.longitude - geoPoint.longitude;
        
        MKCoordinateSpan span;
        if (fabsf(latDelta) > fabsf(lonDelta))
        {
            span = MKCoordinateSpanMake(fabsf(latDelta*2),0.0);
        }
        else
        {
            span = MKCoordinateSpanMake(0.0,fabsf(lonDelta*2));
        }
        
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude-latDelta/2, placemark.location.coordinate.longitude-lonDelta/2);
        
        MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
        self.mapView.region = region;
        
        for (PFObject* object in self.objects)
        {
            RestaurantAnnotation* annotation = [[RestaurantAnnotation alloc] initWithPFGeoPoint:object[@"geolocation"]];
            annotation.title = object[@"nombre"];
            [self.mapView addAnnotation:annotation];
        }
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
