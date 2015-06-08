//
//  BillVotesViewController.h
//  Created by Greg Combs on 11/21/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFTableViewController.h"

@class BillRecordVote;
@interface BillVotesViewController : SLFTableViewController
@property (nonatomic,retain) BillRecordVote *vote;
- (id)initWithVote:(BillRecordVote *)vote;
@end
