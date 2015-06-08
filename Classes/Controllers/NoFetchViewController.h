//
//  LegislatorsNoFetchViewController.h
//  Created by Greg Combs on 1/18/12.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFTableViewController.h"
#import "SLFImprovedRKTableController.h"

@interface NoFetchViewController : SLFTableViewController
@property (nonatomic,retain) SLFImprovedRKTableController *tableController;
@property (nonatomic,retain) SLFState *state;
@property (nonatomic,copy) NSString *resourcePath;
@property (nonatomic,assign) Class dataClass;

- (id)initWithState:(SLFState *)newState resourcePath:(NSString *)path dataClass:(Class)dataClass;
- (void)configureTableController;
- (void)loadTableFromNetwork;
- (void)resetObjectMapping;
@end
