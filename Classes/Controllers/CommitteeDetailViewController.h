//
//  CommitteeDetailViewController.h
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFTableViewController.h"

@class SLFCommittee;
@interface CommitteeDetailViewController : SLFTableViewController <RKObjectLoaderDelegate> {
}

@property (nonatomic,retain) SLFCommittee *committee;
- (id)initWithCommitteeID:(NSString *)committeeID;

@end
