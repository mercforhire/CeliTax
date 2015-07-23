//
//  CatagoryBuilder.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-20.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Catagory.h"

@interface CatagoryBuilder : NSObject

- (Catagory *) buildCatagoryFrom: (NSDictionary *) json;

@end
