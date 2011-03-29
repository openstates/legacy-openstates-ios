//
//  DataModelUpdateManager.h
//  TexLege
//
//  Created by Gregory Combs on 1/26/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "TexLegeCoreDataUtils.h"

@interface DataModelUpdateManager : NSObject <RKObjectLoaderDelegate, UIAlertViewDelegate/*, TexLegeDataMaintenanceDelegate*/> {
	NSDictionary *statusBlurbsAndModels;
	NSMutableDictionary *availableUpdates;
	NSCountedSet *activeUpdates;
}

@property (nonatomic,retain) NSCountedSet *activeUpdates;
@property (nonatomic,retain) NSMutableDictionary *availableUpdates;
@property (nonatomic,retain) NSDictionary *statusBlurbsAndModels;
//@property (nonatomic,retain) NSOperationQueue *genericOperationQueue;

- (void) performDataUpdatesIfAvailable:(id)sender;

@end
