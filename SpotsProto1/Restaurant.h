//
//  Restaurant.h
//  On Tap
//
//  Created by Jose Carlos Rodriguez on 03/07/14.
//  Copyright (c) 2014 On Tap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Restaurant : NSObject

@property (nonatomic, strong) NSString* objectId;
@property (nonatomic, strong) NSString* nombre;
@property (nonatomic, strong) NSString* telefono;
@property (nonatomic, strong) NSString* direccion;
@property (nonatomic, strong) NSString* tipo;
@property (nonatomic, assign) BOOL tieneSucursales;
@property (nonatomic, strong) NSArray* sucursales;
@property (nonatomic, assign) BOOL tieneImagen;
@property (nonatomic, strong) UIImage* imagen;
@property (nonatomic, strong) NSString* precio;
@property (nonatomic, strong) NSString* horario;
@property (nonatomic, strong) NSString* pagina;
@property (nonatomic, assign) CLLocationCoordinate2D geolocation;

- (id)initFromParseObject:(PFObject*)object;
- (id)initWithPFObject:(PFObject*)object;

@end
