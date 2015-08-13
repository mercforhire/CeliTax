//
//  UnitPickerViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-08-05.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"
#import "Record.h"

@protocol UnitPickerViewControllerDelegate <NSObject>

@required

- (void) selectedUnit:(NSInteger)unitType;

@end

@interface UnitPickerViewController : BaseViewController

@property (nonatomic, weak) id <UnitPickerViewControllerDelegate> delegate;

@property (nonatomic, assign) NSInteger defaultSelectedUnit;

@property CGSize viewSize;

@end
