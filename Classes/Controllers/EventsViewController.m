//
//  EventsViewController.m
//  Created by Gregory Combs on 8/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "EventsViewController.h"
#import "EventDetailViewController.h"
#import "SLFDataModels.h"
#import "SLFDrawingExtensions.h"

@interface EventsViewController()
@end

@implementation EventsViewController

- (id)initWithState:(SLFState *)newState {
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY,@"apikey", newState.stateID,@"state", nil];
    NSString *resourcePath = RKMakePathWithObject(@"/events/?state=:state&apikey=:apikey", queryParams);
    self = [super initWithState:newState resourcePath:resourcePath dataClass:[SLFEvent class]];
    return self;
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

    // Filter to events that happen today or later
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    today = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:today]];
    self.tableController.predicate = [NSPredicate predicateWithFormat:@"dateStart >= %@" argumentArray:@[today]];

    StyledCellMapping *cellMapping = [StyledCellMapping subtitleMapping];
    cellMapping.useAlternatingRowColors = YES;
    [cellMapping mapKeyPath:@"title" toAttribute:@"textLabel.text"];
    [cellMapping mapKeyPath:@"timeStartForDisplay" toAttribute:@"detailTextLabel.text"];

    __weak __typeof__(self) wSelf = self;
    cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
        if (!wSelf)
            return;
        NSString *path = [SLFActionPathNavigator navigationPathForController:[EventDetailViewController class] withResource:object];
        if (SLFTypeNonEmptyStringOrNil(path))
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:wSelf popToRoot:NO];
            [wSelf.searchBar resignFirstResponder];
    };
    [self.tableController mapObjectsWithClass:self.dataClass toTableCellsWithMapping:cellMapping];    
}

- (void)tableControllerDidFinishFinalLoad:(RKAbstractTableController*)tableController {
    [super tableControllerDidFinishFinalLoad:tableController];
    if (!self.tableController.isEmpty) {
        self.title = [NSString stringWithFormat:@"%lu Events", (unsigned long)self.tableController.rowCount];
    } else {
        self.title = @"No Events";
    }
}

- (BOOL)shouldShowChamberScopeBar {
    return NO;
}

@end


