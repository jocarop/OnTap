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
@property (nonatomic, strong) NSString* imagen;
@property (nonatomic, assign) BOOL tieneSucursales;
@property (nonatomic, strong) NSArray* sucursales;

- (id)initFromParseObject:(PFObject*)object;
- (id)initWithPFObject:(PFObject*)object;

@end
