//
//  BillsSubjectsViewController.h
//  Created by Greg Combs on 12/1/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFTableViewController.h"
#import "SLFState.h"
#import "SLFImprovedRKTableController.h"

@interface BillsSubjectsViewController : SLFTableViewController

@property (nonatomic, strong) SLFImprovedRKTableController *tableController;
@property (nonatomic, strong) SLFState *state;

- (id)initWithState:(SLFState *)newState;
- (void)reconfigureForState:(SLFState *)newState;

@end
