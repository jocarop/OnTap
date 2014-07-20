//
//  RestaurantDetailViewController.m
//  On Tap
//
//  Created by Jose Carlos Rodriguez on 03/07/14.
//  Copyright (c) 2014 On Tap. All rights reserved.
//

#import "RestaurantDetailViewController.h"
#import "Mixpanel.h"
#import "RestaurantsAPI.h"
#import "MBProgressHUD.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>

@implementation RestaurantDetailViewController
{
    UIView* headerView;
}

@synthesize parentView;

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem)
    {
        _detailItem = newDetailItem;
    }
}

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
    
    if (_detailItem.tieneSucursales && [_detailItem.sucursales count] == 0)
    {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Cargando datos";
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("loadDetails", NULL);
        dispatch_async(downloadQueue, ^{
        
            [[RestaurantsAPI sharedInstance] getRestaurantDetails:_detailItem];
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        
        });
    }
    
    if (_detailItem.tieneImagen && _detailItem.imagen == nil)
    {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.center = CGPointMake(160, 45);
        spinner.hidesWhenStopped = YES;
        [headerView addSubview:spinner];
        [spinner startAnimating];
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("downloadImage", NULL);
        dispatch_async(downloadQueue, ^{
            
            [[RestaurantsAPI sharedInstance] getRestaurantImage:_detailItem];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView* imageView = [headerView.subviews objectAtIndex:0];
                imageView.image = _detailItem.imagen;
                imageView.alpha = 0.7f;
                [spinner stopAnimating];
            });
            
        });
    }

    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_detailItem.tieneSucursales)
    {
        return [_detailItem.sucursales count];
    }
    else
    {
        return 2;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    headerView = [[UIView alloc] init];
    
    CGFloat width = self.view.frame.size.width;

    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, 100)];
    imageView.image = _detailItem.imagen;
    imageView.alpha = 0.7f;
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 65, width, 25)];
    titleLabel.text = _detailItem.nombre;
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
    titleLabel.opaque = YES;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(1, 1);

    UILabel* detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 85, width, 15)];
    detailLabel.text = _detailItem.tipo;
    detailLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.textColor = [UIColor grayColor];
    
    [headerView addSubview:imageView];
    [headerView addSubview:titleLabel];
    [headerView addSubview:detailLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* footerView = [[UIView alloc] init];
    
    CGFloat width = self.view.frame.size.width;
    
    UIButton* favoritesBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [favoritesBtn setTitle:@"Agregar a Favoritos" forState:UIControlStateNormal];
    [favoritesBtn sizeToFit];
    
    if ([Util isVersion7])
    {
        CGFloat x = (width - favoritesBtn.frame.size.width - 20)/2;
        [favoritesBtn setBackgroundColor:[UIColor whiteColor]];
        [favoritesBtn setFrame:CGRectMake(x, 10, favoritesBtn.frame.size.width + 20, favoritesBtn.frame.size.height)];
        favoritesBtn.layer.borderWidth=0.5;
        favoritesBtn.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    }
    else
    {
        CGFloat x = (width - favoritesBtn.frame.size.width)/2;
        [favoritesBtn setFrame:CGRectMake(x, 10, favoritesBtn.frame.size.width, favoritesBtn.frame.size.height)];
    }
    
    [favoritesBtn addTarget: self action: @selector(addToFavorites:)
     forControlEvents: UIControlEventTouchDown];
    
    UILabel* onTapLink = [[UILabel alloc] initWithFrame:CGRectMake(0, 54, width, 44)];
    onTapLink.text = @"wwww.ontap.com.mx";
    onTapLink.font = [UIFont fontWithName:@"System" size:15.0];
    onTapLink.textColor = [UIColor lightGrayColor];
    onTapLink.textAlignment = NSTextAlignmentCenter;
    onTapLink.backgroundColor = [UIColor clearColor];
    
    [footerView addSubview:favoritesBtn];
    [footerView addSubview:onTapLink];

    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString* text = @"Telefono";
    NSString* detail = _detailItem.telefono;
    
    if (_detailItem.tieneSucursales)
    {
        text = [[_detailItem.sucursales objectAtIndex:indexPath.row] objectForKey:@"sucursal"];
        detail = [[_detailItem.sucursales objectAtIndex:indexPath.row] objectForKey:@"telefono"];
    }
    
    NSString* formattedPhoneNumber = [NSString stringWithFormat:@"(%@) %@-%@", [detail substringWithRange:NSMakeRange(0, 3)], [detail substringWithRange:NSMakeRange(3, 3)], [detail substringWithRange:NSMakeRange(6, 4)]];
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = formattedPhoneNumber;
    
    if (indexPath.row == 1 && !_detailItem.tieneSucursales)
    {
        cell.textLabel.text = @"Dirección";
        cell.detailTextLabel.text = _detailItem.direccion;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_detailItem.direccion != nil && indexPath.row == 1)
    {
        NSString *cellText = _detailItem.direccion;
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
    NSString* telefono = _detailItem.telefono;
    if (_detailItem.tieneSucursales)
    {
        telefono = [[_detailItem.sucursales objectAtIndex:indexPath.row] objectForKey:@"telefono"];
    }
    
    NSString* sucursal = @"";
    if (_detailItem.tieneSucursales)
    {
        sucursal = [[_detailItem.sucursales objectAtIndex:indexPath.row] objectForKey:@"sucursal"];
    }
    
    Mixpanel* mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Llamada" properties:@{
                                            @"id": _detailItem.objectId,
                                            @"nombre": _detailItem.nombre,
                                            @"sucursal": sucursal,
                                            @"vista": parentView
                                        }];
        
    NSString *dialThis = [NSString stringWithFormat:@"tel:%@", telefono];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialThis]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)addToFavorites:(id)sender
{
    RestaurantsAPI* api = [RestaurantsAPI sharedInstance];
    [api addFavoriteRestaurant:_detailItem.objectId];
}

@end