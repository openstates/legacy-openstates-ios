//
//  CommitteesViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "CommitteesViewController.h"
#import "CommitteeDetailViewController.h"
#import "SLFDataModels.h"

@interface CommitteesViewController()
@end

@implementation CommitteesViewController

- (id)initWithState:(SLFState *)newState {
    NSString *resourcePath = [SLFCommittee resourcePathForAllWithStateID:newState.stateID];
    self = [super initWithState:newState resourcePath:resourcePath dataClass:[SLFCommittee class]];
    return self;
}

- (void)configureTableController
{
    [super configureTableController];

    StyledCellMapping *cellMapping = [StyledCellMapping subtitleMapping];
    cellMapping.useAlternatingRowColors = YES;
    [cellMapping mapKeyPath:@"fullName" toAttribute:@"textLabel.text"];
    [cellMapping mapKeyPath:@"chamberShortName" toAttribute:@"detailTextLabel.text"];

    __weak __typeof__(self) bself = self;
    cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
        if (!bself)
            return;
        NSString *path = [SLFActionPathNavigator navigationPathForController:[CommitteeDetailViewController class] withResource:object];
        if (SLFTypeNonEmptyStringOrNil(path))
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:bself popToRoot:NO];
        [bself.searchBar resignFirstResponder];
    };
    [self.tableController mapObjectsWithClass:self.dataClass toTableCellsWithMapping:cellMapping];    
}

- (void)tableControllerDidFinishFinalLoad:(RKAbstractTableController*)tableController {
    [super tableControllerDidFinishFinalLoad:tableController];
    if (!self.tableController.isEmpty)
        self.title = [NSString stringWithFormat:@"%lu Committees", (unsigned long)self.tableController.rowCount];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Committees View Screen";
}

@end
