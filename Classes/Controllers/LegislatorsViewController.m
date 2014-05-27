//
//  LegislatorsViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LegislatorsViewController.h"
#import "LegislatorDetailViewController.h"
#import "SLFDataModels.h"
#import "LegislatorCell.h"

@interface LegislatorsViewController()
@end

@implementation LegislatorsViewController

- (id)initWithState:(SLFState *)newState {
    NSString *resourcePath = [SLFLegislator resourcePathForAllWithStateID:newState.stateID];
    self = [super initWithState:newState resourcePath:resourcePath dataClass:[SLFLegislator class]];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.screenName = @"Legislators Screen";
}

- (void)configureTableController {
    [super configureTableController];
    self.tableController.showsSectionIndexTitles = YES;
    self.tableController.tableView.rowHeight = 73;
    self.tableController.sectionNameKeyPath = @"lastnameInitial";
    __block __typeof__(self) bself = self;
    LegislatorCellMapping *objCellMap = [LegislatorCellMapping cellMappingUsingBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"self" toAttribute:@"legislator"];
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            NSString *path = [SLFActionPathNavigator navigationPathForController:[LegislatorDetailViewController class] withResource:object];
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:bself popToRoot:NO];
            [bself.searchBar resignFirstResponder];
        };
    }];
    [self.tableController mapObjectsWithClass:self.dataClass toTableCellsWithMapping:objCellMap];    
}

- (void)tableControllerDidFinishFinalLoad:(RKAbstractTableController*)tableController {
    [super tableControllerDidFinishFinalLoad:tableController];
    if (!self.tableController.isEmpty)
        self.title = [NSString stringWithFormat:@"%lu Members", (unsigned long)self.tableController.rowCount];
}

@end

