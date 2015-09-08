//
//  TaxYearsDAO.h
//  CeliTax
//
//  Created by Leon Chen on 2015-06-17.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDataDAO.h"

@interface TaxYearsDAO : NSObject

@property (weak, nonatomic) UserDataDAO *userDataDAO;

-(NSArray *)loadAllTaxYears;

-(BOOL)addTaxYear:(NSInteger)taxYear save:(BOOL)save; 

-(BOOL)mergeWith:(NSArray *)taxyears save:(BOOL)save;

@end
