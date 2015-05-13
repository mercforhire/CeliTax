//
//  ViewControllerFactory.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RevealBlock)();

@class ConfigurationManager, UserManager;
@class BaseViewController, SplashViewController, LoginViewController, RegisterViewController, FeedbackViewController, SettingsViewController, VaultViewController, HelpScreenViewController, MainScreenRootViewController, MyAccountViewController, MainViewController, DeleteCatagoryViewController, TransferCatagoryViewController, ModifyCatagoryViewController, CatagoriesManagementViewController, AddCatagoryViewController, SidebarViewController, GHRevealViewController, ItemCatagory, ReceiptCheckingViewController;
@protocol AuthenticationService, DataService, ManipulationService;

@interface ViewControllerFactory : NSObject

@property (nonatomic, weak) UserManager *userManager;
@property (nonatomic, weak) ConfigurationManager *configurationManager;      /** Used to get global configuration values */

@property (nonatomic, weak) id <AuthenticationService> authenticationService;
@property (nonatomic, weak) id <DataService> dataService;
@property (nonatomic, weak) id <ManipulationService> manipulationService;

- (SplashViewController *) createSplashViewController;

- (LoginViewController *) createLoginViewController;

- (RegisterViewController *) createRegisterViewController;

- (SidebarViewController *) createSidebarViewControllerWithGHRevealViewController:(GHRevealViewController *)viewController withControllers:(NSArray *)viewControllers withCellInfos:(NSArray *)cellInfos;

- (MainScreenRootViewController *) createMainScreenRootViewController;

- (MainViewController *) createMainViewControllerWith:(RevealBlock)revealBlock;

- (FeedbackViewController *) createFeedbackViewControllerWith:(RevealBlock)revealBlock;

- (SettingsViewController *) createSettingsViewControllerWith:(RevealBlock)revealBlock;

- (VaultViewController *) createVaultViewControllerWith:(RevealBlock)revealBlock;

- (HelpScreenViewController *) createHelpScreenViewControllerWith:(RevealBlock)revealBlock;

- (MyAccountViewController *) createMyAccountViewControllerWith:(RevealBlock)revealBlock;

- (DeleteCatagoryViewController *) createDeleteCatagoryViewController:(ItemCatagory *)catagoryToDelete;

- (TransferCatagoryViewController *) createTransferCatagoryViewController;

- (ModifyCatagoryViewController *) createModifyCatagoryViewControllerWith:(ItemCatagory *)catagoryToModify;

- (CatagoriesManagementViewController *) createEditCatagoriesViewController;

- (AddCatagoryViewController *) createAddCatagoryViewController;

- (ReceiptCheckingViewController *) createReceiptCheckingViewController;

@end
