//
//  ContributionsViewController.h
//  Created by Gregory Combs on 9/15/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFTableViewController.h"
#import "ContributionsDataSource.h"

@interface ContributionsViewController : SLFTableViewController
@property (nonatomic,retain) ContributionsDataSource *dataSource;
- (void)setQueryEntityID:(NSString *)newObj type:(NSNumber *)newType cycle:(NSString *)newCycle;

@end
