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
#import "RestaurantsAPI.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize annotations;

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
    
    for (RestaurantAnnotation* annotation in annotations)
    {
        [self.mapView addAnnotation:annotation];
    }
    
    RestaurantAnnotation* annotation = [annotations firstObject];
    
    CLLocation* location = [RestaurantsAPI sharedInstance].location;
    CLLocationDegrees latDelta = location.coordinate.latitude - annotation.coordinate.latitude;
    CLLocationDegrees lonDelta = location.coordinate.longitude - annotation.coordinate.longitude;
    
    MKCoordinateSpan span;
    if (fabsf(latDelta) > fabsf(lonDelta))
    {
        span = MKCoordinateSpanMake(fabsf(latDelta*2),0.0);
    }
    else
    {
        span = MKCoordinateSpanMake(0.0,fabsf(lonDelta*2));
    }
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(location.coordinate.latitude-latDelta/2, location.coordinate.longitude-lonDelta/2);

    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    self.mapView.region = region;
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    for (NSObject* a in [self.mapView annotations])
    {
        if ([a isMemberOfClass:[RestaurantAnnotation class]])
        {
            [self.mapView selectAnnotation:(RestaurantAnnotation*)a animated:YES];
            break;
        }
    }
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
