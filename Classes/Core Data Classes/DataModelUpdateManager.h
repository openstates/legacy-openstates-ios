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
	NSMutableArray *availableUpdates;
	NSMutableArray *downloadedUpdates;
}

@property (nonatomic,retain) NSMutableArray *availableUpdates;
@property (nonatomic,retain) NSMutableArray *downloadedUpdates;
@property (nonatomic,retain) NSDictionary *statusBlurbsAndModels;

- (void) performDataUpdatesIfAvailable:(id)sender;

@end
