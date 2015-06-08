//
//  BillsSearchViewController.h
//  Created by Greg Combs on 11/21/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFTableViewController.h"

@class SLFState;
@interface BillsSearchViewController : SLFTableViewController
@property (nonatomic,retain) SLFState *state;
- (id)initWithState:(SLFState *)state;
@end
