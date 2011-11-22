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
    //#import "DDActionHeaderView.h"
#import "SLFMappingsManager.h"
#import "SLFRestKitManager.h"
#import "SVWebViewController.h"
#import "SLFReachable.h"
#import "TableSectionHeaderView.h"
#import "NSDate+SLFDateHelper.h"
#import "LegislatorCell.h"

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
@property (nonatomic, retain) RKTableViewModel *tableViewModel;
- (id)initWithResourcePath:(NSString *)resourcePath;
- (void)loadDataFromNetworkWithResourcePath:(NSString *)resourcePath;
- (NSString *)headerForSectionIndex:(NSInteger)sectionIndex;
- (RKTableViewCellMapping *)actionCellMap;
- (RKTableViewCellMapping *)sponsorCellMap;
- (RKTableViewCellMapping *)votesCellMap;
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
@synthesize bill;
@synthesize tableViewModel = _tableViewModel;

- (id)initWithResourcePath:(NSString *)resourcePath {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.stackWidth = 500;
        RKLogDebug(@"Loading resource path for bill: %@", resourcePath);
        [self loadDataFromNetworkWithResourcePath:resourcePath];
    }
    return self;
}

- (id)initWithBillID:(NSString *)billID state:(SLFState *)aState session:(NSString *)aSession {
    NSString *resourcePath = [BillSearchParameters pathForBill:billID state:aState.stateID session:aSession];
    self = [self initWithResourcePath:resourcePath];
    return self;
}

- (id)initWithBill:(SLFBill *)aBill {
    NSString *resourcePath = [BillSearchParameters pathForBill:aBill];
    self = [self initWithResourcePath:resourcePath];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableViewModel = [RKTableViewModel tableViewModelForTableViewController:(UITableViewController*)self];
    self.tableViewModel.delegate = self;
    self.tableViewModel.variableHeightRows = YES;
    self.tableViewModel.objectManager = [RKObjectManager sharedManager];
    self.tableViewModel.pullToRefreshEnabled = NO;
    [self.tableViewModel mapObjectsWithClass:[BillRecordVote class] toTableCellsWithMapping:[self votesCellMap]];
    [self.tableViewModel mapObjectsWithClass:[BillAction class] toTableCellsWithMapping:[self actionCellMap]];
    [self.tableViewModel mapObjectsWithClass:[BillSponsor class] toTableCellsWithMapping:[self sponsorCellMap]];    
    NSInteger sectionIndex;
    for (sectionIndex = SectionBillInfo;sectionIndex < kNumSections; sectionIndex++) {
        [self.tableViewModel addSectionWithBlock:^(RKTableViewSection *section) {
            NSString *headerTitle = [self headerForSectionIndex:sectionIndex];
            TableSectionHeaderView *headerView = [[TableSectionHeaderView alloc] initWithTitle:headerTitle width:self.tableView.width];
            section.headerTitle = headerTitle;
            section.headerHeight = TableSectionHeaderViewDefaultHeight;
            section.headerView = headerView;
            [headerView release];
        }];
    }         
	self.title = NSLocalizedString(@"Loading...", @"");
}

- (void)dealloc {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
	self.bill = nil;
    self.tableViewModel = nil;
    [super dealloc];
}

- (void)loadDataFromNetworkWithResourcePath:(NSString *)resourcePath {
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:self block:^(RKObjectLoader* loader) {
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[SLFBill class]];
        loader.cacheTimeoutInterval = 1 * 60 * 60;
    }];
}

- (void)configureTableItems {
    [self configureBillInfoItems];     
    [self configureStages];
    [self configureResources];
    [self configureSubjects];
    [self configureVotes];
    [self configureSponsors];
    [self configureActions];
}

#pragma mark - Table Item Creation and Mapping

- (void)configureBillInfoItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.cellMapping.rowHeight = 90;
        tableItem.text = bill.billID;
        tableItem.detailText = bill.title;
        tableItem.cellMapping.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
            cell.textLabel.textColor = [SLFAppearance cellTextColor];
            cell.textLabel.font = SLFFont(15);
            cell.detailTextLabel.textColor = [SLFAppearance cellSecondaryTextColor];
            cell.detailTextLabel.font = SLFFont(12);
            SLFAlternateCellForIndexPath(cell, indexPath);
            cell.detailTextLabel.numberOfLines = 4;
            cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
        };
    }]];
    [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"Originating Chamber", @"");
        tableItem.detailText = self.bill.chamberObj.formalName;
    }]];
    [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"Last Updated", @"");
        tableItem.detailText = [NSString stringWithFormat:NSLocalizedString(@"Bill info was updated %@",@""), [bill.dateUpdated stringForDisplayWithPrefix:YES]];
    }]];
    NSArray *sortedActions = bill.sortedActions;
    if (!IsEmpty(sortedActions)) {
        [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
            tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
            tableItem.text = NSLocalizedString(@"Latest Activity",@"");
            BillAction *latest = [sortedActions objectAtIndex:0];
            tableItem.detailText = [NSString stringWithFormat:@"%@ - %@", latest.title, latest.subtitle];
        }]];
    }
    [self.tableViewModel loadTableItems:tableItems inSection:SectionBillInfo];     
    [tableItems release];
}

- (void)configureStages {
    NSArray *stages = bill.stages;
    if (IsEmpty(stages))
        return;
    RKTableItem *stageItemCell = [RKTableItem tableItemWithBlock:^(RKTableItem* tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        CGFloat rowHeight = PSIsIpad() ? 45 : 95;
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
    [self.tableViewModel loadTableItems:[NSArray arrayWithObjects:stageItemCell, emptyCell, nil] inSection:SectionStages];     
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
        NSString *subjectPath = [BillSearchParameters pathForSubject:word state:self.bill.stateID session:self.bill.session chamber:nil];
        BillsViewController *vc = [[BillsViewController alloc] initWithState:self.bill.stateObj resourcePath:subjectPath];
        vc.title = [NSString stringWithFormat:@"%@: %@", [self.bill.stateID uppercaseString], word];
        [self stackOrPushViewController:vc];
        [vc release];
    };
    [self addTableItems:tableItems fromWords:self.bill.subjects withType:nil onSelectCell:onSelectBlock];
    [self.tableViewModel loadTableItems:tableItems inSection:SectionSubjects];
    [tableItems release];
}

- (void)configureResources {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    [self addTableItems:tableItems fromWebAssets:self.bill.versions withType:NSLocalizedString(@"Version",@"")];
    [self addTableItems:tableItems fromWebAssets:self.bill.documents withType:NSLocalizedString(@"Document",@"")];
    [self addTableItems:tableItems fromWebAssets:self.bill.sources withType:NSLocalizedString(@"Resource",@"")];
    [self.tableViewModel loadTableItems:tableItems inSection:SectionResources];
    [tableItems release];
}

- (void)configureSponsors {
    [self.tableViewModel loadObjects:self.bill.sortedSponsors inSection:SectionSponsors];    
}

- (void)configureVotes {
    [self.tableViewModel loadObjects:self.bill.sortedVotes inSection:SectionVotes];    
}

- (void)configureActions {
    [self.tableViewModel loadObjects:self.bill.sortedActions inSection:SectionActions];    
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
    if (object && [object isKindOfClass:[SLFBill class]]) {
        self.bill = object;
        self.title = self.bill.name;
    }
    [self configureTableItems];
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

@end
