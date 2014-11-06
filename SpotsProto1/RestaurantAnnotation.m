//
//  RestaurantAnnotation.m
//  OnTap
//
//  Created by Jose Carlos Rodriguez on 03/07/14.
//  Copyright (c) 2014 On Tap. All rights reserved.
//

#import "RestaurantAnnotation.h"

@implementation RestaurantAnnotation

- (id)initWithPFGeoPoint:(PFGeoPoint*)geoPoint
{
    self = [super init];
    
    if (self)
    {
        self.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    }
    
    return self;
}

@end
