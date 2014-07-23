//
//  MapViewController.h
//  OnTap
//
//  Created by Andrea Martinez de Castro on 22/07/14.
//  Copyright (c) 2014 Appvertising. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <UINavigationBarDelegate>

@property IBOutlet UINavigationBar* myNavigationBar;
@property (weak, nonatomic) IBOutlet MKMapView* mapVeiw;

@end
