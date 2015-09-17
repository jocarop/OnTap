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
    
    if([CLLocationManager locationServicesEnabled])
    {
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [self.locationManager requestAlwaysAuthorization];
        }
     
        [[self locationManager] startMonitoringSignificantLocationChanges];
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
    
    self.mapView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            authorizationStatus = @"Autorizado";
            autorized = YES;
            break;
            
        default:
            authorizationStatus = @"No Determinado";
            autorized = NO;
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
        
        UITabBarController* tabController = (UITabBarController*)self.tabBarController;
        tabController.tabBar.userInteractionEnabled = NO;
    }
    
    if (determined)
    {
        if (autorized)
        {
            UITabBarController* tabController = (UITabBarController*)self.tabBarController;
            tabController.tabBar.userInteractionEnabled = YES;
        }
        
        [TSMessage dismissActiveNotification];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    CLLocation* location = [locations lastObject];
 
    RestaurantsAPI* api = [RestaurantsAPI sharedInstance];
    if (api.location != nil)
    {
        CLLocationDegrees latDelta = api.location.coordinate.latitude - location.coordinate.latitude;
        CLLocationDegrees lonDelta = api.location.coordinate.longitude - location.coordinate.longitude;
    
        if (fabsf(latDelta) < 0.225 && fabsf(lonDelta) < 0.225)
        {
            api.location = location;
            [self loadObjects];
            
            return;
        }
        
    }
    
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if ([placemarks count] > 0 && error == nil)
         {
             dispatch_queue_t downloadQueue = dispatch_queue_create("loadData", NULL);
             dispatch_async(downloadQueue, ^{
                 
                 CLPlacemark* placemark = [placemarks objectAtIndex:0];
                 NSString* postalCode = (placemark.postalCode != nil) ? placemark.postalCode : @"00000";
                 
                 Mixpanel* mixpanel = [Mixpanel sharedInstance];
                 [mixpanel track:@"Abrio App" properties:@{
                                                           @"ciudad":placemark.locality,
                                                           @"codigo postal":postalCode
                                                           }];
                 
                 RestaurantsAPI* api = [RestaurantsAPI sharedInstance];
                 api.locality = placemark.locality;
                 api.location = placemark.location;
                 
                 BOOL cityOK = [api isCityInCatalogue:placemark.locality];
                 if (!cityOK)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                     [TSMessage showNotificationInViewController:[TSMessage defaultViewController]
                                                           title:@"No Hay Resultados"
                                                        subtitle:@"No contamos con servicio en tu ciudad. Hemos recibido tu solicitud y estaremos agregando esta ciudad pronto. Síguenos en Facebook para estar enterado de las actualizaciones a nuestro catalogo."
                                                            type:TSMessageNotificationTypeMessage
                                                        duration:TSMessageNotificationDurationEndless
                                            canBeDismissedByUser:NO];
                         
                     UITabBarController* tabController = (UITabBarController*)self.tabBarController;
                     tabController.tabBar.userInteractionEnabled = NO;
                     
                     });
                 }
                 else
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         UINavigationController* navController = (UINavigationController*)self.parentViewController;
                         UITableViewController* viewController = (UITableViewController*)[navController visibleViewController];
                         [viewController.navigationItem setTitle:placemark.locality];
                         PFQueryTableViewController* queryViewController = (PFQueryTableViewController*)viewController;
                         [queryViewController loadObjects];
                     });
                 }
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
             
             UITabBarController* tabController = (UITabBarController*)self.tabBarController;
             tabController.tabBar.userInteractionEnabled = NO;
         }
     }];
}

- (void)objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    
    if (error == nil)
    {
        self.mapView.showsUserLocation = YES;
        
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        CLLocationCoordinate2D center;
        CLLocation* location = [RestaurantsAPI sharedInstance].location;
        
        PFObject* farthestRest = [self.objects lastObject];
        if (farthestRest == nil)
        {
            span = MKCoordinateSpanMake(0.0135f, 0.0);
            region = MKCoordinateRegionMake(location.coordinate, span);
        }
        else
        {
            PFGeoPoint* geoPoint = farthestRest[@"geolocation"];
        
            CLLocationDegrees latDelta = location.coordinate.latitude - geoPoint.latitude;
            CLLocationDegrees lonDelta = location.coordinate.longitude - geoPoint.longitude;
        
            if (fabsf(latDelta) > fabsf(lonDelta))
            {
                span = MKCoordinateSpanMake(fabsf(latDelta*2),0.0);
            }
            else
            {
                span = MKCoordinateSpanMake(0.0,fabsf(lonDelta*2));
            }
        
            center = CLLocationCoordinate2DMake(location.coordinate.latitude-latDelta/2, location.coordinate.longitude-lonDelta/2);
        
            region = MKCoordinateRegionMake(center, span);
        }
            
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
    CLLocation* location = [RestaurantsAPI sharedInstance].location;
    if (location == nil)
        return nil;
    
    NSString* ciudad = [RestaurantsAPI sharedInstance].locality;
    if ([ciudad isEqual:@"Cupertino"])
        ciudad = @"Sunnyvale";
    
    PFGeoPoint* geoPoint = [PFGeoPoint geoPointWithLocation:location];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Restaurant"];
    [query whereKey:@"ciudad" equalTo:ciudad];
    [query whereKey:@"geolocation" nearGeoPoint:geoPoint withinKilometers:2.0f];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    
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
