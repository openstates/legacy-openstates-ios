//
//  EventDetailViewController.h
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFTableViewController.h"
#import "SLFEventsManager.h"
#import "SLFImprovedRKTableController.h"

@class SLFEvent;

@interface EventDetailViewController : SLFTableViewController <RKObjectLoaderDelegate, SLFEventsManagerDelegate>

@property (nonatomic, strong) SLFImprovedRKTableController *tableController;
@property (nonatomic, strong) SLFEvent *event;

- (id)initWithEventID:(NSString *)objID;
- (id)initWithEvent:(SLFEvent *)event;

@end
