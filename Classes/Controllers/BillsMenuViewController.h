//
//  BillsMenuViewController.h
//  Created by Gregory Combs on 11/6/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SLFTableViewController.h"
#import "SLFState.h"
#import "SLFImprovedRKTableController.h"

@interface BillsMenuViewController : SLFTableViewController <RKObjectLoaderDelegate>

@property (nonatomic, strong) SLFImprovedRKTableController *tableController;
@property (nonatomic,strong) SLFState *state;
- (id)initWithState:(SLFState *)newState;
- (void)reconfigureForState:(SLFState *)newState;
- (RKTableViewCellMapping *)menuCellMapping;   // override this to customize appearance
- (void)selectMenuItem:(NSString *)menuItem;   // override this to customize behavior

@end
