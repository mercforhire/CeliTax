//
// CatagoryRecord.m
// CeliTax
//
// Created by Leon Chen on 2015-05-04.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "Record.h"

#define kKeyIdentifer            @"Identifer"
#define kKeyCatagoryID           @"CatagoryID"
#define kKeyReceiptID            @"ReceiptID"
#define kKeyAmount               @"Amount"
#define kKeyQuantity             @"Quantity"
#define kKeyUnitType             @"UnitType"
#define kKeyDataAction           @"DataAction"

@implementation Record

- (void) encodeWithCoder: (NSCoder *) coder
{
    [coder encodeObject: self.localID forKey: kKeyIdentifer];
    [coder encodeObject: self.catagoryID forKey: kKeyCatagoryID];;
    [coder encodeObject: self.receiptID forKey: kKeyReceiptID];
    [coder encodeFloat: self.amount forKey: kKeyAmount];
    [coder encodeInteger: self.quantity forKey: kKeyQuantity];
    [coder encodeInteger: self.unitType forKey: kKeyUnitType];
    [coder encodeInteger:self.dataAction forKey:kKeyDataAction];
}

- (id) initWithCoder: (NSCoder *) coder
{
    self = [self init];

    self.localID = [coder decodeObjectForKey: kKeyIdentifer];
    self.catagoryID = [coder decodeObjectForKey: kKeyCatagoryID];
    self.receiptID = [coder decodeObjectForKey: kKeyReceiptID];
    self.amount = [coder decodeFloatForKey: kKeyAmount];
    self.quantity = [coder decodeIntegerForKey: kKeyQuantity];
    self.unitType = [coder decodeIntegerForKey: kKeyUnitType];
    self.dataAction = [coder decodeIntegerForKey:kKeyDataAction];

    return self;
}

- (id) copyWithZone: (NSZone *) zone
{
    Record *copy = [[[self class] alloc] init];

    if (copy)
    {
        copy.localID = [self.localID copy];
        copy.catagoryID = [self.catagoryID copy];
        copy.receiptID = [self.receiptID copy];
        copy.amount = self.amount;
        copy.quantity = self.quantity;
        copy.unitType = self.unitType;
        copy.dataAction = self.dataAction;
    }

    return copy;
}

- (float) calculateTotal
{
    if (self.unitType == UnitItem)
    {
        return self.quantity * self.amount;
    }
    else
    {
        return self.amount;
    }
}

- (NSDictionary *) toJson
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    [json setObject:self.localID forKey:kKeyIdentifer];
    
    [json setObject:self.catagoryID forKey:kKeyCatagoryID];
    
    [json setObject:self.receiptID forKey:kKeyReceiptID];
    
    [json setObject:[NSNumber numberWithFloat:self.amount] forKey:kKeyAmount];
    
    [json setObject:[NSNumber numberWithInteger:self.quantity] forKey:kKeyQuantity];
    
    [json setObject:[NSNumber numberWithInteger:self.unitType] forKey:kKeyUnitType];
    
    [json setObject:[NSNumber numberWithInteger:self.dataAction] forKey:kKeyDataAction];
    
    return json;
}

-(void)copyDataFromRecord:(Record *)thisOne
{
    self.catagoryID = [thisOne.catagoryID copy];
    self.receiptID = [thisOne.receiptID copy];
    self.amount = thisOne.amount;
    self.quantity = thisOne.quantity;
    self.unitType = thisOne.unitType;
    self.dataAction = thisOne.dataAction;
}

@end