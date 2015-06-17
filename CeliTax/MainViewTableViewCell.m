//
// MainViewTableViewCell.m
// CeliTax
//
// Created by Leon Chen on 2015-05-08.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "MainViewTableViewCell.h"

@implementation MainViewTableViewCell

- (void) awakeFromNib
{
    // Initialization code

    [self setSelectionStyle: UITableViewCellSelectionStyleNone];
}

- (void) setSelected: (BOOL) selected animated: (BOOL) animated
{
    [super setSelected: selected animated: animated];

    // Configure the view for the selected state

    if (selected)
    {
        [self.colorBoxView setBackgroundColor: self.selectedColorBoxColor];
    }
    else
    {
        [self.colorBoxView setBackgroundColor: [UIColor clearColor]];
    }
}

@end