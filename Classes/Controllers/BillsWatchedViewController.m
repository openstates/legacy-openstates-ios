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
#import "NSDate+SLFDateHelper.h"
#import "SLFDrawingExtensions.h"

@interface BillsWatchedViewController()
@property (nonatomic,retain) RKTableController *tableController;
@property (nonatomic,retain) IBOutlet id editButton;
@property (nonatomic,retain) IBOutlet id doneButton;
- (void)watchedBillsChanged:(NSNotification *)notification;
- (void)configureTableItems;
- (void)configureEditingButtons;
- (void)configureEditingButtonsIphone;
- (void)configureEditingButtonsIpad;
- (void)loadStatesForStateIDsFromNetwork:(NSSet *)stateIDs;
- (void)loadBillsForWatchIDsFromNetwork:(NSSet *)watchIDs;
- (NSArray *)actualBillsFromWatchedBills;
- (RKTableViewCellMapping *)billCellMapping;
@end

@implementation BillsWatchedViewController
@synthesize tableController = _tableController;
@synthesize editButton = __editButton;
@synthesize doneButton = __doneButton;
- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.useTitleBar = SLFIsIpad();
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(watchedBillsChanged:) name:SLFWatchedBillsDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    self.tableController = nil;
    self.editButton = nil;
    self.doneButton = nil;
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)viewDidUnload {
    self.editButton = nil;
    self.doneButton = nil;
    self.tableController = nil;
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableController = [RKTableController tableControllerForTableViewController:(UITableViewController*)self];
    _tableController.delegate = self;
    _tableController.objectManager = [RKObjectManager sharedManager];
    _tableController.pullToRefreshEnabled = NO;
    _tableController.tableView.rowHeight = 90;
    _tableController.canEditRows = YES;
    [_tableController mapObjectsWithClass:[SLFBill class] toTableCellsWithMapping:[self billCellMapping]];
    RKTableItem *emptyItem = [RKTableItem tableItemWithText:NSLocalizedString(@"No Watched Bills",@"") detailText:NSLocalizedString(@"There are no watched bills, yet. To add one, find a bill and click its star button.",@"")];
    emptyItem.cellMapping = [StyledCellMapping cellMappingWithStyle:UITableViewCellStyleSubtitle alternatingColors:NO largeHeight:YES selectable:NO];
    [emptyItem.cellMapping addDefaultMappings];
    _tableController.emptyItem = emptyItem;
    [self configureEditingButtons];
    [self configureTableItems];
    self.screenName = @"Watched Bills Screen";
}

- (NSString *)actionPath {
    return [[self class] actionPathForObject:nil];
}

- (void)configureEditingButtonsIphone {
    self.editButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"") orange:NO width:45 target:self action:@selector(toggleEditing:)] autorelease];
    self.doneButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"") orange:YES width:45 target:self action:@selector(toggleEditing:)] autorelease];
    [self.navigationItem setRightBarButtonItem:__editButton animated:YES];
}

- (void)configureEditingButtonsIpad {
    CGPoint origin = CGPointMake(self.titleBarView.size.width - 55, 15);

    self.doneButton = [UIButton buttonWithTitle:NSLocalizedString(@"Done", @"") orange:YES width:45 target:self action:@selector(toggleEditing:)];
    [__doneButton setOrigin:origin];
    [__doneButton setTag:6616];
    [__doneButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [__doneButton setHidden:YES];
    [self.titleBarView addSubview:__doneButton];

    self.editButton = [UIButton buttonWithTitle:NSLocalizedString(@"Edit", @"") orange:NO width:45 target:self action:@selector(toggleEditing:)];
    [__editButton setOrigin:origin];
    [__editButton setTag:6617];
    [__editButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.titleBarView addSubview:__editButton];
}

- (void)configureEditingButtons {
    if (SLFIsIpad())
        [self configureEditingButtonsIpad];
    else
        [self configureEditingButtonsIphone];
}

- (IBAction)toggleEditing:(id)sender {
    BOOL wantToEdit = (NO == self.tableController.tableView.editing);
    [self.tableController.tableView setEditing:wantToEdit animated:YES];
    id nextButton = wantToEdit ? self.doneButton : self.editButton;
    id previousButton = wantToEdit ? self.editButton : self.doneButton;
    if (SLFIsIpad()) {
        [previousButton setHidden:YES];
        [nextButton setHidden:NO];
    }
    else
        [self.navigationItem setRightBarButtonItem:nextButton animated:YES];
}

#pragma mark - Section / Row Data

- (NSArray *)filterBills:(NSArray *)bills withStateID:(NSString *)stateID {
    NSParameterAssert(!IsEmpty(bills) && !IsEmpty(stateID));
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"stateID == %@", [stateID lowercaseString]];
    return [bills filteredArrayUsingPredicate:pred];
}

- (void)recreateSectionForStateID:(NSString *)stateID usingWatchedBillsOrNil:(NSArray *)bills {
    if (!bills)
        bills = [self actualBillsFromWatchedBills];
    if (IsEmpty(bills))
        return;
    NSArray *stateBills = [self filterBills:bills withStateID:stateID];
    NSString *headerTitle = [stateID uppercaseString];
    RKTableSection *section = [_tableController sectionWithHeaderTitle:headerTitle];
    if (IsEmpty(stateBills)) {
        if (section)
            [_tableController removeSection:section];
        return;
    }
    if (!section) {
        section = SLFAddTableControllerSectionWithTitle(self.tableController, headerTitle);
    }
    [section setObjects:stateBills];
}

- (void)configureTableItems {
    [self.tableController removeAllSections];
    NSArray *bills = [self actualBillsFromWatchedBills];
    if (IsEmpty(bills)) {
        [self.tableController loadEmpty];
        [self.tableView reloadData];
        self.title = NSLocalizedString(@"No Watched Bills", @"");
        [self.editButton setEnabled:NO];
        return;
    }
    NSArray *states = [bills valueForKeyPath:@"stateID"];
    NSAssert(IsEmpty(states) == NO, @"Found watched bills but had an empty list of stateIDs??");
    for (NSString *state in states)
        [self recreateSectionForStateID:state usingWatchedBillsOrNil:bills];
    self.title = [NSString stringWithFormat:NSLocalizedString(@"%d Watched Bills",@""), _tableController.rowCount];
    [self.editButton setEnabled:YES];
    [self.tableView reloadData];
}

- (RKTableViewCellMapping *)billCellMapping {
    StyledCellMapping *cellMap = [StyledCellMapping cellMappingWithStyle:UITableViewCellStyleSubtitle alternatingColors:NO largeHeight:YES selectable:YES];
    [cellMap mapKeyPath:@"name" toAttribute:@"textLabel.text"];
    [cellMap mapKeyPath:@"watchSummaryForDisplay" toAttribute:@"detailTextLabel.text"];
    __block __typeof__(self) bself = self;
    cellMap.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
        SLFBill *bill = object;
        NSString *path = [SLFActionPathNavigator navigationPathForController:[BillDetailViewController class] withResource:bill];
        if (!IsEmpty(path))
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:bself popToRoot:NO];
    };
    return cellMap;
}

- (void)tableController:(RKAbstractTableController*)tableController didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
    if (!object || ![object isKindOfClass:[SLFBill class]])
        return;
    SLFBill *bill = [object retain];
    SLFSaveBillWatchedStatus(bill, NO);
    [bill release];
}

- (void)watchedBillsChanged:(NSNotification *)notification {
    if (!notification || !notification.object || NO == [notification.object isKindOfClass:[SLFBill class]]) {
        [self configureTableItems];
        return;
    }
    SLFBill *bill = (SLFBill *)notification.object;
    [self recreateSectionForStateID:bill.stateID usingWatchedBillsOrNil:nil];
    [self.tableView reloadData];
}

- (NSArray *)actualBillsFromWatchedBills {
    NSMutableArray *foundBills = [NSMutableArray array];
    NSDictionary *watchedBills = SLFWatchedBillsCatalog();
    if (IsEmpty(watchedBills))
        return foundBills;
    NSArray *watchIDs = [[watchedBills allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    NSMutableSet *billsToLoad = [NSMutableSet set];
    NSMutableSet *statesToLoad = [NSMutableSet set];
    for (NSString *watchID in watchIDs) {
        SLFBill *bill = [SLFBill billForWatchID:watchID];
        if (!bill) {
            [billsToLoad addObject:watchID];
            continue;
        }
        [foundBills addObject:bill];
        SLFState *state = bill.stateObj;
        if (!state)
            [statesToLoad addObject:bill.stateID];
    }
    [self loadBillsForWatchIDsFromNetwork:billsToLoad];
    [self loadStatesForStateIDsFromNetwork:statesToLoad];
    return foundBills;
}

- (void)loadBillsForWatchIDsFromNetwork:(NSSet *)watchIDs {
    if (IsEmpty(watchIDs))
        return;
    for (NSString *watchID in watchIDs) {
        NSString *resourcePath = [SLFBill resourcePathForWatchID:watchID];
        [[SLFRestKitManager sharedRestKit] loadObjectsAtResourcePath:resourcePath delegate:self withTimeout:SLF_HOURS_TO_SECONDS(1)];
    }
}

- (void)loadStatesForStateIDsFromNetwork:(NSSet *)stateIDs {
     if (IsEmpty(stateIDs))
         return;
     for (NSString *stateID in stateIDs) {
         NSString *resourcePath = [SLFState resourcePathForStateID:stateID];
         [[SLFRestKitManager sharedRestKit] loadObjectsAtResourcePath:resourcePath delegate:self withTimeout:SLF_HOURS_TO_SECONDS(1)];
     }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    if (!object)
        return;
    NSString *stateID = nil;
    if ([object isKindOfClass:[SLFBill class]] || [object isKindOfClass:[SLFState class]])
        stateID = [object valueForKey:@"stateID"];
    if (IsEmpty(stateID))
        return;
    [self recreateSectionForStateID:stateID usingWatchedBillsOrNil:nil];
    [self.tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    self.title = NSLocalizedString(@"Load Error", @"");
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
}
@end
