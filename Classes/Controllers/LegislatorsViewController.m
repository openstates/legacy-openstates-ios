//
//  LegislatorsViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
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
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 SUNLIGHT_APIKEY,@"apikey", newState.stateID,@"state", nil];
    NSString *resourcePath = RKMakePathWithObject(@"/legislators?state=:state&active=true&apikey=:apikey", queryParams);
    self = [super initWithState:newState resourcePath:resourcePath dataClass:[SLFLegislator class]];
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.tableViewModel.rowCount && !self.title)
        self.title = [NSString stringWithFormat:@"%d Members", self.tableViewModel.rowCount];
}

- (void)configureTableViewModel {
    [super configureTableViewModel];
    self.tableViewModel.showsSectionIndexTitles = YES;
    self.tableViewModel.tableView.rowHeight = 73;
    self.tableViewModel.sectionNameKeyPath = @"lastnameInitial";
    LegislatorCellMapping *objCellMap = [LegislatorCellMapping cellMappingWithBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"self" toAttribute:@"legislator"];
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            SLFLegislator *legislator = object;
            LegislatorDetailViewController *vc = [[LegislatorDetailViewController alloc] initWithLegislatorID:legislator.legID];
            [self stackOrPushViewController:vc];
            [vc release];
        };
    }];
    [self.tableViewModel mapObjectsWithClass:self.dataClass toTableCellsWithMapping:objCellMap];    
}

- (void)tableViewModelDidFinishLoad:(RKAbstractTableViewModel*)tableViewModel {
    [super tableViewModelDidFinishLoad:tableViewModel];
    if (!self.title)
        self.title = [NSString stringWithFormat:@"%d Members", self.tableViewModel.rowCount];
}

@end

