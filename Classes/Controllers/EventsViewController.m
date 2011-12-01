//
//  EventsViewController.m
//  Created by Gregory Combs on 8/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
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

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.tableViewModel.rowCount && !self.title)
        self.title = [NSString stringWithFormat:@"%d Events", self.tableViewModel.rowCount];
}

- (void)configureTableViewModel {
    [super configureTableViewModel];
    self.tableViewModel.autoRefreshRate = 240;
    SubtitleCellMapping *objCellMap = [SubtitleCellMapping cellMappingWithBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"eventDescription" toAttribute:@"textLabel.text"];
        [cellMapping mapKeyPath:@"dateStartForDisplay" toAttribute:@"detailTextLabel.text"];
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            SLFEvent *event = object;
            EventDetailViewController *vc = [[EventDetailViewController alloc] initWithEventID:event.eventID];
            [self stackOrPushViewController:vc];
            [vc release];
        };
    }];
    [self.tableViewModel mapObjectsWithClass:self.dataClass toTableCellsWithMapping:objCellMap];    
}

- (void)tableViewModelDidFinishLoad:(RKAbstractTableViewModel*)tableViewModel {
    [super tableViewModelDidFinishLoad:tableViewModel];
    if (!self.title)
        self.title = [NSString stringWithFormat:@"%d Events", self.tableViewModel.rowCount];
}

- (BOOL)shouldShowChamberScopeBar {
    return NO;
}

@end


