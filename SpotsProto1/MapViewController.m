//
//  MapViewController.m
//  OnTap
//
//  Created by Andrea Martinez de Castro on 22/07/14.
//  Copyright (c) 2014 Appvertising. All rights reserved.
//

#import "MapViewController.h"
#import "Util.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize restLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIColor* barColor = [UIColor colorWithRed:255.0/255.0 green:144.0/255.0 blue:66.0/255.0 alpha:0.9f];
    
    if ([Util isVersion7])
    {
        [self.view setTintColor:[UIColor whiteColor]];
        [self.myNavigationBar setBarTintColor:barColor];
        [self.myNavigationBar setTranslucent:YES];
        [self.myNavigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    }
    else
    {
        self.myNavigationBar.frame = CGRectMake(0, 0, 0, 0);
        [self.myNavigationBar sizeToFit];
        [self.myNavigationBar setTintColor:barColor];
        [self.myNavigationBar setTranslucent:NO];
    }
        
    UINavigationItem* navItem = [[UINavigationItem alloc] initWithTitle:@"Mapa"];
    UIBarButtonItem* close = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeMap:)];
    
    navItem.rightBarButtonItem = close;
    NSArray* items = [NSArray arrayWithObjects:navItem, nil];
    [self.myNavigationBar setItems:items];
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (userLocation.location.horizontalAccuracy > 50)
        return;
    
    CLLocationDegrees latDelta = userLocation.coordinate.latitude - restLocation.latitude;
    MKCoordinateSpan span = MKCoordinateSpanMake(fabsf(latDelta*3),0.0);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, span);
    
    self.mapView.region = region;
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (IBAction)closeMap:(UIButton*)sender
{
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
