//
//  ItemCatagory.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ItemCatagory : NSObject <NSCoding>

@property NSInteger                     identifer;

@property (nonatomic, copy) NSString    *name;
@property (nonatomic, strong) UIColor   *color;

@property float                         nationalAverageCost;

@end
