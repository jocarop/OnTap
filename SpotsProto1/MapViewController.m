//
//  MapViewController.m
//  OnTap
//
//  Created by Andrea Martinez de Castro on 22/07/14.
//  Copyright (c) 2014 Appvertising. All rights reserved.
//

#import "MapViewController.h"
#import "Util.h"
#import "RestaurantAnnotation.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize annotation;

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
    
    if (annotation != nil)
    {
        [self.mapView addAnnotation:annotation];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationDegrees latDelta = userLocation.coordinate.latitude - annotation.coordinate.latitude;
    CLLocationDegrees lonDelta = userLocation.coordinate.longitude - annotation.coordinate.longitude;
    
    MKCoordinateSpan span;
    if (latDelta > lonDelta)
    {
        span = MKCoordinateSpanMake(fabsf(latDelta*3),0.0);
    }
    else
    {
        span = MKCoordinateSpanMake(0.0,fabsf(lonDelta*3));
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, span);
    
    self.mapView.region = region;
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [self.mapView selectAnnotation:[[self.mapView annotations] firstObject] animated:YES];
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
