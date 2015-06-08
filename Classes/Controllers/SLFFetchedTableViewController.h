//
//  SLFFetchedTableViewController.h
//  Created by Greg Combs on 11/24/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFTableViewController.h"
#import "SLFImprovedRKFetchedResultsTableController.h"

@interface SLFFetchedTableViewController : SLFTableViewController

@property (nonatomic, strong) SLFImprovedRKFetchedResultsTableController *tableController;
@property (nonatomic, strong) SLFState *state;
@property (nonatomic, copy) NSString *resourcePath;
@property (nonatomic, assign) Class dataClass;
@property (nonatomic, assign) BOOL omitSearchBar;
@property (nonatomic, strong) RKTableItem* defaultEmptyItem;

- (id)initWithState:(SLFState *)newState resourcePath:(NSString *)path dataClass:(Class)dataClass;
- (id)initWithState:(SLFState *)newState resourcePath:(NSString *)path;
- (id)initWithState:(SLFState *)newState; // set resource path before loading

- (BOOL)hasExistingChamberPredicate;
- (BOOL)filterDefaultFetchRequestWithChamberFilter:(NSString *)newChamberFilter;
- (BOOL)filterCustomPredicateWithChamberFilter:(NSString *)newChamberFilter;
- (void)configureTableController;
- (BOOL)hasSearchableDataClass;
- (BOOL)shouldShowChamberScopeBar;
@end
