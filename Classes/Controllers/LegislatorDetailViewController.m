//
//  LegislatorDetailViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LegislatorDetailViewController.h"
#import "SLFDataModels.h"
#import "SLFMappingsManager.h"
#import "SLFRestKitManager.h"
#import "CommitteeDetailViewController.h"
#import "DistrictDetailViewController.h"
#import "BillSearchParameters.h"
#import "BillsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+RoundedCorners.h"
#import "SVWebViewController.h"
#import "SLFReachable.h"
#import "ContributionsViewController.h"
#import "TableSectionHeaderView.h"
#import "LegislatorDetailHeader.h"
#import "SLFEmailComposer.h"

@interface LegislatorDetailViewController()
@property (nonatomic, retain) RKTableController *tableController;
- (void)loadDataFromNetworkWithID:(NSString *)resourceID;
- (SubtitleCellMapping *)committeeRoleCellMap;
- (void)configureTableItems;
- (void)configureMemberInfoItems;
- (void)configureDistrictMapItems;
- (void)configureResourceItems;
- (void)configureCommitteeItems;
- (void)configureBillItems;
- (void)configureTableHeader;
@end

@implementation LegislatorDetailViewController
@synthesize legislator = _legislator;
@synthesize tableController = _tableController;

- (id)initWithLegislatorID:(NSString *)legislatorID {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [self loadDataFromNetworkWithID:legislatorID];
    }
    return self;
}

- (void)dealloc {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
	self.legislator = nil;
    self.tableController = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    self.tableController = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableController = [RKTableController tableControllerForTableViewController:(UITableViewController*)self];
    _tableController.delegate = self;
    _tableController.variableHeightRows = YES;
    _tableController.objectManager = [RKObjectManager sharedManager];
    _tableController.pullToRefreshEnabled = NO;
    [_tableController mapObjectsWithClass:[CommitteeRole class] toTableCellsWithMapping:[self committeeRoleCellMap]];
	self.title = NSLocalizedString(@"Loading...", @"");
}

- (NSString *)actionPath {
    return [[self class] actionPathForObject:self.legislator];
}

- (void)reconfigureForLegislator:(SLFLegislator *)legislator {
    if (legislator) {
        self.legislator = legislator;
        self.title = self.legislator.formalName;
    }
    [self configureTableItems];
}

- (void)loadDataFromNetworkWithID:(NSString *)resourceID {
    if (IsEmpty(resourceID))
        return;
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY,@"apikey", resourceID, @"legislatorID", nil];
    NSString *resourcePath = RKMakePathWithObject(@"/legislators/:legislatorID?apikey=:apikey", queryParams);
    [[SLFRestKitManager sharedRestKit] loadObjectsAtResourcePath:resourcePath delegate:self withTimeout:SLF_HOURS_TO_SECONDS(24)];
}

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
    [self configureTableHeader];
    [self configureMemberInfoItems];     
    [self configureDistrictMapItems];
    [self configureResourceItems];
    [self configureCommitteeItems];
    [self configureBillItems];
}

- (void)configureTableHeader {
    RKTableSection *headerSection = [RKTableSection sectionUsingBlock:^(RKTableSection *section) {
        CGRect headerRect = CGRectMake(0, 20, self.tableView.width, 120);
        LegislatorDetailHeader *header = [[LegislatorDetailHeader alloc] initWithFrame:headerRect];
        section.headerView = header;
        section.headerHeight = 120;
        section.headerTitle = @"";
        header.legislator = self.legislator;
        [header release];;
    }];
    [_tableController insertSection:headerSection atIndex:0];
}

- (void)configureMemberInfoItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"Chamber", @"");
        tableItem.detailText = _legislator.chamberObj.formalName;
    }]];
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = [NSString stringWithFormat:@"%@ %@", _legislator.title, NSLocalizedString(@"Term", @"")];
        tableItem.detailText = _legislator.term;
    }]];
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"Party", @"");
        tableItem.detailText = _legislator.partyObj.name;
    }]];
    if (!IsEmpty(_legislator.email)) {
        [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
            tableItem.cellMapping = [SubtitleCellMapping cellMapping];
            tableItem.text = NSLocalizedString(@"Email", @"");
            tableItem.detailText = _legislator.email;
            tableItem.cellMapping.onSelectCell = ^(void) {
                [[SLFEmailComposer sharedComposer] presentMailComposerTo:_legislator.email subject:@"" body:@"" parent:self];
            };
        }]];
    }
    if (!IsEmpty(_legislator.url)) {
        [tableItems addObject:[self webPageItemWithTitle:NSLocalizedString(@"Website", @"") subtitle:_legislator.url url:_legislator.url]];
    }
    [self createSectionWithTitle:NSLocalizedString(@"Member Details", @"")];
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
    [tableItems release];
}

- (void)configureDistrictMapItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"District", @"");
        tableItem.detailText = _legislator.district;
    }]];
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [SubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"Map", @"");
        tableItem.detailText = _legislator.districtMapLabel;
        tableItem.cellMapping.onSelectCell = ^(void) {
            NSString *path = [SLFActionPathNavigator navigationPathForController:[DistrictDetailViewController class] withResourceID:_legislator.districtID];
            if (!IsEmpty(path))
                [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:self popToRoot:NO];
        };
    }]];
    [self createSectionWithTitle:NSLocalizedString(@"District Map", @"")];
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
    [tableItems release];
}

- (void)configureResourceItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    if (!IsEmpty(_legislator.votesmartID)) {
        NSString *url = [NSString stringWithFormat:@"http://votesmart.org/bio.php?can_id=%@", _legislator.votesmartID];
        [tableItems addObject:[self webPageItemWithTitle:NSLocalizedString(@"Vote Smart Bio", @"") subtitle:@"" url:url]];
    }
    if (!IsEmpty(_legislator.transparencyID)) {
        [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
            tableItem.cellMapping = [SubtitleCellMapping cellMapping];
            tableItem.text = NSLocalizedString(@"Campaign Contributions", @"");
            tableItem.detailText = @"";
            tableItem.URL = @"";
            tableItem.cellMapping.onSelectCell = ^(void) {
                ContributionsViewController *controller = [[ContributionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                [controller setQueryEntityID:_legislator.transparencyID type:[NSNumber numberWithInteger:kContributionQueryRecipient] cycle:@"-1"];
                [self stackOrPushViewController:controller];
                [controller release];
            };
        }]];
    }
    if (!IsEmpty(_legislator.nimspID)) {
        NSString *url = [NSString stringWithFormat:@"http://www.followthemoney.org/database/uniquecandidate.phtml?uc=%@", _legislator.nimspID];
        [tableItems addObject:[self webPageItemWithTitle:NSLocalizedString(@"Follow The Money Summary", @"") subtitle:@"" url:url]];
    }
    for (GenericAsset *source in _legislator.sources) {
        NSString *subtitle = source.name;
        if (IsEmpty(subtitle))
            subtitle = source.url;
        [tableItems addObject:[self webPageItemWithTitle:NSLocalizedString(@"Web Resource", @"") subtitle:subtitle url:source.url]];
    }
    [self createSectionWithTitle:NSLocalizedString(@"Resources", @"")];
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
    [tableItems release];
}

- (void)configureBillItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [SubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"Authored/Sponsored Bills", @"");
        NSString *selectedSession = SLFSelectedSessionForState(_legislator.state);
        tableItem.detailText = [_legislator.state displayNameForSession:selectedSession];
        tableItem.cellMapping.onSelectCell = ^(void) {
            NSString *resourcePath = [BillSearchParameters pathForSponsor:_legislator.legID state:_legislator.stateID session:selectedSession];
            BillsViewController *vc = [[BillsViewController alloc] initWithState:_legislator.state resourcePath:resourcePath];
            [self stackOrPushViewController:vc];
            [vc release];
        };
    }]];
    [self createSectionWithTitle:NSLocalizedString(@"Legislation", @"")];
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
    [tableItems release];
}


- (void)configureCommitteeItems {
    [self createSectionWithTitle:NSLocalizedString(@"Committees", @"")];
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadObjects:_legislator.sortedRoles inSection:sectionIndex];
}

- (SubtitleCellMapping *)committeeRoleCellMap {
    SubtitleCellMapping *roleCellMap = [SubtitleCellMapping cellMapping];
    [roleCellMap mapKeyPath:@"name" toAttribute:@"textLabel.text"];
    [roleCellMap mapKeyPath:@"type" toAttribute:@"detailTextLabel.text"];
    roleCellMap.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
        CommitteeRole *role = object;
        NSString *path = [SLFActionPathNavigator navigationPathForController:[CommitteeDetailViewController class] withResourceID:role.committeeID];
        if (!IsEmpty(path))
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:self popToRoot:NO];
    };
    return roleCellMap;
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    self.title = NSLocalizedString(@"Load Error", @"");
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    SLFLegislator *legislator = nil;
    if (object && [object isKindOfClass:[SLFLegislator class]])
        legislator = object;
    [self reconfigureForLegislator:legislator];
}

@end
