//
//  DistrictsViewController.h
//  Created by Gregory Combs on 8/31/11.
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
@interface DistrictsViewController : SLFTableViewController {
}
@property (nonatomic, retain) RKFetchedResultsTableViewModel *tableViewModel;
@property (nonatomic, retain) SLFState *state;
@property (nonatomic, copy) NSString *resourcePath;

- (id)initWithState:(SLFState *)newState;

@end
