//
// ColorPickerViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-11.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ColorPickerViewController.h"

@interface ColorPickerViewController ()

@end

@implementation ColorPickerViewController

- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        // Custom initialization
        self.viewSize = CGSizeMake(46, 274);
    }

    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // apply gray border to all subviews
    
    for (UIView *subview in [self.view subviews])
    {
        [self.lookAndFeel applyGrayBorderTo: subview];
    }
}

- (IBAction) colorBoxPressed: (UIButton *) sender
{
    if (self.delegate)
    {
        [self.delegate selectedColor: sender.backgroundColor];
    }
}

- (IBAction) customerColorButtonPressed: (UIButton *) sender
{
    if (self.delegate)
    {
        [self.delegate customColorPressed];
    }
}

@end