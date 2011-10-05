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

@implementation EventsViewController
@synthesize state;
@synthesize tableViewModel;
@synthesize resourcePath;

- (id)initWithState:(SLFState *)newState {
    self = [super init];
    if (self) {
        self.state = newState;
        NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                     SUNLIGHT_APIKEY,@"apikey", 
                                     newState.stateID,@"state", nil];
        self.resourcePath = RKMakePathWithObject(@"/events/?state=:state&apikey=:apikey", queryParams);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Loading...",@"");
    self.tableViewModel = [RKFetchedResultsTableViewModel tableViewModelForTableViewController:(UITableViewController*)self];
    self.tableViewModel.delegate = self;
    self.tableViewModel.objectManager = [RKObjectManager sharedManager];
    self.tableViewModel.resourcePath = self.resourcePath;
    [self.tableViewModel setObjectMappingForClass:[SLFEvent class]]; 
    self.tableViewModel.autoRefreshFromNetwork = YES;
    self.tableViewModel.autoRefreshRate = 240;
    self.tableViewModel.pullToRefreshEnabled = YES;
    
    SubtitleCellMapping *objCellMap = [SubtitleCellMapping cellMappingWithBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"eventDescription" toAttribute:@"textLabel.text"];
        [cellMapping mapKeyPath:@"dateStart" toAttribute:@"detailTextLabel.text"];
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            SLFEvent *event = object;
            EventDetailViewController *vc = [[EventDetailViewController alloc] initWithEventID:event.eventID];
            [self stackOrPushViewController:vc];
            [vc release];
        };
    }];
    [self.tableViewModel mapObjectsWithClass:[SLFEvent class] toTableCellsWithMapping:objCellMap];    
    [self.tableViewModel loadTable];
    self.title = [NSString stringWithFormat:@"%d Events",[[self.tableViewModel.fetchedResultsController fetchedObjects] count]];
}

- (void)tableViewModelDidFinishLoad:(RKAbstractTableViewModel*)tableViewModel {
    self.title = [NSString stringWithFormat:@"%d Events",[[self.tableViewModel.fetchedResultsController fetchedObjects] count]];
}

- (void)dealloc {
    self.tableViewModel = nil;
    self.state = nil;
    self.resourcePath = nil;
    [super dealloc];
}

@end


