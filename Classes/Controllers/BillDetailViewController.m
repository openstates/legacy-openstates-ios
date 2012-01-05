//
//  BillDetailViewController.m
//  Created by Gregory Combs on 2/20/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "BillDetailViewController.h"
#import "SLFDataModels.h"
#import "BillsViewController.h"
#import "BillSearchParameters.h"
#import "LegislatorDetailViewController.h"
#import "BillVotesViewController.h"
#import "DDActionHeaderView.h"
#import "SLFMappingsManager.h"
#import "SLFRestKitManager.h"
#import "SVWebViewController.h"
#import "SLFReachable.h"
#import "TableSectionHeaderView.h"
#import "NSDate+SLFDateHelper.h"
#import "LegislatorCell.h"
#import "SLFDrawingExtensions.h"
#import "SLFPersistenceManager.h"
#import "AppendingFlowCell.h"

@interface BillDetailViewController()
@property (nonatomic,retain) RKTableController *tableController;
@property (nonatomic,retain) IBOutlet UIButton *watchButton; 
- (id)initWithResourcePath:(NSString *)resourcePath;
- (RKTableViewCellMapping *)actionCellMap;
- (RKTableViewCellMapping *)sponsorCellMap;
- (RKTableViewCellMapping *)votesCellMap;
- (void)reconfigureForBill:(SLFBill *)bill;
- (void)configureActionBarForBill:(SLFBill *)bill;
- (UIButton *)configureWatchButton;
- (void)reconfigureWatchButtonForBill:(SLFBill *)bill;
- (void)configureTableItems;
- (void)configureBillInfoItems;
- (void)configureStages;
- (void)configureResources;
- (void)configureSubjects;
- (void)configureVotes;
- (void)configureSponsors;
- (void)configureActions;
- (void)addTableItems:(NSMutableArray *)tableItems fromWords:(NSSet *)words withType:(NSString *)type onSelectCell:(RKTableViewCellForObjectAtIndexPathBlock)onSelect;
- (void)addTableItems:(NSMutableArray *)tableItems fromWebAssets:(NSSet *)assets withType:(NSString *)type;
@end

@implementation BillDetailViewController
@synthesize bill = _bill;
@synthesize tableController = _tableController;
@synthesize watchButton = _watchButton;

- (id)initWithResourcePath:(NSString *)resourcePath {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.useTitleBar = YES;
        self.stackWidth = 500;
        RKLogDebug(@"Loading resource path for bill: %@", resourcePath);
        [[SLFRestKitManager sharedRestKit] loadObjectsAtResourcePath:resourcePath delegate:self withTimeout:SLF_HOURS_TO_SECONDS(1)];
    }
    return self;
}

- (id)initWithState:(SLFState *)aState session:(NSString *)aSession billID:(NSString *)billID {
    NSString *resourcePath = [BillSearchParameters pathForBill:billID state:aState.stateID session:aSession];
    self = [self initWithResourcePath:resourcePath];
    return self;
}

- (id)initWithBill:(SLFBill *)aBill {
    NSString *resourcePath = [BillSearchParameters pathForBill:aBill];
    self = [self initWithResourcePath:resourcePath];
    if (self) {
        self.bill = aBill;
    }
    return self;
}

- (void)dealloc {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
	self.bill = nil;
    self.tableController = nil;
    self.watchButton = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    self.tableController = nil;
    self.watchButton = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableController = [RKTableController tableControllerForTableViewController:(UITableViewController*)self];
    _tableController.delegate = self;
    _tableController.variableHeightRows = YES;
    _tableController.objectManager = [RKObjectManager sharedManager];
    _tableController.pullToRefreshEnabled = NO;
    [_tableController mapObjectsWithClass:[BillRecordVote class] toTableCellsWithMapping:[self votesCellMap]];
    [_tableController mapObjectsWithClass:[BillAction class] toTableCellsWithMapping:[self actionCellMap]];
    [_tableController mapObjectsWithClass:[BillSponsor class] toTableCellsWithMapping:[self sponsorCellMap]];    
    [self configureActionBarForBill:self.bill];
	self.title = NSLocalizedString(@"Loading...", @"");
}

- (NSString *)actionPath {
    return [[self class] actionPathForObject:self.bill];
}

- (void)reconfigureForBill:(SLFBill *)bill {
    if (bill) {
        self.bill = bill;
        self.title = bill.name;
    }
    if (!self.isViewLoaded)
        return;
    [self reconfigureWatchButtonForBill:bill];
    [self configureTableItems];
}

#pragma mark - Action Bar Header

- (void)setState:(BOOL)isOn forWatchButton:(UIButton *)button {
    static UIImage *buttonOff;
    if (!buttonOff)
        buttonOff = [[UIImage imageNamed:@"StarButtonOff"] retain];
    static UIImage *buttonOn;
    if (!buttonOn)
        buttonOn = [[UIImage imageNamed:@"StarButtonOn"] retain];
    button.tag = isOn;
    UIImage *normal = isOn ? buttonOn : buttonOff;
    [button setImage:normal forState:UIControlStateNormal];
    UIImage *highlighted = isOn ? buttonOff : buttonOn;;
    [button setImage:highlighted forState:UIControlStateHighlighted];
    [button setNeedsDisplay];
}

- (IBAction)toggleWatchButton:(id)sender {
    NSParameterAssert(sender != NULL && [sender isKindOfClass:[UIButton class]]);
    BOOL isFavorite = SLFBillIsWatched(_bill);
    [self setState:!isFavorite forWatchButton:sender];
    SLFSaveBillWatchedStatus(_bill, !isFavorite);
}

- (UIButton *)configureWatchButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    button.frame = CGRectMake(self.titleBarView.size.width - 50, 12, 43, 43);
    [button addTarget:self action:@selector(toggleWatchButton:) forControlEvents:UIControlEventTouchDown]; 
    return button;
}

- (void)reconfigureWatchButtonForBill:(SLFBill *)bill {
    _watchButton.enabled = (bill != NULL);
    [self setState:SLFBillIsWatched(bill) forWatchButton:_watchButton];
    if (!bill)
        return;
    SLFTouchBillWatchedStatus(_bill);
}

- (void)configureActionBarForBill:(SLFBill *)bill {
    self.watchButton = [self configureWatchButton];
    [self reconfigureWatchButtonForBill:bill];
    [self.titleBarView addSubview:_watchButton];
}

#pragma mark - Table Item Creation and Mapping

- (RKTableSection *)createSectionWithTitle:(NSString *)title {
    if (IsEmpty(title))
        return nil;
    RKTableSection *section = [_tableController sectionWithHeaderTitle:title];
    if (!section) {
        section = [RKTableSection sectionUsingBlock:^(RKTableSection *section) {
            TableSectionHeaderView *headerView = [[TableSectionHeaderView alloc] initWithTitle:title width:300.f];
            section.headerTitle = title;
            section.headerHeight = TableSectionHeaderViewDefaultHeight;
            section.headerView = headerView;
            [headerView release];
        }];
        [_tableController addSection:section];
    }
    return section;
}

- (void)configureTableItems {
    [_tableController removeAllSections:NO];
    [self configureBillInfoItems];     
    [self configureStages];
    [self configureResources];
    [self configureSubjects];
    [self configureVotes];
    [self configureSponsors];
    [self configureActions];
}

- (void)configureBillInfoItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    __block __typeof__(self) bself = self;
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [LargeStaticSubtitleCellMapping cellMapping];
        tableItem.text = bself.bill.billID;
        tableItem.detailText = bself.bill.title;
    }]];
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"Originating Chamber", @"");
        tableItem.detailText = bself.bill.chamberObj.formalName;
    }]];
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"Last Updated", @"");
        tableItem.detailText = [NSString stringWithFormat:NSLocalizedString(@"Bill info was updated %@",@""), [bself.bill.dateUpdated stringForDisplayWithPrefix:YES]];
    }]];
    NSArray *sortedActions = _bill.sortedActions;
    if (!IsEmpty(sortedActions)) {
        [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
            tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
            tableItem.text = NSLocalizedString(@"Latest Activity",@"");
            BillAction *latest = [sortedActions objectAtIndex:0];
            tableItem.detailText = [NSString stringWithFormat:@"%@ - %@", latest.title, latest.subtitle];
        }]];
    }
    [self createSectionWithTitle:NSLocalizedString(@"Bill Details",@"")];
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
    [tableItems release];
}

- (void)configureStages {
    NSArray *stages = _bill.stages;
    if (IsEmpty(stages))
        return;
    RKTableItem *stageItemCell = [RKTableItem tableItemUsingBlock:^(RKTableItem* tableItem) {
        AppendingFlowCellMapping *cellMap = [AppendingFlowCellMapping cellMapping];
        cellMap.stages = stages;
        tableItem.cellMapping = cellMap;
    }];
    NSArray *tableItems = [[NSArray alloc] initWithObjects:stageItemCell, nil];
    [self createSectionWithTitle:NSLocalizedString(@"Legislative Status (Beta)",@"")];
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
    [tableItems release];
}

- (void)configureSubjects {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    __block __typeof__(self) bself = self;
    RKTableViewCellForObjectAtIndexPathBlock onSelectBlock = ^(UITableViewCell *cell, id object, NSIndexPath *indexPath) {
        if (!object || ![object isKindOfClass:[RKTableItem class]])
            return;
        RKTableItem *item = object;
        NSString *word = item.text;
        if (IsEmpty(word))
            return;
        NSString *subjectPath = [BillSearchParameters pathForSubject:word state:bself.bill.stateID session:bself.bill.session chamber:nil];
        BillsViewController *vc = [[BillsViewController alloc] initWithState:bself.bill.stateObj resourcePath:subjectPath];
        vc.title = [NSString stringWithFormat:@"%@: %@", [bself.bill.stateID uppercaseString], word];
        [bself stackOrPushViewController:vc];
        [vc release];
    };
    [self addTableItems:tableItems fromWords:_bill.subjects withType:nil onSelectCell:onSelectBlock];
    [self createSectionWithTitle:NSLocalizedString(@"Subjects", @"")];
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
    [tableItems release];
}

- (void)configureResources {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    [self addTableItems:tableItems fromWebAssets:_bill.versions withType:NSLocalizedString(@"Version",@"")];
    [self addTableItems:tableItems fromWebAssets:_bill.documents withType:NSLocalizedString(@"Document",@"")];
    [self addTableItems:tableItems fromWebAssets:_bill.sources withType:NSLocalizedString(@"Resource",@"")];
    [self createSectionWithTitle:NSLocalizedString(@"Resources", @"")];
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
    [tableItems release];
}

- (void)configureSponsors {
    NSArray *tableItems = _bill.sortedSponsors;
    [self createSectionWithTitle:NSLocalizedString(@"Sponsors", @"")];
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadObjects:tableItems inSection:sectionIndex];
}

- (void)configureVotes {
    NSArray *tableItems = _bill.sortedVotes;
    [self createSectionWithTitle:NSLocalizedString(@"Votes", @"")];
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadObjects:tableItems inSection:sectionIndex];
}

- (void)configureActions {
    NSArray *tableItems = _bill.sortedActions;
    [self createSectionWithTitle:NSLocalizedString(@"Actions", @"")];
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadObjects:tableItems inSection:sectionIndex];
}

- (RKTableViewCellMapping *)actionCellMap {
    StaticSubtitleCellMapping *cellMap = [StaticSubtitleCellMapping cellMapping];
    [cellMap mapKeyPath:@"title" toAttribute:@"textLabel.text"];
    [cellMap mapKeyPath:@"subtitle" toAttribute:@"detailTextLabel.text"];
    return cellMap;
}

- (RKTableViewCellMapping *)sponsorCellMap {
    __block __typeof__(self) bself = self;
    FoundLegislatorCellMapping *cellMap = [FoundLegislatorCellMapping cellMappingUsingBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"foundLegislator" toAttribute:@"legislator"];
        [cellMapping mapKeyPath:@"type" toAttribute:@"role"];
        [cellMapping mapKeyPath:@"name" toAttribute:@"genericName"];
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            NSString *legID = [object valueForKey:@"legID"];
            NSString *path = [SLFActionPathNavigator navigationPathForController:[LegislatorDetailViewController class] withResourceID:legID];
            if (!IsEmpty(path))
                [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:bself popToRoot:NO];
        };
    }];
    return cellMap;
}

- (RKTableViewCellMapping *)votesCellMap {
    SubtitleCellMapping *cellMap = [SubtitleCellMapping cellMapping];
    [cellMap mapKeyPath:@"title" toAttribute:@"textLabel.text"];
    [cellMap mapKeyPath:@"subtitle" toAttribute:@"detailTextLabel.text"];
    __block __typeof__(self) bself = self;
    cellMap.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
        BillRecordVote *vote = object;
        BillVotesViewController *vc = [[BillVotesViewController alloc] initWithVote:vote];
        [bself stackOrPushViewController:vc];
        [vc release];
    };
    return cellMap;
}

- (void)addTableItems:(NSMutableArray *)tableItems fromWebAssets:(NSSet *)assets withType:(NSString *)type {
    if (IsEmpty(assets))
        return;
    NSArray *sorted = [assets sortedArrayUsingDescriptors:[GenericAsset sortDescriptors]];
    for (GenericAsset *source in sorted) {
        if (IsEmpty(source.url))
            continue;
        NSString *subtitle = source.name;
        if (IsEmpty(subtitle))
            subtitle = source.url;
        [tableItems addObject:[self webPageItemWithTitle:type subtitle:subtitle url:source.url]];
    }
}

- (void)addTableItems:(NSMutableArray *)tableItems fromWords:(NSSet *)words withType:(NSString *)type onSelectCell:(RKTableViewCellForObjectAtIndexPathBlock)onSelect {
    if (IsEmpty(words))
        return;
    NSArray *sorted = [words sortedArrayUsingDescriptors:[GenericWord sortDescriptors]];
    for (GenericWord *word in sorted) {
        if (IsEmpty(word.word))
            continue;
        RKTableViewCellMapping *cellMapping = [SubtitleCellMapping cellMapping];
        if (!onSelect)
            cellMapping = [StaticSubtitleCellMapping cellMapping];
        [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
            tableItem.cellMapping = cellMapping;
            if (!IsEmpty(type))
                tableItem.detailText = type;
            tableItem.text = [word.word capitalizedString];
            if (onSelect)
                tableItem.cellMapping.onSelectCellForObjectAtIndexPath = onSelect;
        }]];
    }
}

#pragma mark - Object Loader

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    self.title = NSLocalizedString(@"Load Error", @"");
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    SLFBill *bill = nil;
    if (object && [object isKindOfClass:[SLFBill class]]) {
        bill = object;
    }
    [self reconfigureForBill:bill];
    [self.tableView reloadData];
}

@end
