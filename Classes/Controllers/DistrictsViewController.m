//
//  DistrictsViewController.m
//  Created by Gregory Combs on 8/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.



#import "DistrictsViewController.h"
#import "DistrictDetailViewController.h"
#import "SLFDataModels.h"

@interface DistrictsViewController()
@end

@implementation DistrictsViewController

- (id)initWithState:(SLFState *)newState {
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY,@"apikey", newState.stateID,@"state", nil];
    NSString *resourcePath = RKMakePathWithObject(@"/districts/:state?apikey=:apikey", queryParams);
    self = [super initWithState:newState resourcePath:resourcePath dataClass:[SLFDistrict class]];
    return self;
}


- (void)configureTableController {
    [super configureTableController];
    self.tableController.autoRefreshRate = 36000;

    StyledCellMapping *cellMapping = [StyledCellMapping subtitleMapping];
    cellMapping.useAlternatingRowColors = YES;
    cellMapping.style = UITableViewCellStyleSubtitle;
    cellMapping.reuseIdentifier = @"VirtualDistrictTableViewCell";
    [cellMapping mapKeyPath:@"title" toAttribute:@"textLabel.text"];
    [cellMapping mapKeyPath:@"subtitle" toAttribute:@"detailTextLabel.text"];

    __weak __typeof__(self) bself = self;
    cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
        if (!bself)
            return;
        NSString *path = [SLFActionPathNavigator navigationPathForController:[DistrictDetailViewController class] withResource:object];
        if (SLFTypeNonEmptyStringOrNil(path))
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:bself popToRoot:NO];
            [bself.searchBar resignFirstResponder];
    };
    [self.tableController mapObjectsWithClass:self.dataClass toTableCellsWithMapping:cellMapping];        
}

- (void)tableControllerDidFinishFinalLoad:(RKAbstractTableController*)tableController {
    [super tableControllerDidFinishFinalLoad:tableController];
    if (!self.tableController.isEmpty)
        self.title = [NSString stringWithFormat:@"%d Districts", (int)self.tableController.rowCount];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.screenName = @"Districts Screen";
}

@end
