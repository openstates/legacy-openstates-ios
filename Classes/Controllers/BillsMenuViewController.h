//
//  BillsMenuViewController.h
//  Created by Gregory Combs on 11/6/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFTableViewController.h"
#import "SLFState.h"

@interface BillsMenuViewController : SLFTableViewController <RKObjectLoaderDelegate> {
}

@property (nonatomic, retain) RKTableController *tableController;
@property (nonatomic,retain) SLFState *state;
- (id)initWithState:(SLFState *)newState;
- (void)reconfigureForState:(SLFState *)newState;
- (RKTableViewCellMapping *)menuCellMapping;   // override this to customize appearance
- (void)selectMenuItem:(NSString *)menuItem;   // override this to customize behavior

@end
