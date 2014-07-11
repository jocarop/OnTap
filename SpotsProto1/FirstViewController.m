//
//  FirstViewController.m
//  On Tap
//
//  Created by Jose Carlos Rodriguez on 03/07/14.
//  Copyright (c) 2014 On Tap. All rights reserved.
//

#import "FirstViewController.h"
#import "Mixpanel.h"
#import "RestaurantsAPI.h"
#import "MBProgressHUD.h"
#import "TSMessage.h"

@interface FirstViewController ()
{
    CLLocationManager* locationManager;
}

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
      
    if([CLLocationManager locationServicesEnabled])
    {
        [[self locationManager] startUpdatingLocation];
    }
    else
    {
        Mixpanel* mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Servicios de ubicacion deshabilitados"];
        
        [TSMessage showNotificationInViewController:[TSMessage defaultViewController]
                                    title:@"Error"
                                    subtitle:@"Servicios de ubicación deshabilitados. Habilite los servicios de ubicación en 'Ajustes > Privacidad > Localización' para poder utilizar esta aplicación."
                                        type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationEndless
                               canBeDismissedByUser:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CLLocationManager*)locationManager
{
    if (locationManager != nil)
    {
        return locationManager;
    }
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [locationManager setDelegate:self];
    self.locationManager.distanceFilter = 1000.0f;
    
    return locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    bool determined = YES;
    bool autorized = NO;
    NSString* authorizationStatus;
    switch ([CLLocationManager authorizationStatus])
    {
        case kCLAuthorizationStatusNotDetermined:
            authorizationStatus = @"No Determinado";
            determined = NO;
            break;
            
        case kCLAuthorizationStatusRestricted:
            authorizationStatus = @"Restringido";
            break;
            
        case kCLAuthorizationStatusDenied:
            authorizationStatus = @"Denegado";
            break;
            
        case kCLAuthorizationStatusAuthorized:
            authorizationStatus = @"Autorizado";
            autorized = YES;
            break;
            
        default:
            break;
    }
    
    if (determined && !autorized)
    {
        [TSMessage showNotificationInViewController:[TSMessage defaultViewController]
                                              title:@"Error"
                                           subtitle:@"Servicios de ubicación no autorizados. Autorice a esta aplicación para utilizar los servicios de ubicación en 'Ajustes > Privacidad > Localización'."
                                               type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationEndless
         canBeDismissedByUser:NO];
        
        Mixpanel* mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Servicios de ubicacion no autorizados" properties:@{@"estado":authorizationStatus}];
        
        self.tabBar.userInteractionEnabled = NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    
    if (determined)
    {
        if (autorized)
            self.tabBar.userInteractionEnabled = YES;
        
        [TSMessage dismissActiveNotification];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Buscando:";
    hud.detailsLabelText = @"Ubicacion";
    
    [locationManager stopUpdatingLocation];
    locationManager =  nil;
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0 && error == nil)
        {
            hud.labelText = @"Cargando:";
            hud.detailsLabelText = @"Datos";
            dispatch_queue_t downloadQueue = dispatch_queue_create("loadData", NULL);
            dispatch_async(downloadQueue, ^{
                
                // do our long running process here
                CLPlacemark* placemark = [placemarks objectAtIndex:0];
                NSString* postalCode = (placemark.postalCode != nil) ? placemark.postalCode : @"00000";
                
                Mixpanel* mixpanel = [Mixpanel sharedInstance];
                [mixpanel track:@"Abrio App" properties:@{
                                                          @"ciudad":placemark.locality,
                                                          @"codigo postal":postalCode
                                                          }];
                
                RestaurantsAPI* api = [RestaurantsAPI sharedInstance];
                bool data = [api loadRestaurants:placemark];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                        if (data)
                        {
                            UINavigationController* navController = (UINavigationController*)self.selectedViewController;
                            UITableViewController* viewController = (UITableViewController*)[navController visibleViewController];
                            [viewController.tableView reloadData];
                        }
                        else
                        {
                            [TSMessage showNotificationInViewController:[TSMessage defaultViewController]
                                                                  title:@"No Hay Resultados"
                                                               subtitle:@"No contamos con servicio en tu ciudad. Hemos recibido tu solicitud y estaremos agregando esta ciudad pronto. Síguenos en Facebook para estar enterado de las actualizaciones a nuestro directorio."
                                                                   type:TSMessageNotificationTypeMessage
                                                               duration:TSMessageNotificationDurationEndless
                                                   canBeDismissedByUser:NO];
                            
                            self.tabBar.userInteractionEnabled = NO;
                            [locationManager startUpdatingLocation];
                        }
                    
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
            });
        }
        else if (error)
        {
            [TSMessage showNotificationInViewController:[TSMessage defaultViewController]
                                                  title:@"Error"
                                               subtitle:@"No se ha podido determinar la ciudad en la que se encuentra. Por favor verifique su conexión a Internet."
                                                   type:TSMessageNotificationTypeError
                                               duration:TSMessageNotificationDurationEndless
                                   canBeDismissedByUser:NO];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.tabBar.userInteractionEnabled = NO;
            [locationManager startUpdatingLocation];
        }
    }];
}


@end
