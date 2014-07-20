//
//  Restaurant.m
//  On Tap
//
//  Created by Jose Carlos Rodriguez on 03/07/14.
//  Copyright (c) 2014 On Tap. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

@synthesize objectId = _objectId;
@synthesize nombre = _nombre;
@synthesize telefono = _telefono;
@synthesize direccion = _direccion;
@synthesize tipo = _tipo;
@synthesize imagen = _imagen;
@synthesize sucursales = _sucursales;

- (id)initFromParseObject:(PFObject *)object
{
    self = [super init];
    
    if (self)
    {
        self.objectId = object.objectId;
        self.nombre = object[@"nombre"];
        self.telefono = object[@"telefono"];
        self.direccion = object[@"direccion"];
        self.tipo = object[@"tipo"];
        self.imagen = object[@"imagen"];
    }
    
    return self;
}

- (id)initWithPFObject:(PFObject*)object
{
    self = [super init];
    
    if (self)
    {
        self.objectId = object.objectId;
        self.nombre = object[@"nombre"];
        self.tipo = object[@"tipo"];
        self.telefono = object[@"telefono"];
        self.direccion = object[@"direccion"];
        self.tieneSucursales = [object[@"tieneSucursales"] boolValue];
        self.tieneImagen = [object[@"tieneImagen"] boolValue];
    }
    
    return self;
}

- (void)setTelefonos:(NSMutableArray *)telefonos
{
    self.telefono = [telefonos firstObject];
}

@end
