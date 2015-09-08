//
//  ConfigurationManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigurationManager : NSObject

typedef enum : NSUInteger {
    UnitSystemMetric,
    UnitSystemImperial
} UnitSystems;

-(void)loadSettingsFromPersistence;

//Tax Year
-(NSNumber *)getCurrentTaxYear;

-(void)setCurrentTaxYear:(NSInteger)taxYear;

//Unit
-(NSNumber *)getUnitSystem;

-(void)setUnitSystem:(NSInteger)unitSystem;

@end
