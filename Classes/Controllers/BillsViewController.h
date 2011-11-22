//
//  BillsViewController.h
//  Created by Gregory Combs on 11/6/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFTableViewController.h"

@class SLFState;
@interface BillsViewController : SLFTableViewController
@property (nonatomic, retain) RKFetchedResultsTableViewModel *tableViewModel;
@property (nonatomic, retain) SLFState *state;
@property (nonatomic, copy) NSString *resourcePath;
@property (nonatomic, retain) NSPredicate *filterResults;

- (id)initWithState:(SLFState *)newState resourcePath:(NSString *)path filterResults:(NSPredicate *)filter;
- (id)initWithState:(SLFState *)newState resourcePath:(NSString *)path;
- (id)initWithState:(SLFState *)newState; // set resource path before loading
@end
