//
//  CommitteesViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "CommitteesViewController.h"
#import "CommitteeDetailViewController.h"
#import "SLFDataModels.h"

@implementation CommitteesViewController
@synthesize state;
@synthesize tableViewModel;
@synthesize resourcePath;

- (id)initWithState:(SLFState *)newState {
    self = [super init];
    if (self) {
        [self setStackWidth:320];
        self.state = newState;
        NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                     SUNLIGHT_APIKEY,@"apikey", 
                                     newState.stateID,@"state", nil];
        self.resourcePath = RKMakePathWithObject(@"/committees?state=:state&apikey=:apikey", queryParams);
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
    [self.tableViewModel setObjectMappingForClass:[SLFCommittee class]]; 
    self.tableViewModel.autoRefreshFromNetwork = YES;
    self.tableViewModel.autoRefreshRate = 360;
    self.tableViewModel.pullToRefreshEnabled = YES;
    
    SubtitleCellMapping *objCellMap = [SubtitleCellMapping cellMappingWithBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"committeeName" toAttribute:@"textLabel.text"];
        [cellMapping mapKeyPath:@"chamberShortName" toAttribute:@"detailTextLabel.text"];
        
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            SLFCommittee *committee = object;
            CommitteeDetailViewController *vc = [[CommitteeDetailViewController alloc] initWithCommitteeID:committee.committeeID];
            [self stackOrPushViewController:vc];
            [vc release];
            
        };
    }];
    [self.tableViewModel mapObjectsWithClass:[SLFCommittee class] toTableCellsWithMapping:objCellMap];    
    [self.tableViewModel loadTable];
    self.title = [NSString stringWithFormat:@"%d Committees",[[self.tableViewModel.fetchedResultsController fetchedObjects] count]];
}

- (void)tableViewModelDidFinishLoad:(RKAbstractTableViewModel*)tableViewModel {
    self.title = [NSString stringWithFormat:@"%d Committees",[[self.tableViewModel.fetchedResultsController fetchedObjects] count]];
}

- (void)dealloc {
    self.tableViewModel = nil;
    self.state = nil;
    self.resourcePath = nil;
    [super dealloc];
}

@end
