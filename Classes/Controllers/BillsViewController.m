//
//  BillsViewController.m
//  Created by Gregory Combs on 11/6/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
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
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.tableViewModel.rowCount && !self.title)
        self.title = [NSString stringWithFormat:@"%d Bills", self.tableViewModel.rowCount];
}

- (void)configureTableViewModel {
    [super configureTableViewModel];
    SubtitleCellMapping *objCellMap = [SubtitleCellMapping cellMappingWithBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"name" toAttribute:@"textLabel.text"];
        [cellMapping mapKeyPath:@"title" toAttribute:@"detailTextLabel.text"];
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            if (!object || ![object isKindOfClass:[SLFBill class]])
                return;
            SLFBill *bill = object;
            BillDetailViewController *vc = [[BillDetailViewController alloc] initWithBill:bill];
            [self stackOrPushViewController:vc];
            [vc release];
        };
    }];
    [self.tableViewModel mapObjectsWithClass:self.dataClass toTableCellsWithMapping:objCellMap];
}

- (void)tableViewModelDidFinishLoad:(RKAbstractTableViewModel*)tableViewModel {
    [super tableViewModelDidFinishLoad:tableViewModel];
    self.title = [NSString stringWithFormat:@"Found %d Bills", self.tableViewModel.rowCount];
}

@end
