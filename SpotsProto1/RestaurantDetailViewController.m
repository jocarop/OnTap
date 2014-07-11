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
#import <QuartzCore/QuartzCore.h>

@implementation RestaurantDetailViewController
{
    //IBOutlet UIButton* favoritesBtn;
}

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem)
    {
        _detailItem = newDetailItem;
    }
}

- (void)viewDidLoad
{
    if (_detailItem.tieneSucursales)
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
        return 1;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];

    CGFloat width = self.view.frame.size.width;
    CGFloat margin = 10.0f;
    CGFloat height = 0.0f;
    
    if ([_detailItem.imagen length] != 0)
    {
        height = 100.0f;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(margin, margin, width - 2 * margin, height)];
        UIImage *myImage = [UIImage imageNamed:_detailItem.imagen];
        imageView.image = myImage;
    
        [headerView addSubview:imageView];
    }
    
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(0, height + margin, width, 30)];
    title.text = _detailItem.nombre;
    title.font = [UIFont fontWithName:@"Helvetica" size:22.0];
    title.textAlignment = NSTextAlignmentCenter;
    title.backgroundColor = [UIColor clearColor];
    
    UILabel* detail = [[UILabel alloc] initWithFrame:CGRectMake(0, height + 25 + margin, width, 30)];
    detail.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:16.0];
    detail.text = _detailItem.tipo;
    detail.textAlignment = NSTextAlignmentCenter;
    detail.backgroundColor = [UIColor clearColor];
    
    [headerView addSubview:title];
    [headerView addSubview:detail];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([_detailItem.imagen length] == 0)
        return 64.0f;
    else
        return 164.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* footerView = [[UIView alloc] init];
    
    CGFloat width = self.view.frame.size.width;
    
    UIButton* favoritesBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [favoritesBtn setFrame:CGRectMake(9, 10, width - 18, 44)];
    [favoritesBtn setTitle:@"Agregar a Favoritos" forState:UIControlStateNormal];
    [favoritesBtn setBackgroundColor:[UIColor whiteColor]];
    favoritesBtn.reversesTitleShadowWhenHighlighted = YES;

    [favoritesBtn addTarget: self action: @selector(addToFavorites:)
     forControlEvents: UIControlEventTouchDown];
    
    favoritesBtn.layer.borderColor = [self.tableView separatorColor].CGColor;
    favoritesBtn.layer.borderWidth = 0.5;
    
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
    
    /*else if (indexPath.row == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        cell.textLabel.text = @"Dirección";
        cell.detailTextLabel.text = _detailItem.direccion;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 5;
    }*/
    
    return cell;
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_detailItem.direccion != nil && indexPath.row == 1)
    {
        NSString *cellText = _detailItem.direccion;
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    
        NSAttributedString *attributedText =
        [[NSAttributedString alloc]
        initWithString:cellText
        attributes:@
        {
        NSFontAttributeName: cellFont
        }];
        CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
        return rect.size.height + 20;
    }
    
    return tableView.rowHeight;
    
}*/

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
                                            @"sucursal": sucursal
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