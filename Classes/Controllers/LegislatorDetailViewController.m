//
//  LegislatorDetailViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


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
#import "SLFReachable.h"
#import "ContributionsViewController.h"
#import "LegislatorDetailHeader.h"
#import "SLFEmailComposer.h"
#import "SLFImprovedRKTableController.h"

@interface LegislatorDetailViewController()

@property (nonatomic, strong) SLFImprovedRKTableController *tableController;

- (void)loadDataFromNetworkWithID:(NSString *)resourceID;
- (RKTableViewCellMapping *)committeeRoleCellMap;
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
}

- (void)viewDidUnload {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    self.tableController = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableController = [SLFImprovedRKTableController tableControllerForTableViewController:(UITableViewController*)self];
    _tableController.delegate = self;
    _tableController.variableHeightRows = YES;
    _tableController.objectManager = [RKObjectManager sharedManager];
    _tableController.pullToRefreshEnabled = NO;
    [_tableController mapObjectsWithClass:[CommitteeRole class] toTableCellsWithMapping:[self committeeRoleCellMap]];
	self.title = NSLocalizedString(@"Loading...", @"");
    self.screenName = @"Legislator Detail Screen";
}

- (NSString *)actionPath {
    return [[self class] actionPathForObject:self.legislator];
}

- (void)reconfigureForLegislator:(SLFLegislator *)legislator {
    if (legislator) {
        self.legislator = legislator;
        self.title = legislator.formalName;
    }
    [self configureTableItems];
}

- (void)loadDataFromNetworkWithID:(NSString *)resourceID {
    if (!SLFTypeNonEmptyStringOrNil(resourceID))
        return;
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY,@"apikey", resourceID, @"legislatorID", nil];
    NSString *resourcePath = RKMakePathWithObject(@"/legislators/:legislatorID?apikey=:apikey", queryParams);
    [[SLFRestKitManager sharedRestKit] loadObjectsAtResourcePath:resourcePath delegate:self withTimeout:SLF_HOURS_TO_SECONDS(24)];
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
    __weak __typeof__(self) wSelf = self;
    RKTableSection *headerSection = [RKTableSection sectionUsingBlock:^(RKTableSection *section) {
        CGRect headerRect = CGRectMake(0, 20, wSelf.tableView.width, 120);
        LegislatorDetailHeader *header = [[LegislatorDetailHeader alloc] initWithFrame:headerRect];
        section.headerView = header;
        section.headerHeight = 120;
        section.headerTitle = @"";
        header.legislator = wSelf.legislator;
        ;
    }];
    [_tableController addSection:headerSection];
}

- (void)configureMemberInfoItems
{
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    __weak __typeof__(self) wSelf = self;
    if (SLFTypeNonEmptyStringOrNil(_legislator.email)) {
        [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
            if (!wSelf)
                return;
            __strong __typeof__(wSelf) sSelf = wSelf;

            tableItem.text = NSLocalizedString(@"Email", @"");
            tableItem.detailText = wSelf.legislator.email;

            __weak __typeof__(sSelf) wSelf = sSelf;

            tableItem.cellMapping = [StyledCellMapping styledMappingUsingBlock:^(StyledCellMapping* cellMapping) {
                if (!wSelf)
                    return;
                __strong __typeof__(wSelf) sSelf = wSelf;

                cellMapping.style = UITableViewCellStyleSubtitle;

                __weak __typeof__(sSelf) wSelf = sSelf;
                cellMapping.onSelectCell = ^(void) {
                    if (!wSelf)
                        return;
                    __strong __typeof__(wSelf) sSelf = wSelf;
                    [[SLFEmailComposer sharedComposer] presentMailComposerTo:sSelf.legislator.email subject:@"" body:@"" parent:wSelf];
                };
            }];
        }]];
    }
    if (SLFTypeNonEmptyStringOrNil(_legislator.url))
    {
        RKTableItem *webPageItem = [self webPageItemWithTitle:NSLocalizedString(@"Website", @"") subtitle:_legislator.url url:_legislator.url];
        if (webPageItem)
            [tableItems addObject:webPageItem];
    }
    if (tableItems.count) {
        SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"Contact Details", @""));
        NSUInteger sectionIndex = _tableController.sectionCount-1;
        [_tableController loadTableItems:tableItems inSection:sectionIndex];
    }
}

- (void)configureDistrictMapItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    __weak __typeof__(self) wSelf = self;
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        if (!wSelf)
            return;
        __strong __typeof__(wSelf) sSelf = wSelf;

        tableItem.text = NSLocalizedString(@"Map", @"");
        tableItem.text = sSelf.legislator.districtMapLabel;

        __weak __typeof__(sSelf) wSelf = sSelf;
        tableItem.cellMapping = [StyledCellMapping styledMappingUsingBlock:^(StyledCellMapping* cellMapping) {
            if (!wSelf)
                return;
            __strong __typeof__(wSelf) sSelf = wSelf;
            cellMapping.style = UITableViewCellStyleSubtitle;

            __weak __typeof__(sSelf) wSelf = sSelf;
            cellMapping.onSelectCell = ^(void) {
                if (!wSelf)
                    return;
                __strong __typeof__(wSelf) sSelf = wSelf;
                NSString *path = [SLFActionPathNavigator navigationPathForController:[DistrictDetailViewController class] withResourceID:sSelf.legislator.districtID];
                if (SLFTypeNonEmptyStringOrNil(path))
                    [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:sSelf popToRoot:NO];
            };
        }];
    }]];
    SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"District Map", @""));
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
}

- (void)configureResourceItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    if (SLFTypeNonEmptyStringOrNil(_legislator.votesmartID)) {
        NSString *url = [NSString stringWithFormat:@"http://votesmart.org/bio.php?can_id=%@", _legislator.votesmartID];
        [tableItems addObject:[self webPageItemWithTitle:NSLocalizedString(@"VoteSmart Bio", @"") subtitle:@"" url:url]];
    }
    if (SLFTypeNonEmptyStringOrNil(_legislator.transparencyID)) {
        __weak __typeof__(self) wSelf = self;
        [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
            if (!wSelf)
                return;
            __strong __typeof__(wSelf) sSelf = wSelf;
            tableItem.text = NSLocalizedString(@"Campaign Contributions", @"");
            tableItem.detailText = @"";
            tableItem.URL = @"";
            __weak __typeof__(sSelf) wSelf = sSelf;
            tableItem.cellMapping = [StyledCellMapping styledMappingUsingBlock:^(StyledCellMapping* cellMapping) {
                cellMapping.style = UITableViewCellStyleSubtitle;
                cellMapping.onSelectCell = ^(void) {
                    if (!wSelf)
                        return;
                    __strong __typeof__(wSelf) sSelf = wSelf;
                    ContributionsViewController *controller = [[ContributionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    [controller setQueryEntityID:sSelf.legislator.transparencyID type:@(kContributionQueryRecipient) cycle:@"-1"];
                    [sSelf stackOrPushViewController:controller];
                };
            }];
        }]];
    }
    if (SLFTypeNonEmptyStringOrNil(_legislator.nimspID)) {
        NSString *url = [NSString stringWithFormat:@"http://www.followthemoney.org/database/uniquecandidate.phtml?uc=%@", _legislator.nimspID];
        RKTableItem *webPageItem = [self webPageItemWithTitle:NSLocalizedString(@"Follow The Money Summary", @"") subtitle:@"" url:url];
        if (webPageItem)
            [tableItems addObject:webPageItem];
    }
    for (GenericAsset *source in _legislator.sources) {
        NSString *subtitle = source.name;
        if (!SLFTypeNonEmptyStringOrNil(subtitle))
            subtitle = source.url;
        RKTableItem *webPageItem = [self webPageItemWithTitle:NSLocalizedString(@"Web Resource", @"") subtitle:subtitle url:source.url];
        if (webPageItem)
            [tableItems addObject:webPageItem];
    }
    SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"Resources", @""));
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
}

- (void)configureBillItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    __weak __typeof__(self) wSelf = self;
    StyledCellMapping *cellMapping = [StyledCellMapping subtitleMapping];
    cellMapping.onSelectCell = ^(void) {
        if (!wSelf)
            return;
        NSString *selectedSession = SLFSelectedSessionForState(wSelf.legislator.state);
        NSString *resourcePath = [BillSearchParameters pathForSponsor:wSelf.legislator.legID state:wSelf.legislator.stateID session:selectedSession];
        BillsViewController *vc = [[BillsViewController alloc] initWithState:wSelf.legislator.state resourcePath:resourcePath];
        [wSelf stackOrPushViewController:vc];
    };
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        if (!wSelf)
            return;
        tableItem.text = NSLocalizedString(@"Authored/Sponsored Bills", @"");
        NSString *selectedSession = SLFSelectedSessionForState(wSelf.legislator.state);
        NSString *displayName = (!selectedSession) ? @"" : [wSelf.legislator.state displayNameForSession:selectedSession];
        tableItem.detailText = displayName;
        tableItem.cellMapping = cellMapping;
    }]];
    SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"Legislation", @""));
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
}


- (void)configureCommitteeItems {
    SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"Committees", @""));
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadObjects:_legislator.sortedRoles inSection:sectionIndex];
}

- (RKTableViewCellMapping *)committeeRoleCellMap {
    __weak __typeof__(self) wSelf = self;
    StyledCellMapping *cellMapping = [StyledCellMapping subtitleMapping];
    [cellMapping mapKeyPath:@"name" toAttribute:@"textLabel.text"];
    [cellMapping mapKeyPath:@"type" toAttribute:@"detailTextLabel.text"];
    cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
        if (!wSelf)
            return;
        __strong __typeof__(wSelf) sSelf = wSelf;
        CommitteeRole *role = object;
        NSString *path = [SLFActionPathNavigator navigationPathForController:[CommitteeDetailViewController class] withResourceID:role.committeeID];
        if (SLFTypeNonEmptyStringOrNil(path))
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:sSelf popToRoot:NO];
    };
    return cellMapping;
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
