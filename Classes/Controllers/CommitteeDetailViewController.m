//
//  CommitteeDetailViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "CommitteeDetailViewController.h"
#import "LegislatorDetailViewController.h"
#import "SLFDataModels.h"
#import "SLFMappingsManager.h"
#import "SLFRestKitManager.h"
#import "SLFReachable.h"
#import "SVWebViewController.h"
#import "TableSectionHeaderView.h"
#import "LegislatorCell.h"
#import "GenericDetailHeader.h"

#define SectionHeaderCommitteeInfo NSLocalizedString(@"Committee Details", @"")
#define SectionHeaderMembers NSLocalizedString(@"Members", @"")

@interface CommitteeDetailViewController()
@property (nonatomic, retain) RKTableController *tableController;
- (void)configureTableController;
- (void)configureTableItems;
- (void)configureResourceItems;
- (void)configureMemberItems;
- (void)configureTableHeader;
- (void)loadDataFromNetworkWithID:(NSString *)resourceID;
- (RKTableViewCellMapping *)committeeMemberCellMap;
@end

@implementation CommitteeDetailViewController
@synthesize committee = _committee;
@synthesize tableController = _tableController;

- (id)initWithCommitteeID:(NSString *)committeeID {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [self loadDataFromNetworkWithID:committeeID];
    }
    return self;
}

- (void)dealloc {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
	self.committee = nil;
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
    [self configureTableController];
	self.title = NSLocalizedString(@"Loading...", @"");
}

- (NSString *)actionPath {
    return [[self class] actionPathForObject:self.committee];
}

- (void)reconfigureForCommittee:(SLFCommittee *)committee {
    if (committee) {
        self.committee = committee;
        self.title = committee.committeeName;
    }
    [self configureTableItems];
}

- (void)loadDataFromNetworkWithID:(NSString *)resourceID {
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY,@"apikey", resourceID, @"committeeID", nil];
    NSString *resourcePath = RKMakePathWithObject(@"/committees/:committeeID?apikey=:apikey", queryParams);
    [[SLFRestKitManager sharedRestKit] loadObjectsAtResourcePath:resourcePath delegate:self withTimeout:SLF_HOURS_TO_SECONDS(24)];
}

- (void)configureTableController {
    self.tableController = [RKTableController tableControllerForTableViewController:(UITableViewController*)self];
    _tableController.delegate = self;
    _tableController.objectManager = [RKObjectManager sharedManager];
    _tableController.pullToRefreshEnabled = NO;
    _tableController.variableHeightRows = YES;
    [_tableController mapObjectsWithClass:[CommitteeMember class] toTableCellsWithMapping:[self committeeMemberCellMap]];
}

- (void)configureTableItems {
    [_tableController removeAllSections:NO];
    [self configureTableHeader];
    [self configureResourceItems];
    [self configureMemberItems];
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

- (void)configureTableHeader {
    RKTableSection *headerSection = [RKTableSection sectionUsingBlock:^(RKTableSection *section) {
        GenericDetailHeader *header = [[GenericDetailHeader alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 100)];
        header.defaultSize = CGSizeMake(self.tableView.width, 100);
        section.headerTitle = @"";
        header.title = _committee.committeeName;
        header.subtitle = _committee.chamberObj.name;
        header.detail = _committee.subcommittee;
        [header configure];
        section.headerHeight = header.height;
        section.headerView = header;
        [header release];
    }];
    [_tableController insertSection:headerSection atIndex:0];
}

- (void)configureResourceItems {
    if (IsEmpty(_committee.sources))
        return;
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    for (GenericAsset *source in _committee.sources) {
        NSString *subtitle = source.name;
        if (IsEmpty(subtitle))
            subtitle = source.url;
        [tableItems addObject:[self webPageItemWithTitle:NSLocalizedString(@"Web Site", @"") subtitle:subtitle url:source.url]];
    }
    [self createSectionWithTitle:NSLocalizedString(@"Resources", @"")];
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
    [tableItems release];
}

- (void)configureMemberItems {
    if (IsEmpty(_committee.members))
        return;
    [self createSectionWithTitle:NSLocalizedString(@"Members", @"")];
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadObjects:_committee.sortedMembers inSection:sectionIndex];
}

- (RKTableViewCellMapping *)committeeMemberCellMap {
    FoundLegislatorCellMapping *cellMap = [FoundLegislatorCellMapping cellMappingUsingBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"foundLegislator" toAttribute:@"legislator"];
        [cellMapping mapKeyPath:@"type" toAttribute:@"role"];
        [cellMapping mapKeyPath:@"name" toAttribute:@"genericName"];
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            NSString *legID = [object valueForKey:@"legID"];
            NSString *path = [SLFActionPathNavigator navigationPathForController:[LegislatorDetailViewController class] withResourceID:legID];
            if (!IsEmpty(path))
                [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:self popToRoot:NO];
        };
    }];
    return cellMap;
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    SLFCommittee *committee = nil;
    if (object && [object isKindOfClass:[SLFCommittee class]])
        committee = object;
    [self reconfigureForCommittee:committee];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    self.title = NSLocalizedString(@"Load Error",@"");
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
}

@end
