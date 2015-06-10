//
// LookAndFeel.m
// CeliTax
//
// Created by Leon Chen on 2015-06-09.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "LookAndFeel.h"

@implementation LookAndFeel

-(void)addLeftInsetToTextField:(UITextField *)textField
{
    UIView *paddingView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 12, 12)];
    [paddingView setBackgroundColor: [UIColor clearColor]];
    
    textField.leftViewMode = UITextFieldViewModeAlways;
    [textField setLeftView: paddingView];
}

- (void) applyGrayBorderTo: (UIView *) view
{
    view.layer.cornerRadius = 2.0f;
    view.layer.borderColor = [UIColor colorWithWhite: 187.0f/255.0f alpha: 1].CGColor;
    view.layer.borderWidth = 1.0f;
}

- (void) applyHollowGreenButtonStyleTo: (UIButton *) button
{
    [button setBackgroundColor: [UIColor whiteColor]];
    button.layer.cornerRadius = 3.0f;
    button.layer.borderColor = [UIColor colorWithRed: 158.0f/255.0f green: 216.0f/255.0f blue: 113.0f/255.0f alpha: 1].CGColor;
    button.layer.borderWidth = 1.0f;

    button.layer.shadowColor = [UIColor colorWithRed: 158.0f/255.0f green: 216.0f/255.0f blue: 113.0f/255.0f alpha: 1].CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 1.5);
    button.layer.shadowOpacity = 1;
    button.layer.shadowRadius = 0;

    [button setTitleColor: [UIColor colorWithRed: 158.0f/255.0f green: 216.0f/255.0f blue: 113.0f/255.0f alpha: 1] forState: UIControlStateNormal];
}

@end