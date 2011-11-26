//
//  BillsWatchedViewController.m
//  Created by Greg Combs on 11/25/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "BillsWatchedViewController.h"
#import "SLFDataModels.h"
#import "BillDetailViewController.h"
#import "SLFPersistenceManager.h"
#import "SLFRestKitManager.h"
#import "TableSectionHeaderView.h"
#import "NSDate+SLFDateHelper.h"

@interface BillsWatchedViewController()
@property (nonatomic,retain) RKTableViewModel *tableViewModel;
@property (nonatomic,retain) NSMutableArray *sectionNames;
@property (nonatomic,retain) NSMutableDictionary *rowsForSections;
- (void)watchedBillsChanged:(NSNotification *)notification;
- (void)configureTableItems;
- (void)loadWatchedWatchIDPathsFromNetwork:(NSSet *)watchIDPaths;
@end

@implementation BillsWatchedViewController
@synthesize tableViewModel = __tableViewModel;
@synthesize sectionNames = _sectionNames;
@synthesize rowsForSections = _rowsForSections;

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(watchedBillsChanged:) name:SLFWatchedBillsDidChangeNotification object:nil];
        self.sectionNames = [NSMutableArray array];
        self.rowsForSections = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.tableViewModel = nil;
    self.sectionNames = nil;
    self.rowsForSections = nil;
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)viewDidUnload {
    self.tableViewModel = nil;
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableViewModel = [RKTableViewModel tableViewModelForTableViewController:(UITableViewController*)self];
    __tableViewModel.delegate = self;
    __tableViewModel.objectManager = [RKObjectManager sharedManager];
    __tableViewModel.pullToRefreshEnabled = NO;
    __tableViewModel.tableView.rowHeight = 73;
    [self configureTableItems];
}

#pragma mark - Section / Row Data

- (void)addTableSectionWithTitle:(NSString *)sectionTitle {
    [__tableViewModel addSectionWithBlock:^(RKTableViewSection *section) {
        TableSectionHeaderView *headerView = [[TableSectionHeaderView alloc] initWithTitle:sectionTitle width:self.tableView.width];
        section.headerTitle = sectionTitle;
        section.headerHeight = TableSectionHeaderViewDefaultHeight;
        section.headerView = headerView;
        [headerView release];
    }];
}

- (RKTableItem *)tableItemForBill:(SLFBill *)bill {
    return [RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [LargeSubtitleCellMapping cellMapping];
        tableItem.text = [NSString stringWithFormat:NSLocalizedString(@"%@ - Updated %@",@""), bill.name, [bill.dateUpdated stringForDisplayWithPrefix:YES]];
        tableItem.detailText = bill.title;
        tableItem.cellMapping.onSelectCell = ^(void) {
            BillDetailViewController *vc = [[BillDetailViewController alloc] initWithBill:bill];
            [self stackOrPushViewController:vc];
            [vc release];
        };
    }];
}

- (NSMutableArray *)createEmptySectionWithName:(NSString *)sectionName {
    [self addTableSectionWithTitle:sectionName];
    NSMutableArray *rows = [NSMutableArray array];
    [self.rowsForSections setObject:rows forKey:sectionName];
    [self.sectionNames addObject:sectionName];
    return rows;
}

- (void)configureTableItems {
    [_sectionNames removeAllObjects];
    [_rowsForSections removeAllObjects];
    [__tableViewModel removeAllSections];
    
    NSDictionary *watchedBills = SLFWatchedBillsCatalog();
    if (IsEmpty(watchedBills)) {
            // Do something like insert a static cell, to show how to add watched bills
            // [__tableViewModel loadTableItems:[NSArray arrayWithObject:emptyTableItem]];
        return;
    }
    NSArray *watchIDs = [[watchedBills allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    NSMutableSet *billsToLoad = [NSMutableSet set];
    for (NSString *watchID in watchIDs) {
        NSString *path = [SLFBill resourcePathForWatchID:watchID];
        SLFBill *bill = [SLFBill billForWatchID:watchID];
        if (!bill && !IsEmpty(path)) {
            [billsToLoad addObject:path];
            continue;
        }
        SLFState *state = bill.state;
        NSMutableArray *rows = [_rowsForSections objectForKey:state.name];
        if (IsEmpty(rows))
            rows = [self createEmptySectionWithName:state.name];
        [rows addObject:[self tableItemForBill:bill]];
    }
    
    for (NSInteger index = 0; index < _sectionNames.count; index++) {
        NSString *sectionKey = [_sectionNames objectAtIndex:index];
        NSMutableArray *rows = [_rowsForSections objectForKey:sectionKey];
        [__tableViewModel loadTableItems:rows inSection:index + 1];
    }
    [self loadWatchedWatchIDPathsFromNetwork:billsToLoad];
    self.title = [NSString stringWithFormat:NSLocalizedString(@"%d Watched Bills",@""), __tableViewModel.rowCount];
}

- (void)addSingleTableRowForBill:(SLFBill *)bill {
    SLFState *state = bill.state;
    NSMutableArray *rows = [self.rowsForSections objectForKey:state.name];
    if (IsEmpty(rows))
        rows = [self createEmptySectionWithName:state.name];
    [rows addObject:[self tableItemForBill:bill]];
    NSInteger sectionIndex = [_sectionNames indexOfObject:state.name];
    [__tableViewModel loadTableItems:rows inSection:sectionIndex + 1];
}

- (void)watchedBillsChanged:(NSNotification *)notification {
    if (!notification || !notification.object || NO == [notification.object isKindOfClass:[SLFBill class]]) {
        [self configureTableItems];
        return;
    }
    SLFBill *bill = (SLFBill *)notification.object;
    BOOL isWatched = SLFBillIsWatched(bill);
    if (!isWatched) {
        [self configureTableItems];
        return;
    }
    [self addSingleTableRowForBill:bill];
}

- (void)loadWatchedWatchIDPathsFromNetwork:(NSSet *)watchIDPaths {
    if (!IsEmpty(watchIDPaths))
        return;
    for (NSString *resourcePath in watchIDPaths)
        [[SLFRestKitManager sharedRestKit] loadObjectsAtResourcePath:resourcePath delegate:self];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    if (!object || NO == [object isKindOfClass:[SLFBill class]])
        return;
    [self addSingleTableRowForBill:object];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    self.title = NSLocalizedString(@"Load Error", @"");
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
}

@end
