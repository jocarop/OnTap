//
//  Restaurant+TableRepresentation.m
//  SpotsProto1
//
//  Created by Andrea Martinez de Castro on 16/06/14.
//  Copyright (c) 2014 Appvertising. All rights reserved.
//

#import "Restaurant+TableRepresentation.h"

@implementation Restaurant (TableRepresentation)

- (NSDictionary*)tr_tableRepresentation
{
    return @{@"titles":@[@"Nombre", @"Telefono", @"Direccion", @"Tipo"],
             @"values":@[self.nombre, self.telefono, self.direccion, self.tipo]};
}

@end
