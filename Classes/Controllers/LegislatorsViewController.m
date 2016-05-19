//
//  LegislatorsViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


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

    __weak __typeof__(self) wSelf = self;
    LegislatorCellMapping *objCellMap = [LegislatorCellMapping cellMappingUsingBlock:^(RKTableViewCellMapping* cellMapping) {
        if (!wSelf)
            return;
        __strong __typeof__(wSelf) sSelf = wSelf;

        [cellMapping mapKeyPath:@"self" toAttribute:@"legislator"];

        __weak __typeof__(sSelf) wSelf = sSelf;
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            if (!wSelf)
                return;
            __strong __typeof__(wSelf) sSelf = wSelf;

            NSString *path = [SLFActionPathNavigator navigationPathForController:[LegislatorDetailViewController class] withResource:object];
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:sSelf popToRoot:NO];
            [sSelf.searchBar resignFirstResponder];
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

