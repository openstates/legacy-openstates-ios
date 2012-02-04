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
#import "LegislatorDetailHeader.h"
#import "SLFEmailComposer.h"

@interface LegislatorDetailViewController()
@property (nonatomic, retain) RKTableController *tableController;
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
        self.title = legislator.formalName;
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
    __block __typeof__(self) bself = self;
    RKTableSection *headerSection = [RKTableSection sectionUsingBlock:^(RKTableSection *section) {
        CGRect headerRect = CGRectMake(0, 20, bself.tableView.width, 120);
        LegislatorDetailHeader *header = [[LegislatorDetailHeader alloc] initWithFrame:headerRect];
        section.headerView = header;
        section.headerHeight = 120;
        section.headerTitle = @"";
        header.legislator = bself.legislator;
        [header release];;
    }];
    [_tableController addSection:headerSection];
}

- (void)configureMemberInfoItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    __block __typeof__(self) bself = self;
    if (!IsEmpty(_legislator.email)) {
        [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
            tableItem.text = NSLocalizedString(@"Email", @"");
            tableItem.detailText = bself.legislator.email;
            tableItem.cellMapping = [StyledCellMapping styledMappingUsingBlock:^(StyledCellMapping* cellMapping) {
                cellMapping.style = UITableViewCellStyleSubtitle;
                cellMapping.onSelectCell = ^(void) {
                    [[SLFEmailComposer sharedComposer] presentMailComposerTo:bself.legislator.email subject:@"" body:@"" parent:bself];
                };
            }];
        }]];
    }
    if (!IsEmpty(_legislator.url))
        [tableItems addObject:[self webPageItemWithTitle:NSLocalizedString(@"Website", @"") subtitle:_legislator.url url:_legislator.url]];
    if (!IsEmpty(tableItems)) {
        SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"Contact Details", @""));
        NSUInteger sectionIndex = _tableController.sectionCount-1;
        [_tableController loadTableItems:tableItems inSection:sectionIndex];
    }
    [tableItems release];
}

- (void)configureDistrictMapItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    __block __typeof__(self) bself = self;
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        tableItem.text = NSLocalizedString(@"Map", @"");
        tableItem.text = bself.legislator.districtMapLabel;
        tableItem.cellMapping = [StyledCellMapping styledMappingUsingBlock:^(StyledCellMapping* cellMapping) {
            cellMapping.style = UITableViewCellStyleSubtitle;
            cellMapping.onSelectCell = ^(void) {
                NSString *path = [SLFActionPathNavigator navigationPathForController:[DistrictDetailViewController class] withResourceID:bself.legislator.districtID];
                if (!IsEmpty(path))
                    [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:bself popToRoot:NO];
            };
        }];
    }]];
    SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"District Map", @""));
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
    [tableItems release];
}

- (void)configureResourceItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    if (!IsEmpty(_legislator.votesmartID)) {
        NSString *url = [NSString stringWithFormat:@"http://votesmart.org/bio.php?can_id=%@", _legislator.votesmartID];
        [tableItems addObject:[self webPageItemWithTitle:NSLocalizedString(@"VoteSmart Bio", @"") subtitle:@"" url:url]];
    }
    if (!IsEmpty(_legislator.transparencyID)) {
		__block __typeof__(self) bself = self;
        [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
            tableItem.text = NSLocalizedString(@"Campaign Contributions", @"");
            tableItem.detailText = @"";
            tableItem.URL = @"";
            tableItem.cellMapping = [StyledCellMapping styledMappingUsingBlock:^(StyledCellMapping* cellMapping) {
                cellMapping.style = UITableViewCellStyleSubtitle;
                cellMapping.onSelectCell = ^(void) {
                    ContributionsViewController *controller = [[ContributionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    [controller setQueryEntityID:bself.legislator.transparencyID type:[NSNumber numberWithInteger:kContributionQueryRecipient] cycle:@"-1"];
                    [bself stackOrPushViewController:controller];
                    [controller release];
                };
            }];
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
    SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"Resources", @""));
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
    [tableItems release];
}

- (void)configureBillItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    __block __typeof__(self) bself = self;
    StyledCellMapping *cellMapping = [StyledCellMapping subtitleMapping];
    cellMapping.onSelectCell = ^(void) {
        NSString *selectedSession = SLFSelectedSessionForState(bself.legislator.state);
        NSString *resourcePath = [BillSearchParameters pathForSponsor:bself.legislator.legID state:bself.legislator.stateID session:selectedSession];
        BillsViewController *vc = [[BillsViewController alloc] initWithState:bself.legislator.state resourcePath:resourcePath];
        [bself stackOrPushViewController:vc];
        [vc release];
    };
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        tableItem.text = NSLocalizedString(@"Authored/Sponsored Bills", @"");
        NSString *selectedSession = SLFSelectedSessionForState(bself.legislator.state);
        NSString *displayName = IsEmpty(selectedSession) ? nil : [bself.legislator.state displayNameForSession:selectedSession];        
        tableItem.detailText = IsEmpty(displayName) ? @"" : displayName;
        tableItem.cellMapping = cellMapping;
    }]];
    SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"Legislation", @""));
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
    [tableItems release];
}


- (void)configureCommitteeItems {
    SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"Committees", @""));
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadObjects:_legislator.sortedRoles inSection:sectionIndex];
}

- (RKTableViewCellMapping *)committeeRoleCellMap {
    __block __typeof__(self) bself = self;
    StyledCellMapping *cellMapping = [StyledCellMapping subtitleMapping];
    [cellMapping mapKeyPath:@"name" toAttribute:@"textLabel.text"];
    [cellMapping mapKeyPath:@"type" toAttribute:@"detailTextLabel.text"];
    cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
        CommitteeRole *role = object;
        NSString *path = [SLFActionPathNavigator navigationPathForController:[CommitteeDetailViewController class] withResourceID:role.committeeID];
        if (!IsEmpty(path))
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:bself popToRoot:NO];
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
