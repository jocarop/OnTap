//
//  RestaurantDetailViewController.m
//  On Tap
//
//  Created by Jose Carlos Rodriguez on 03/07/14.
//  Copyright (c) 2014 On Tap. All rights reserved.
//

#import "RestaurantDetailViewController.h"
#import "MapViewController.h"
#import "Mixpanel.h"
#import "RestaurantsAPI.h"
#import "MBProgressHUD.h"
#import "Util.h"
#import "RestaurantAnnotation.h"

@implementation RestaurantDetailViewController
{
    UIView* headerView;
}

@synthesize parentView;
@synthesize restaurantObj;

- (void)viewDidLoad
{
    UIColor* barColor = [UIColor colorWithRed:255.0/255.0 green:144.0/255.0 blue:66.0/255.0 alpha:0.9f];
    
    if ([Util isVersion7])
    {
        [self.navigationController.navigationBar setBarTintColor:barColor];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setTranslucent:YES];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    }
    else
    {
        [self.navigationController.navigationBar setTintColor:barColor];
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([restaurantObj[@"tieneSucursales"] boolValue])
    {
        NSInteger count = [restaurantObj[@"sucursales"] count];
        return count;
    }
    else
    {
        return 5;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    headerView = [[UIView alloc] init];
    
    CGFloat width = self.view.frame.size.width;

    PFImageView* imageView = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, width, 164)];
    
    PFFile *thumbnail = restaurantObj[@"imagen"];
    
    imageView.image = [UIImage imageNamed:@"ontap.png"];
    imageView.file = thumbnail;
    
    [imageView loadInBackground];

    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 90, width, 25)];
    titleLabel.text = restaurantObj[@"nombre"];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:22.0];
    titleLabel.opaque = YES;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(1, 1);

    UILabel* detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 110, width, 15)];
    detailLabel.text = restaurantObj[@"tipo"];
    detailLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.textColor = [UIColor whiteColor];
    detailLabel.shadowColor = [UIColor blackColor];
    detailLabel.shadowOffset = CGSizeMake(1, 1);
    
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 130, width, 34)];
    toolbar.alpha = 0.7f;
    
    if ([Util isVersion7])
    {
        [toolbar setBackgroundColor:[UIColor lightGrayColor]];
        [toolbar setTintColor:[UIColor blackColor]];
    }
    
    UIButton* favoritesBtn;
    UIButton* mapBtn;
    UIButton* photosBtn;
    
    if ([Util isVersion7])
    {
        favoritesBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        mapBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        photosBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    }
    else
    {
        favoritesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        photosBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    
    UIImage* favorites = [UIImage imageNamed:@"favoritos.png"];
    [favoritesBtn setImage:favorites forState:UIControlStateNormal];
    [favoritesBtn setTitle:@" Favoritos" forState:UIControlStateNormal];
    [favoritesBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    favoritesBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [favoritesBtn sizeToFit];
    [favoritesBtn setFrame:CGRectMake(0, 0, width/2, favoritesBtn.frame.size.height)];
    [favoritesBtn addTarget:self action:@selector(addToFavorites:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addToFavorites = [[UIBarButtonItem alloc] initWithCustomView:favoritesBtn];
    
    UIImage* map = [UIImage imageNamed:@"ver-mapa.png"];
    [mapBtn setImage:map forState:UIControlStateNormal];
    [mapBtn setTitle:@" Ver Mapa" forState:UIControlStateNormal];
    [mapBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    mapBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [mapBtn sizeToFit];
    [mapBtn setFrame:CGRectMake(0, 0, width/4, mapBtn.frame.size.height)];
    [mapBtn addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *showMap = [[UIBarButtonItem alloc] initWithCustomView:mapBtn];
    
    /*UIImage* photos = [UIImage imageNamed:@"ver-fotos.png"];
    [photosBtn setImage:photos forState:UIControlStateNormal];
    [photosBtn setTitle:@" Ver Fotos" forState:UIControlStateNormal];
    [photosBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    photosBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [photosBtn sizeToFit];
    [photosBtn setFrame:CGRectMake(0, 0, width/3, photosBtn.frame.size.height)];
    [photosBtn addTarget:self action:@selector(showPhotos:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *showPhotos = [[UIBarButtonItem alloc] initWithCustomView:photosBtn];
    */
    NSArray *buttonItems = [NSArray arrayWithObjects:addToFavorites, showMap, nil];
    [toolbar setItems:buttonItems];
    
    [headerView addSubview:imageView];
    [headerView addSubview:titleLabel];
    [headerView addSubview:detailLabel];
    [headerView addSubview:toolbar];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([Util isVersion7])
        return 164.0f;
    else
        return 174.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* footerView = [[UIView alloc] init];
    
    CGFloat width = self.view.frame.size.width;
    
    UILabel* onTapLink = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, width, 44)];
    onTapLink.text = @"wwww.ontap.com.mx";
    onTapLink.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    onTapLink.textColor = [UIColor lightGrayColor];
    onTapLink.textAlignment = NSTextAlignmentCenter;
    onTapLink.backgroundColor = [UIColor clearColor];

    [footerView addSubview:onTapLink];
    [footerView sizeToFit];

    return footerView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString* text = @"Telefono";
    NSString* detail = restaurantObj[@"telefono"];
    
    BOOL tieneSucursales = [restaurantObj[@"tieneSucursales"] boolValue];
    
    if (tieneSucursales)
    {
        text = [[restaurantObj[@"sucursales"] objectAtIndex:indexPath.row] objectForKey:@"sucursal"];
        detail = [[restaurantObj[@"sucursales"] objectAtIndex:indexPath.row] objectForKey:@"telefono"];
    }
    
    NSString* formattedPhoneNumber = [NSString stringWithFormat:@"(%@) %@-%@", [detail substringWithRange:NSMakeRange(0, 3)], [detail substringWithRange:NSMakeRange(3, 3)], [detail substringWithRange:NSMakeRange(6, 4)]];
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = formattedPhoneNumber;
    
    if (indexPath.row == 1 && !tieneSucursales)
    {
        cell.textLabel.text = @"Dirección";
        cell.detailTextLabel.text = restaurantObj[@"direccion"];
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    if (indexPath.row == 2 && !tieneSucursales)
    {
        cell.textLabel.text = @"Horario";
        cell.detailTextLabel.text = restaurantObj[@"horario"];
    }
    
    if (indexPath.row == 3 && !tieneSucursales)
    {
        cell.textLabel.text = @"Precio";
        cell.detailTextLabel.text = restaurantObj[@"precio"];
    }
    
    if (indexPath.row == 4 && !tieneSucursales)
    {
        cell.textLabel.text = @"Página";
        cell.detailTextLabel.text = restaurantObj[@"pagina"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (restaurantObj[@"direccion"] != nil && indexPath.row == 1)
    {
        NSString *cellText = restaurantObj[@"direccion"];
        UIFont *cellFont = [UIFont systemFontOfSize:17];
        CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
        CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        return labelSize.height + 20;
    }
    
    return tableView.rowHeight;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([restaurantObj[@"tieneSucursales"] boolValue])
    {
        [self makePhoneCall:indexPath.row];
    }
    else
    {
        if (indexPath.row == 0)
        {
            [self makePhoneCall:indexPath.row];
        }
        else if (indexPath.row == 4)
        {
            NSString* url = [NSString stringWithFormat:@"http://%@", restaurantObj[@"pagina"]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)makePhoneCall:(NSUInteger)index
{
    NSString* telefono = restaurantObj[@"telefono"];
    if ([restaurantObj[@"tieneSucursales"] boolValue])
    {
        telefono = [[restaurantObj[@"sucursales"] objectAtIndex:index] objectForKey:@"telefono"];
    }
    
    NSString* sucursal = @"";
    if ([restaurantObj[@"tieneSucursales"] boolValue])
    {
        sucursal = [[restaurantObj[@"sucursales"] objectAtIndex:index] objectForKey:@"sucursal"];
    }
    
    Mixpanel* mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Llamada" properties:@{
                                            @"id": restaurantObj.objectId,
                                            @"nombre": restaurantObj[@"nombre"],
                                            @"sucursal": sucursal,
                                            @"vista": parentView
                                            }];
    
    NSString *dialThis = [NSString stringWithFormat:@"telprompt:%@", telefono];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialThis]];
}

- (IBAction)addToFavorites:(UIButton*)sender
{
    RestaurantsAPI* api = [RestaurantsAPI sharedInstance];
    [api addFavoriteRestaurant:restaurantObj];
}

- (IBAction)showMap:(UIButton*)sender
{
    Mixpanel* mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Mapa visto" properties:@{
                                            @"id": restaurantObj.objectId,
                                            @"nombre": restaurantObj[@"nombre"],
                                            }];
    
    [self performSegueWithIdentifier: @"showMap" sender:self];
}

- (IBAction)showPhotos:(UIButton*)sender
{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMap"])
    {
        NSMutableArray* annotations = [[NSMutableArray alloc] init];
        
        if ([restaurantObj[@"tieneSucursales"] boolValue])
        {
            NSArray* sucursales = restaurantObj[@"sucursales"];
            
            for (NSDictionary* sucursal in sucursales)
            {
                CLLocationDegrees latitude = [[sucursal objectForKey:@"latitud"] floatValue];
                CLLocationDegrees longitude = [[sucursal objectForKey:@"longitud"] floatValue];
                
                RestaurantAnnotation* annotation = [[RestaurantAnnotation alloc] init];
                CLLocationCoordinate2D geolocation = CLLocationCoordinate2DMake(latitude, longitude);
                annotation.coordinate = geolocation;
                annotation.title = restaurantObj[@"nombre"];
                annotation.subtitle = restaurantObj[@"tipo"];
            
                [annotations addObject:annotation];
            }
        }
        else
        {
            RestaurantAnnotation* annotation = [[RestaurantAnnotation alloc] init];
            PFGeoPoint* geoPoint = restaurantObj[@"geolocation"];
            CLLocationCoordinate2D geolocation = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
            annotation.coordinate = geolocation;
            annotation.title = restaurantObj[@"nombre"];
            annotation.subtitle = restaurantObj[@"tipo"];
            
            [annotations addObject:annotation];
        }
        
        [[segue destinationViewController] setAnnotations:annotations];
    }
}

@end