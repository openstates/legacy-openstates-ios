//
//  DataModelUpdateManager.h
//  Created by Gregory Combs on 1/26/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
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
