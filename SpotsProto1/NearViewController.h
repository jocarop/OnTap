//
//  NearViewController.h
//  OnTap
//
//  Created by Andrea Martinez de Castro on 04/11/14.
//  Copyright (c) 2014 Appvertising. All rights reserved.
//

#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "RestaurantsAPI.h"

@interface NearViewController : PFQueryTableViewController <CLLocationManagerDelegate, MKMapViewDelegate, LocationDelegate>

@property (weak, nonatomic) IBOutlet MKMapView* mapView;

@end
