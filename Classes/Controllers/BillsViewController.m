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
#import "BillDetailViewController.h"
#import "SLFDataModels.h"
#import "BillSearchParameters.h"
#import "SLFRestKitManager.h"

@implementation BillsViewController
@synthesize state;
@synthesize tableViewModel = __tableViewModel;
@synthesize resourcePath;

- (id)initWithState:(SLFState *)newState resourcePath:(NSString *)path {
    self = [super init];
    if (self) {
        self.stackWidth = 380;
        self.state = newState;
        self.resourcePath = path;
    }
    return self;
}

- (id)initWithState:(SLFState *)newState {
    self = [self initWithState:newState resourcePath:nil];
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
            if (!object || ![object isKindOfClass:[SLFBill class]])
                return;
            SLFBill *bill = object;
            BillDetailViewController *vc = [[BillDetailViewController alloc] initWithBill:bill];
            [self stackOrPushViewController:vc];
            [vc release];
        };
    }];
    [self.tableViewModel mapObjectsWithClass:[SLFBill class] toTableCellsWithMapping:objCellMap];    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSAssert(self.resourcePath != NULL, @"Must set a resource path before attempting to download table data.");
    [self configureTableViewModel];
    [self.tableViewModel loadTable];
}

- (void)tableViewModelDidFinishLoad:(RKAbstractTableViewModel*)tableViewModel {
    [super tableViewModelDidFinishLoad:tableViewModel];
    if (!self.title)
        self.title = [NSString stringWithFormat:@"Found %d Bills",[[self.tableViewModel.fetchedResultsController fetchedObjects] count]];
}

- (void)dealloc {
    self.tableViewModel = nil;
    self.state = nil;
    self.resourcePath = nil;
    [super dealloc];
}

@end
