//
//  BillsViewController.m
//  Created by Gregory Combs on 11/6/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "BillsViewController.h"
#import "BillDetailViewController.h"
#import "SLFDataModels.h"
#import "BillSearchParameters.h"

@interface BillsViewController()
@end

@implementation BillsViewController

- (id)initWithState:(SLFState *)newState resourcePath:(NSString *)path {
    self = [super initWithState:newState resourcePath:path dataClass:[SLFBill class]];
    if (self) {
        self.useTitleBar = SLFIsIpad();
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.tableController.rowCount && !self.title)
        self.title = [NSString stringWithFormat:@"%d Bills", self.tableController.rowCount];
}

- (void)configureTableController {
    [super configureTableController];
    __block __typeof__(self) bself = self;
    LargeSubtitleCellMapping *objCellMap = [LargeSubtitleCellMapping cellMappingUsingBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"name" toAttribute:@"textLabel.text"];
        [cellMapping mapKeyPath:@"title" toAttribute:@"detailTextLabel.text"];
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            NSString *path = [SLFActionPathNavigator navigationPathForController:[BillDetailViewController class] withResource:object];
            if (!IsEmpty(path))
                [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:bself popToRoot:NO];
        };
    }];
    [self.tableController mapObjectsWithClass:self.dataClass toTableCellsWithMapping:objCellMap];
    self.tableView.rowHeight = objCellMap.rowHeight;
}

- (void)tableControllerDidFinishFinalLoad:(RKAbstractTableController*)tableController {
    [super tableControllerDidFinishFinalLoad:tableController];
    self.title = [NSString stringWithFormat:@"Found %d Bills", self.tableController.rowCount];
}

@end
