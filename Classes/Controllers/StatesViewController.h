//
//  StatesViewController.h
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFFetchedTableViewController.h"

@class SLFState;
@protocol StateMenuSelectionDelegate <NSObject>
@required
- (void)stateMenuSelectionDidChangeWithState:(SLFState *)aState;
@end

@interface StatesViewController : SLFFetchedTableViewController
@property (nonatomic, assign) id<StateMenuSelectionDelegate> stateMenuDelegate;
@end
