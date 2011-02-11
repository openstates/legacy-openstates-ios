//
//  DataModelUpdateManager.h
//  TexLege
//
//  Created by Gregory Combs on 1/26/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



@interface DataModelUpdateManager : NSObject {
	NSDictionary *statusBlurbsAndModels;
}

@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) NSDictionary *localModelCatalog;
@property (nonatomic,retain) NSDictionary *remoteModelCatalog;
@property (nonatomic,retain) NSArray *availableUpdates;
@property (nonatomic,retain) NSMutableArray *downloadedUpdates;
@property (nonatomic,retain) NSDictionary *statusBlurbsAndModels;

- (id) initWithManagedObjectContext:(NSManagedObjectContext*)newContext;
- (BOOL)isDataUpdateAvailable;
- (void)downloadDataUpdatesUsingCachedList:(BOOL)cached;
- (NSDictionary *)getLocalDataModelCatalog;

@end
