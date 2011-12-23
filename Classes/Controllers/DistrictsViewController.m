//
//  DistrictsViewController.m
//  Created by Gregory Combs on 8/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//


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

- (void)dealloc {
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%d Districts", self.tableController.rowCount];
}

- (void)configureTableController {
    [super configureTableController];
    self.tableController.autoRefreshRate = 36000;
    SubtitleCellMapping *objCellMap = [SubtitleCellMapping cellMappingUsingBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"title" toAttribute:@"textLabel.text"];
        [cellMapping mapKeyPath:@"subtitle" toAttribute:@"detailTextLabel.text"];
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            NSString *path = [SLFActionPathNavigator navigationPathForController:[DistrictDetailViewController class] withResource:object];
            if (!IsEmpty(path))
                [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:self popToRoot:NO];
        };
    }];
    [self.tableController mapObjectsWithClass:self.dataClass toTableCellsWithMapping:objCellMap];        
}

- (void)tableControllerDidFinishFinalLoad:(RKAbstractTableController*)tableController {
    [super tableControllerDidFinishFinalLoad:tableController];
    self.title = [NSString stringWithFormat:@"%d Districts", self.tableController.rowCount];
}

@end
