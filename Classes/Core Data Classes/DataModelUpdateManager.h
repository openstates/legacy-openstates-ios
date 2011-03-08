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

@interface DataModelUpdateManager : NSObject <RKObjectLoaderDelegate, UIAlertViewDelegate> {
	NSDictionary *statusBlurbsAndModels;
	NSArray *availableUpdates;
	NSMutableArray *downloadedUpdates;
}

@property (nonatomic,retain) NSArray *availableUpdates;
@property (nonatomic,retain) NSMutableArray *downloadedUpdates;
@property (nonatomic,retain) NSDictionary *statusBlurbsAndModels;


- (void) checkAndAlertAvailableUpdates:(id)sender;
- (BOOL) isDataUpdateAvailable;
- (void) alertHasUpdates:(id)delegate;
- (void) performAvailableUpdates;
@end
