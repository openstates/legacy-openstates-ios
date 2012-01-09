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
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 SUNLIGHT_APIKEY,@"apikey", newState.stateID,@"state", nil];
    NSString *resourcePath = RKMakePathWithObject(@"/legislators?state=:state&active=true&apikey=:apikey", queryParams);
    self = [super initWithState:newState resourcePath:resourcePath dataClass:[SLFLegislator class]];
    return self;
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
        };
    }];
    [self.tableController mapObjectsWithClass:self.dataClass toTableCellsWithMapping:objCellMap];    
}

- (void)tableControllerDidFinishFinalLoad:(RKAbstractTableController*)tableController {
    [super tableControllerDidFinishFinalLoad:tableController];
    self.title = [NSString stringWithFormat:@"%d Members", self.tableController.rowCount];
}

@end

