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

@synthesize parentView;
@synthesize restaurantObj;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    UIView* headerView = [[UIView alloc] init];
    headerView.userInteractionEnabled = YES;
    
    CGFloat width = self.view.frame.size.width;
    CGFloat x = self.navigationController.navigationBar.frame.size.height + 20;
    
    PFImageView* imageView = [[PFImageView alloc] initWithFrame:CGRectMake(0, x, width, 164)];
    PFFile *thumbnail = restaurantObj[@"imagen"];
    imageView.image = [UIImage imageNamed:@"ontap.png"];
    imageView.file = thumbnail;
    [imageView loadInBackground];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, x+90, width, 25)];
    titleLabel.text = restaurantObj[@"nombre"];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:22.0];
    titleLabel.opaque = YES;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(1, 1);
    
    UILabel* detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, x+110, width, 20)];
    detailLabel.text = restaurantObj[@"tipo"];
    detailLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.textColor = [UIColor whiteColor];
    detailLabel.shadowColor = [UIColor blackColor];
    detailLabel.shadowOffset = CGSizeMake(1, 1);
    
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, x+130, width, 34)];
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
    [self.view addSubview:headerView];
    
    UIView* footerView = [[UIView alloc] init];

    UILabel* onTapLink = [[UILabel alloc] initWithFrame:CGRectMake(0, x+164+235, width, 44)];
    onTapLink.text = @"wwww.ontap.com.mx";
    onTapLink.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    onTapLink.textColor = [UIColor lightGrayColor];
    onTapLink.textAlignment = NSTextAlignmentCenter;
    onTapLink.backgroundColor = [UIColor clearColor];
    
    [footerView addSubview:onTapLink];
    [footerView sizeToFit];
    [self.view addSubview:footerView];
    
    self.carousel.type = iCarouselTypeLinear;
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [self.restaurantObj[@"sucursales"] count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 235) style:UITableViewStylePlain];
    tableView.delegate = (UITableViewController*)self;
    tableView.dataSource = (UITableViewController*)self;
    
    return tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Cell"];
    }
    
    NSInteger carouselIndex = [self.carousel indexOfItemViewOrSubview:tableView];
    PFObject* sucursal = [restaurantObj[@"sucursales"] objectAtIndex:carouselIndex];
    
    if (indexPath.row == 0)
    {
        NSString* detail = sucursal[@"telefono"];
        NSString* formattedPhoneNumber = [NSString stringWithFormat:@"(%@) %@-%@", [detail substringWithRange:NSMakeRange(0, 3)], [detail substringWithRange:NSMakeRange(3, 3)], [detail substringWithRange:NSMakeRange(6, 4)]];
        
        cell.textLabel.text = @"Telefono";
        cell.detailTextLabel.text = formattedPhoneNumber;
    }
    
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Dirección";
        cell.detailTextLabel.text = sucursal[@"direccion"];
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    else if (indexPath.row == 2)
    {
        cell.textLabel.text = @"Horario";
        cell.detailTextLabel.text = sucursal[@"horario"];
    }
    
    else if (indexPath.row == 3)
    {
        cell.textLabel.text = @"Precio";
        cell.detailTextLabel.text = restaurantObj[@"precio"];
    }
    
    else if (indexPath.row == 4)
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
 
    if (indexPath.row == 0)
    {
        [self makePhoneCall:indexPath.row];
    }
    else if (indexPath.row == 4)
    {
        NSString* url = [NSString stringWithFormat:@"http://%@", restaurantObj[@"pagina"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)makePhoneCall:(NSUInteger)index
{
    NSString* telefono = restaurantObj[@"telefono"];
    
    /*NSString* sucursal = @"";
    if ([restaurantObj[@"tieneSucursales"] boolValue])
    {
        sucursal = [[restaurantObj[@"sucursales"] objectAtIndex:index] objectForKey:@"sucursal"];
    }*/
    
    Mixpanel* mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Llamada" properties:@{
                                            @"id": restaurantObj.objectId,
                                            @"nombre": restaurantObj[@"nombre"],
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
        
        RestaurantAnnotation* annotation = [[RestaurantAnnotation alloc] init];
        PFGeoPoint* geoPoint = restaurantObj[@"geolocation"];
        CLLocationCoordinate2D geolocation = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
        annotation.coordinate = geolocation;
        annotation.title = restaurantObj[@"nombre"];
        annotation.subtitle = restaurantObj[@"tipo"];
            
        [annotations addObject:annotation];

        [[segue destinationViewController] setAnnotations:annotations];
    }
}

@end