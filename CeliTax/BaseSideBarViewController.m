//
// BaseSideBarViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-28.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseSideBarViewController.h"
#import "UserManager.h"
#import "ViewControllerFactory.h"
#import "SettingsViewController.h"
#import "VaultViewController.h"
#import "HelpScreenViewController.h"
#import "MyAccountViewController.h"
#import "MainViewController.h"
#import "LoginViewController.h"
#import "ProfileSettingsViewController.h"

#import "CeliTax-Swift.h"

@interface BaseSideBarViewController () <CDRTranslucentSideBarDelegate, SideMenuViewProtocol>

@end

@implementation BaseSideBarViewController

- (instancetype) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        // initialize the slider bar menu button
        UIButton *menuButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 28, 20)];
        [menuButton setBackgroundImage: [UIImage imageNamed: @"menu.png"] forState: UIControlStateNormal];
        menuButton.tintColor = [UIColor colorWithRed: 7.0 / 255 green: 61.0 / 255 blue: 48.0 / 255 alpha: 1.0f];
        [menuButton addTarget: self action: @selector(revealSidebar) forControlEvents: UIControlEventTouchUpInside];

        UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView: menuButton];
        self.navigationItem.rightBarButtonItem = menuItem;

        [self.navigationItem setHidesBackButton: YES];
    }

    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sideMenuView = [Utils getLeftSideViewUsing:self.userManager.user.avatarImage userName:[NSString stringWithFormat: @"%@ %@", self.userManager.user.firstname, self.userManager.user.lastname]];
    self.sideMenuView.delegate = self;
    self.sideMenuView.lookAndFeel = self.lookAndFeel;

    self.rightSideBar = [[CDRTranslucentSideBar alloc] initWithDirectionFromRight: YES];
    (self.rightSideBar).translucentAlpha = 0.98;
    self.rightSideBar.delegate = self;
    
    UITapGestureRecognizer *profileImageViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget: self
                                            action: @selector(profileSettingsPressed)];
    
    [self.sideMenuView.profileImageView addGestureRecognizer: profileImageViewTap];
    
    UITapGestureRecognizer *profileImageViewTap2 =
    [[UITapGestureRecognizer alloc] initWithTarget: self
                                            action: @selector(profileSettingsPressed)];
    
    [self.sideMenuView.usernameLabel addGestureRecognizer: profileImageViewTap2];

    if ([self isKindOfClass: [MainViewController class]])
    {
        (self.sideMenuView).currentlySelectedIndex = RootViewControllerHome;
    }
    else if ([self isKindOfClass: [MyAccountViewController class]])
    {
        (self.sideMenuView).currentlySelectedIndex = RootViewControllerAccount;
    }
    else if ([self isKindOfClass: [VaultViewController class]])
    {
        (self.sideMenuView).currentlySelectedIndex = RootViewControllerVault;
    }
    else if ([self isKindOfClass: [HelpScreenViewController class]])
    {
        (self.sideMenuView).currentlySelectedIndex = RootViewControllerHelp;
    }
    else if ([self isKindOfClass: [SettingsViewController class]])
    {
        (self.sideMenuView).currentlySelectedIndex = RootViewControllerSettings;
    }

    // Set ContentView in SideBar
    [self.rightSideBar setContentViewInSideBar: self.sideMenuView];
}

// slide out the slider bar
- (void) revealSidebar
{
    (self.sideMenuView).profileImage = self.userManager.user.avatarImage;
    
    [self.rightSideBar show];
}

- (void) pushAndReplaceTopViewControllerWith: (BaseViewController *) viewController
{
    [self.rightSideBar dismissAnimated: NO];

    // remove CDRTranslucentSideBar
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray: self.navigationController.viewControllers];

    [viewControllers removeObject: self.rightSideBar];

    [self.navigationController setViewControllers: viewControllers animated: YES];

    // push the new viewController
    [viewControllers addObject:viewController];

    // remove self viewController
    NSMutableArray *viewController2 = [NSMutableArray arrayWithArray: viewControllers];

    [viewController2 removeObject: self];

    // Assign the updated stack with animation
    [self.navigationController setViewControllers: viewController2 animated: YES];
}

- (void) popToLoginView
{
    [self.navigationController popToViewController: (self.navigationController.viewControllers)[0] animated: YES];
}

- (void)profileSettingsPressed
{
    [self.rightSideBar dismissAnimated: NO];
    
    // remove CDRTranslucentSideBar
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray: self.navigationController.viewControllers];
    
    [viewControllers removeObject: self.rightSideBar];
    
    [self.navigationController setViewControllers: viewControllers animated: YES];
    
    [self.navigationController pushViewController: [self.viewControllerFactory createProfileSettingsViewController] animated: YES];
}

#pragma mark - LeftSideMenuViewProtocol
- (void) selectedMenuIndex: (NSInteger) index
{
    switch (index)
    {
        case RootViewControllerHome:

            // push MainViewController if self is not already MainViewController
            if (![self isKindOfClass: [MainViewController class]])
            {
                [self pushAndReplaceTopViewControllerWith: [self.viewControllerFactory createMainViewController]];
            }
            else
            {
                // dismiss itself
                [self.rightSideBar dismiss];
            }

            break;

        case RootViewControllerAccount:

            // push MyAccountViewController if self is not already MyAccountViewController
            if (![self isKindOfClass: [MyAccountViewController class]])
            {
                [self pushAndReplaceTopViewControllerWith: [self.viewControllerFactory createMyAccountViewController]];
            }
            else
            {
                // dismiss itself
                [self.rightSideBar dismiss];
            }

            break;

        case RootViewControllerVault:

            // push VaultViewController if self is not already VaultViewController
            if (![self isKindOfClass: [VaultViewController class]])
            {
                [self pushAndReplaceTopViewControllerWith: [self.viewControllerFactory createVaultViewController]];
            }
            else
            {
                // dismiss itself
                [self.rightSideBar dismiss];
            }

            break;

        case RootViewControllerHelp:

            // push HelpScreenViewController if self is not already HelpScreenViewController
            if (![self isKindOfClass: [HelpScreenViewController class]])
            {
                [self pushAndReplaceTopViewControllerWith: [self.viewControllerFactory createHelpScreenViewController]];
            }
            else
            {
                // dismiss itself
                [self.rightSideBar dismiss];
            }

            break;

        case RootViewControllerSettings:

            // push SettingsViewController if self is not already SettingsViewController
            if (![self isKindOfClass: [SettingsViewController class]])
            {
                [self pushAndReplaceTopViewControllerWith: [self.viewControllerFactory createSettingsViewController]];
            }
            else
            {
                // dismiss itself
                [self.rightSideBar dismiss];
            }

            break;

        case RootViewControllerLogOff:

            [self.userManager deleteAllLocalUserData];
            
            [self.userManager logOutUser];

            // dismiss itself
            [self.rightSideBar dismiss];

            [self pushAndReplaceTopViewControllerWith: [self.viewControllerFactory createLoginViewController]];

            break;

        default:
            break;
    }
}

@end