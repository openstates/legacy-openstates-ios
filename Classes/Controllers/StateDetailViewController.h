//
//  StateDetailViewController.h
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFTableViewController.h"
#import "SLFState.h"

@interface StateDetailViewController : SLFTableViewController <StateMenuSelectionDelegate, RKObjectLoaderDelegate> {
}

@property (nonatomic,strong) RKTableController *tableController;
@property (nonatomic,strong) SLFState *state;
- (id)initWithState:(SLFState *)newState;
- (RKTableViewCellMapping *)menuCellMapping;   // override this to customize appearance
- (void)selectMenuItem:(NSString *)menuItem;   // override this to customize behavior
@end
