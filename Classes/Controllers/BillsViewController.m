//
//  BillsViewController.m
//  Created by Gregory Combs on 11/6/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "BillsViewController.h"
#import "BillDetailViewController.h"
#import "SLFDataModels.h"
#import "BillSearchParameters.h"
#import "OpenStatesTableViewCell.h"

@interface BillsViewController()
@end

@implementation BillsViewController

- (id)initWithState:(SLFState *)newState resourcePath:(NSString *)path
{
    self = [super initWithState:newState resourcePath:path dataClass:[SLFBill class]];
    if (self) {
        self.useTitleBar = SLFIsIpad();
    }
    return self;
}

- (void)configureTableController
{
    [super configureTableController];
    StyledCellMapping *cellMapping = [StyledCellMapping cellMappingWithStyle:UITableViewCellStyleSubtitle alternatingColors:YES largeHeight:YES selectable:YES];
    cellMapping.cellClass = [OpenStatesSubtitleTableViewCell class];
    cellMapping.reuseIdentifier = @"OpenStatesSubtitleTableViewCell";

    [cellMapping mapKeyPath:@"name" toAttribute:@"textLabel.text"];
    [cellMapping mapKeyPath:@"title" toAttribute:@"detailTextLabel.text"];

    __weak __typeof__(self) bself = self;
    cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
        if (!bself)
            return;

        NSString *path = [SLFActionPathNavigator navigationPathForController:[BillDetailViewController class] withResource:object];
        if (SLFTypeNonEmptyStringOrNil(path))
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:bself popToRoot:NO];
            [bself.searchBar resignFirstResponder];
    };
    [self.tableController mapObjectsWithClass:self.dataClass toTableCellsWithMapping:cellMapping];
    self.tableView.rowHeight = cellMapping.rowHeight;
}

- (void)tableControllerDidFinishFinalLoad:(RKAbstractTableController*)tableController {
    [super tableControllerDidFinishFinalLoad:tableController];
    self.title = [NSString stringWithFormat:NSLocalizedString(@"%@ Bills",@""), self.state.stateIDForDisplay];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.screenName = @"Bills View Screen";
}


@end
