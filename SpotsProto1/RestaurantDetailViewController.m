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

@implementation RestaurantDetailViewController

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem)
    {
        _detailItem = newDetailItem;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView;

    headerView = [[UIView alloc] init];

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

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell;
    
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        cell.textLabel.text = @"Telefono";
        NSString* phoneNumber = [NSString stringWithFormat:@"(%@) %@-%@", [_detailItem.telefono substringWithRange:NSMakeRange(0, 3)], [_detailItem.telefono substringWithRange:NSMakeRange(3, 3)], [_detailItem.telefono substringWithRange:NSMakeRange(6, 4)]];
        cell.detailTextLabel.text = phoneNumber;
    }
    
    else if (indexPath.row == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        cell.textLabel.text = @"Dirección";
        cell.detailTextLabel.text = _detailItem.direccion;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 5;
    }
    
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Button" forIndexPath:indexPath];
        cell.textLabel.text = @"Agregar a Favoritos";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        Mixpanel* mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Llamada" properties:@{
                                                      @"id": _detailItem.objectId,
                                                      @"nombre": _detailItem.nombre
                                                      }];
        
        NSString *dialThis = [NSString stringWithFormat:@"tel:%@", _detailItem.telefono];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialThis]];
    }
    
    if (indexPath.row == 2)
    {
        RestaurantsAPI* api = [RestaurantsAPI sharedInstance];
        [api addFavoriteRestaurant:_detailItem.objectId];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end