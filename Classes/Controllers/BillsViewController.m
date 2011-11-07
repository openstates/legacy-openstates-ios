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
        self.resourcePath = [parameters pathForSubject:@"Education" state:newState session:newState.latestSession chamber:@"all"];
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
/*
            SLFBill *bill = object;
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
    NSLog(@"stuff = %@", [self.tableViewModel.fetchedResultsController fetchedObjects]);
}

- (void)dealloc {
    self.tableViewModel = nil;
    self.state = nil;
    self.resourcePath = nil;
    [super dealloc];
}

@end
