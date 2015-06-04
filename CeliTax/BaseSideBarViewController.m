//
//  BaseSideBarViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-28.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseSideBarViewController.h"
#import "UserManager.h"
#import "User.h"
#import "Utils.h"
#import "ViewControllerFactory.h"
#import "SettingsViewController.h"
#import "VaultViewController.h"
#import "HelpScreenViewController.h"
#import "MyAccountViewController.h"
#import "MainViewController.h"

@interface BaseSideBarViewController () <CDRTranslucentSideBarDelegate, LeftSideMenuViewProtocol>

@end

@implementation BaseSideBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		//initialize the slider bar menu button
		UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 20)];
		[menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
		menuButton.tintColor = [UIColor colorWithRed:7.0 / 255 green:61.0 / 255 blue:48.0 / 255 alpha:1.0f];
		[menuButton addTarget:self action:@selector(revealSidebar) forControlEvents:UIControlEventTouchUpInside];

		UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
		self.navigationItem.rightBarButtonItem = menuItem;

		[self.navigationItem setHidesBackButton:YES];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.leftSideMenuView = [Utils getLeftSideViewUsing:self.userManager.user.avatarImage
	                                        andUsername:[NSString stringWithFormat:@"%@ %@", self.userManager.user.firstname, self.userManager.user.lastname]
	                                  andMenuSelections:[self.viewControllerFactory getMenuSelections]];
	self.leftSideMenuView.delegate = self;

	self.rightSideBar = [[CDRTranslucentSideBar alloc] initWithDirectionFromRight:YES];
	[self.rightSideBar setTranslucentAlpha:0.8];
	self.rightSideBar.delegate = self;

	if ([self isKindOfClass:[MainViewController class]]) {
		[self.leftSideMenuView setCurrentlySelectedIndex:RootViewControllerHome];
	}
	else if ([self isKindOfClass:[MyAccountViewController class]]) {
		[self.leftSideMenuView setCurrentlySelectedIndex:RootViewControllerAccount];
	}
	else if ([self isKindOfClass:[VaultViewController class]]) {
		[self.leftSideMenuView setCurrentlySelectedIndex:RootViewControllerVault];
	}
	else if ([self isKindOfClass:[HelpScreenViewController class]]) {
		[self.leftSideMenuView setCurrentlySelectedIndex:RootViewControllerHelp];
	}
	else if ([self isKindOfClass:[SettingsViewController class]]) {
		[self.leftSideMenuView setCurrentlySelectedIndex:RootViewControllerSettings];
	}

	// Set ContentView in SideBar
	[self.rightSideBar setContentViewInSideBar:self.leftSideMenuView];
}

//slide out the slider bar
- (void)revealSidebar {
	[self.rightSideBar show];
}

- (void)pushAndReplaceTopViewControllerWith:(BaseSideBarViewController *)viewController {
	[self.rightSideBar dismissAnimated:NO];

	//remove CDRTranslucentSideBar
	NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];

	[viewControllers removeObject:self.rightSideBar];

	[self.navigationController setViewControllers:viewControllers animated:NO];

	//push the new viewController
	[self.navigationController pushViewController:viewController animated:YES];

	//remove self viewController
	NSMutableArray *viewController2 = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];

	[viewController2 removeObject:self];

	// Assign the updated stack with animation
	[self.navigationController setViewControllers:viewController2 animated:NO];
}

#pragma mark - LeftSideMenuViewProtocol
- (void)selectedMenuIndex:(NSInteger)index {
	DLog(@"Sidebar selection %ld clicked", index);

	switch (index) {
		case RootViewControllerHome:
			//push MainViewController if self is not already MainViewController
			if (![self isKindOfClass:[MainViewController class]]) {
				[self pushAndReplaceTopViewControllerWith:[self.viewControllerFactory createMainViewController]];
			}
			break;

		case RootViewControllerAccount:
			//push MyAccountViewController if self is not already MyAccountViewController
			if (![self isKindOfClass:[MyAccountViewController class]]) {
				[self pushAndReplaceTopViewControllerWith:[self.viewControllerFactory createMyAccountViewController]];
			}
			break;

		case RootViewControllerVault:
			//push VaultViewController if self is not already VaultViewController
			if (![self isKindOfClass:[VaultViewController class]]) {
				[self pushAndReplaceTopViewControllerWith:[self.viewControllerFactory createVaultViewController]];
			}
			break;

		case RootViewControllerHelp:
			//push HelpScreenViewController if self is not already HelpScreenViewController
			if (![self isKindOfClass:[HelpScreenViewController class]]) {
				[self pushAndReplaceTopViewControllerWith:[self.viewControllerFactory createHelpScreenViewController]];
			}
			break;

		case RootViewControllerSettings:
			//push SettingsViewController if self is not already SettingsViewController
			if (![self isKindOfClass:[SettingsViewController class]]) {
				[self pushAndReplaceTopViewControllerWith:[self.viewControllerFactory createSettingsViewController]];
			}
			break;

		default:
			break;
	}
}

@end