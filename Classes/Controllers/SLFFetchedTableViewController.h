//
//  SLFFetchedTableViewController.h
//  Created by Greg Combs on 11/24/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFTableViewController.h"

@interface SLFFetchedTableViewController : SLFTableViewController
@property (nonatomic, retain) RKFetchedResultsTableController *tableController;
@property (nonatomic, retain) SLFState *state;
@property (nonatomic, copy) NSString *resourcePath;
@property (nonatomic, assign) Class dataClass;
@property (nonatomic, assign) BOOL omitSearchBar;

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
