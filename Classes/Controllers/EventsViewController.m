//
//  EventsViewController.m
//  Created by Gregory Combs on 8/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "EventsViewController.h"
#import "EventDetailViewController.h"
#import "SLFDataModels.h"

@interface EventsViewController()
@end

@implementation EventsViewController

- (id)initWithState:(SLFState *)newState {
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY,@"apikey", newState.stateID,@"state", nil];
    NSString *resourcePath = RKMakePathWithObject(@"/events/?state=:state&apikey=:apikey", queryParams);
    self = [super initWithState:newState resourcePath:resourcePath dataClass:[SLFEvent class]];
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Events Screen";
}

- (void)configureTableController {
    [super configureTableController];
    self.tableController.autoRefreshRate = 240;
    self.tableController.showsSectionIndexTitles = NO;
    self.tableController.sectionNameKeyPath = @"dayForDisplay";
    __block __typeof__(self) bself = self;
    StyledCellMapping *cellMapping = [StyledCellMapping subtitleMapping];
    cellMapping.useAlternatingRowColors = YES;
    [cellMapping mapKeyPath:@"title" toAttribute:@"textLabel.text"];
    [cellMapping mapKeyPath:@"dateStartForDisplay" toAttribute:@"detailTextLabel.text"];
    cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
        NSString *path = [SLFActionPathNavigator navigationPathForController:[EventDetailViewController class] withResource:object];
        if (!IsEmpty(path))
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:bself popToRoot:NO];
    };
    [self.tableController mapObjectsWithClass:self.dataClass toTableCellsWithMapping:cellMapping];    
}

- (void)tableControllerDidFinishFinalLoad:(RKAbstractTableController*)tableController {
    [super tableControllerDidFinishFinalLoad:tableController];
    if (!self.tableController.isEmpty)
        self.title = [NSString stringWithFormat:@"%lu Events", (unsigned long)self.tableController.rowCount];
}

- (BOOL)shouldShowChamberScopeBar {
    return NO;
}

@end


