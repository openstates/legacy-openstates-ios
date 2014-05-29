//
//  LegislatorsNoFetchViewController.h
//  Created by Greg Combs on 1/18/12.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

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
