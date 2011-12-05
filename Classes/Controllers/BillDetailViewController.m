//
//  BillDetailViewController.m
//  Created by Gregory Combs on 2/20/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
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
#import "AppendingFlowView.h"
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

enum SECTIONS {
    SectionBillInfo = 1,
    SectionStages,
    SectionResources,
    SectionSubjects,
    SectionVotes,
    SectionSponsors,
    SectionActions,
    kNumSections
};

@interface BillDetailViewController()
@property (nonatomic,retain) RKTableViewModel *tableViewModel;
@property (nonatomic,retain) IBOutlet UIButton *watchButton; 
- (id)initWithResourcePath:(NSString *)resourcePath;
- (NSString *)headerForSectionIndex:(NSInteger)sectionIndex;
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
@synthesize tableViewModel = _tableViewModel;
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
    self.tableViewModel = nil;
    self.watchButton = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    self.tableViewModel = nil;
    self.watchButton = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableViewModel = [RKTableViewModel tableViewModelForTableViewController:(UITableViewController*)self];
    _tableViewModel.delegate = self;
    _tableViewModel.variableHeightRows = YES;
    _tableViewModel.objectManager = [RKObjectManager sharedManager];
    _tableViewModel.pullToRefreshEnabled = NO;
    [_tableViewModel mapObjectsWithClass:[BillRecordVote class] toTableCellsWithMapping:[self votesCellMap]];
    [_tableViewModel mapObjectsWithClass:[BillAction class] toTableCellsWithMapping:[self actionCellMap]];
    [_tableViewModel mapObjectsWithClass:[BillSponsor class] toTableCellsWithMapping:[self sponsorCellMap]];    
    NSInteger sectionIndex;
    for (sectionIndex = SectionBillInfo;sectionIndex < kNumSections; sectionIndex++) {
        [_tableViewModel addSectionWithBlock:^(RKTableViewSection *section) {
            NSString *headerTitle = [self headerForSectionIndex:sectionIndex];
            TableSectionHeaderView *headerView = [[TableSectionHeaderView alloc] initWithTitle:headerTitle width:self.tableView.width];
            section.headerTitle = headerTitle;
            section.headerHeight = TableSectionHeaderViewDefaultHeight;
            section.headerView = headerView;
            [headerView release];
        }];
    }
    [self configureActionBarForBill:self.bill];
	self.title = NSLocalizedString(@"Loading...", @"");
}

- (NSString *)headerForSectionIndex:(NSInteger)sectionIndex {
    switch (sectionIndex) {
        case SectionBillInfo:
            return NSLocalizedString(@"Bill Details", @"");
        case SectionStages:
            return NSLocalizedString(@"Legislative Status (Beta)",@"");
        case SectionResources:
            return NSLocalizedString(@"Resources",@"");
        case SectionSubjects:
            return NSLocalizedString(@"Subjects", @"");
        case SectionVotes:
            return NSLocalizedString(@"Votes", @"");
        case SectionSponsors:
            return NSLocalizedString(@"Sponsors", @"");
        case SectionActions:
            return NSLocalizedString(@"Actions", @"");
        default:
            return @"";
    }
}

+ (NSString *)actionPathForBill:(SLFBill *)bill {
    if (!bill)
        return nil;
    return RKMakePathWithObjectAddingEscapes(@"slfos://bills/detail/:stateID/:session/:billID", bill, NO);
}

- (NSString *)actionPath {
    return [[self class] actionPathForBill:self.bill];
}

- (void)reconfigureForBill:(SLFBill *)bill {
    if (bill) {
        self.bill = bill;
        self.title = bill.name;
    }
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
        //button.enabled = (bill != NULL);
    [button addTarget:self action:@selector(toggleWatchButton:) forControlEvents:UIControlEventTouchDown]; 
    return button;
}

- (void)reconfigureWatchButtonForBill:(SLFBill *)bill {
    _watchButton.enabled = (bill != NULL);
    [self setState:SLFBillIsWatched(bill) forWatchButton:_watchButton];
    if (!bill)
        return;
    BOOL isWatched = SLFBillIsWatched(_bill);
    SLFSaveBillWatchedStatus(_bill, isWatched); // to reset the "last updated" date
}

- (void)configureActionBarForBill:(SLFBill *)bill {
    self.watchButton = [self configureWatchButton];
    [self reconfigureWatchButtonForBill:bill];
    [self.titleBarView addSubview:_watchButton];
}

#pragma mark - Table Item Creation and Mapping

- (void)configureTableItems {
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
    [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [LargeStaticSubtitleCellMapping cellMapping];
        tableItem.text = _bill.billID;
        tableItem.detailText = _bill.title;
    }]];
    [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"Originating Chamber", @"");
        tableItem.detailText = _bill.chamberObj.formalName;
    }]];
    [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"Last Updated", @"");
        tableItem.detailText = [NSString stringWithFormat:NSLocalizedString(@"Bill info was updated %@",@""), [_bill.dateUpdated stringForDisplayWithPrefix:YES]];
    }]];
    NSArray *sortedActions = _bill.sortedActions;
    if (!IsEmpty(sortedActions)) {
        [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
            tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
            tableItem.text = NSLocalizedString(@"Latest Activity",@"");
            BillAction *latest = [sortedActions objectAtIndex:0];
            tableItem.detailText = [NSString stringWithFormat:@"%@ - %@", latest.title, latest.subtitle];
        }]];
    }
    [_tableViewModel loadTableItems:tableItems inSection:SectionBillInfo];     
    [tableItems release];
}

- (void)configureStages {
    NSArray *stages = _bill.stages;
    if (IsEmpty(stages))
        return;
    RKTableItem *stageItemCell = [RKTableItem tableItemWithBlock:^(RKTableItem* tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        CGFloat rowHeight = SLFIsIpad() ? 45 : 95;
        tableItem.cellMapping.rowHeight = rowHeight;
        tableItem.cellMapping.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
            AppendingFlowView *appendingFlow = [[AppendingFlowView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), rowHeight)];
            appendingFlow.uniformWidth = NO;
            appendingFlow.preferredBoxSize = CGSizeMake(78.f, 40.f);    
            appendingFlow.connectorSize = CGSizeMake(7.f, 6.f); 
            appendingFlow.font = SLFFont(12);
            appendingFlow.insetMargin = CGSizeMake(1.f, 10.f);
            appendingFlow.stages = stages;
            cell.backgroundView = appendingFlow;
            [appendingFlow release];
        };
    }];
    RKTableItem *emptyCell = [RKTableItem tableItemWithBlock:^(RKTableItem* tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.cellMapping.rowHeight = 5;
        tableItem.cellMapping.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
            UIView *empty = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 5)];
            empty.backgroundColor = [UIColor clearColor];
            cell.backgroundView = empty;
            [empty release];
        };
    }];
    [_tableViewModel loadTableItems:[NSArray arrayWithObjects:stageItemCell, emptyCell, nil] inSection:SectionStages];     
}

- (void)configureSubjects {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    RKTableViewCellForObjectAtIndexPathBlock onSelectBlock = ^(UITableViewCell *cell, id object, NSIndexPath *indexPath) {
        if (!object || ![object isKindOfClass:[RKTableItem class]])
            return;
        RKTableItem *item = object;
        NSString *word = item.text;
        if (IsEmpty(word))
            return;
        NSString *subjectPath = [BillSearchParameters pathForSubject:word state:_bill.stateID session:_bill.session chamber:nil];
        BillsViewController *vc = [[BillsViewController alloc] initWithState:_bill.stateObj resourcePath:subjectPath];
        vc.title = [NSString stringWithFormat:@"%@: %@", [_bill.stateID uppercaseString], word];
        [self stackOrPushViewController:vc];
        [vc release];
    };
    [self addTableItems:tableItems fromWords:_bill.subjects withType:nil onSelectCell:onSelectBlock];
    [_tableViewModel loadTableItems:tableItems inSection:SectionSubjects];
    [tableItems release];
}

- (void)configureResources {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    [self addTableItems:tableItems fromWebAssets:_bill.versions withType:NSLocalizedString(@"Version",@"")];
    [self addTableItems:tableItems fromWebAssets:_bill.documents withType:NSLocalizedString(@"Document",@"")];
    [self addTableItems:tableItems fromWebAssets:_bill.sources withType:NSLocalizedString(@"Resource",@"")];
    [_tableViewModel loadTableItems:tableItems inSection:SectionResources];
    [tableItems release];
}

- (void)configureSponsors {
    [_tableViewModel loadObjects:_bill.sortedSponsors inSection:SectionSponsors];    
}

- (void)configureVotes {
    [_tableViewModel loadObjects:_bill.sortedVotes inSection:SectionVotes];    
}

- (void)configureActions {
    [_tableViewModel loadObjects:_bill.sortedActions inSection:SectionActions];    
}

- (RKTableViewCellMapping *)actionCellMap {
    StaticSubtitleCellMapping *cellMap = [StaticSubtitleCellMapping cellMapping];
    [cellMap mapKeyPath:@"title" toAttribute:@"textLabel.text"];
    [cellMap mapKeyPath:@"subtitle" toAttribute:@"detailTextLabel.text"];
    return cellMap;
}

- (RKTableViewCellMapping *)sponsorCellMap {
    FoundLegislatorCellMapping *cellMap = [FoundLegislatorCellMapping cellMappingWithBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"foundLegislator" toAttribute:@"legislator"];
        [cellMapping mapKeyPath:@"type" toAttribute:@"role"];
        [cellMapping mapKeyPath:@"name" toAttribute:@"genericName"];
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            NSString *legID = [object valueForKey:@"legID"];
            LegislatorDetailViewController *vc = [[LegislatorDetailViewController alloc] initWithLegislatorID:legID];
            [self stackOrPushViewController:vc];
            [vc release];
        };
    }];
    return cellMap;
}

- (RKTableViewCellMapping *)votesCellMap {
    SubtitleCellMapping *cellMap = [SubtitleCellMapping cellMapping];
    [cellMap mapKeyPath:@"title" toAttribute:@"textLabel.text"];
    [cellMap mapKeyPath:@"subtitle" toAttribute:@"detailTextLabel.text"];
    cellMap.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
        BillRecordVote *vote = object;
        BillVotesViewController *vc = [[BillVotesViewController alloc] initWithVote:vote];
        [self stackOrPushViewController:vc];
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
        [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
            tableItem.cellMapping = cellMapping;
            if (!IsEmpty(type))
                tableItem.detailText = type;
            tableItem.text = [word.word capitalizedString];
            if (onSelect)
                tableItem.cellMapping.onSelectCell = onSelect;
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
}

@end
