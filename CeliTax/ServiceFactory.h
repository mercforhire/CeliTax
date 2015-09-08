//
//  ServiceFactory.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConfigurationManager, DAOFactory, NetworkCommunicator, BuilderFactory;
@protocol AuthenticationService, DataService, ManipulationService, SyncService;

@interface ServiceFactory : NSObject

@property (nonatomic, weak) ConfigurationManager *configurationManager;     /** Used to access global config values */

@property (nonatomic, weak) DAOFactory  *daoFactory;

@property (nonatomic, weak) NetworkCommunicator *networkCommunicator;

@property (nonatomic, weak) BuilderFactory *builderFactory;

- (id<AuthenticationService>) createAuthenticationService;

- (id<DataService>) createDataService;

- (id<ManipulationService>) createManipulationService;

- (id<SyncService>) createSyncService;

@end
