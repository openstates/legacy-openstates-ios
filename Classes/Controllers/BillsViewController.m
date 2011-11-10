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
#import "BillsDetailViewController.h"
#import "SLFDataModels.h"
#import "BillSearchParameters.h"
#import "SLFRestKitManager.h"

@implementation BillsViewController
@synthesize state;
@synthesize tableViewModel;
@synthesize resourcePath;

- (id)initWithState:(SLFState *)newState {
    self = [super init];
    if (self) {
        self.stackWidth = 320;
        self.state = newState;
        BillSearchParameters *parameters = [BillSearchParameters billSearchParameters];
            //self.resourcePath = [parameters pathForSubject:@"Education" state:newState session:newState.latestSession chamber:@"all"];
        self.resourcePath = [parameters pathForSubject:@"State Agencies" state:newState session:@"82" chamber:@"all"];
    }
    return self;
}

- (void)configureTableViewModel {
    self.tableViewModel = [RKFetchedResultsTableViewModel tableViewModelForTableViewController:(UITableViewController*)self];
    self.tableViewModel.delegate = self;
    self.tableViewModel.objectManager = [RKObjectManager sharedManager];
    self.tableViewModel.resourcePath = self.resourcePath;
    [self.tableViewModel setObjectMappingForClass:[SLFBill class]]; 
    self.tableViewModel.autoRefreshFromNetwork = YES;
    self.tableViewModel.autoRefreshRate = 360;
    self.tableViewModel.pullToRefreshEnabled = YES;
    SubtitleCellMapping *objCellMap = [SubtitleCellMapping cellMappingWithBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"billID" toAttribute:@"textLabel.text"];
        [cellMapping mapKeyPath:@"title" toAttribute:@"detailTextLabel.text"];
        
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            SLFBill *bill = object;
            NSString *billPath = [[BillSearchParameters billSearchParameters] pathForBill:bill];
            SLFRestKitManager *mgr = [SLFRestKitManager sharedRestKit];
            [mgr loadObjectsAtResourcePath:billPath delegate:self];
            /*
            BillsDetailViewController *vc = [[BillsDetailViewController alloc] initWithBillID:bill.billID];
            [self stackOrPushViewController:vc];
            [vc release];
  */          
        };
    }];
    [self.tableViewModel mapObjectsWithClass:[SLFBill class] toTableCellsWithMapping:objCellMap];    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Loading...",@"");
    [self configureTableViewModel];
    [self.tableViewModel loadTable];
    self.title = [NSString stringWithFormat:@"%d Bills",[[self.tableViewModel.fetchedResultsController fetchedObjects] count]];
}

- (void)tableViewModelDidFinishLoad:(RKAbstractTableViewModel*)tableViewModel {
    self.title = [NSString stringWithFormat:@"%d Bills",[[self.tableViewModel.fetchedResultsController fetchedObjects] count]];
}

- (void)dealloc {
    self.tableViewModel = nil;
    self.state = nil;
    self.resourcePath = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark RKObjectLoaderDelegate methods

#warning remove this later after testing bill mappings

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    RKLogDebug(@"Object Loader Finished: %@", objectLoader.resourcePath);
    SLFBill *bill = object;
    GenericWord *type = [bill.types anyObject];
    if (type) {
        NSLog(@"bill type: %@", type.word);
    }
    NSLog(@"bill votes: %d", [bill.votes count]);
    for (BillRecordVote *vote in bill.votes) {
        NSSet *yes = vote.yesVotes;
        NSSet *no = vote.noVotes;
        NSSet *other = vote.otherVotes;
        NSLog(@"bill vote: %@", vote.voteID);
        for (BillVoter *voter in yes) {
            NSLog(@"yes = (%@) %@", voter.legID, voter.name);
        }
        for (BillVoter *voter in other) {
            NSLog(@"other = (%@) %@", voter.legID, voter.name);
        }
        for (BillVoter *voter in no) {
            NSLog(@"no = (%@) %@", voter.legID, voter.name);
        }
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
}



@end
