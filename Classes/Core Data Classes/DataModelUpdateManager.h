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

@interface DataModelUpdateManager : NSObject <RKObjectLoaderDelegate, UIAlertViewDelegate, RKRequestQueueDelegate> {
	NSDictionary *statusBlurbsAndModels;
	NSCountedSet *activeUpdates;
	RKRequestQueue *_queue;
}

@property (nonatomic,retain) NSCountedSet *activeUpdates;
- (void) performDataUpdatesIfAvailable:(id)sender;

@end
