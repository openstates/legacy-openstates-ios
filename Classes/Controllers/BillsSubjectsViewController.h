//
//  BillsSubjectsViewController.h
//  Created by Greg Combs on 12/1/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFTableViewController.h"
#import "SLFState.h"
#import "SLFImprovedRKTableController.h"

@interface BillsSubjectsViewController : SLFTableViewController

@property (nonatomic, strong) SLFImprovedRKTableController *tableController;
@property (nonatomic, strong) SLFState *state;

- (id)initWithState:(SLFState *)newState;
- (void)reconfigureForState:(SLFState *)newState;

@end
