//
//  YearSavingViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-08-14.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"
#import "DataService.h"

@interface YearSavingViewController : BaseViewController

@property (nonatomic, weak) id <DataService> dataService;

@end