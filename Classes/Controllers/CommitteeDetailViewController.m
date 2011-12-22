//
//  CommitteeDetailViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
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
#define SectionHeaderResources NSLocalizedString(@"Resources", @"")

enum SECTIONS {
    SectionHeader = 0,
//  SectionCommitteeInfo = 1,
    SectionResources,
    SectionMembers,
    kNumSections
};

@interface CommitteeDetailViewController()
@property (nonatomic, retain) RKTableController *tableController;
- (void)configureTableController;
- (void)configureTableItems;
- (void)configureCommitteeInfoItems;
- (void)configureResourceItems;
- (void)configureMemberItems;
- (void)configureTableHeader;
- (void)loadDataFromNetworkWithID:(NSString *)resourceID;
- (NSString *)headerForSectionIndex:(NSInteger)sectionIndex;
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
    NSInteger sectionIndex;
    for (sectionIndex = 1;sectionIndex < kNumSections; sectionIndex++) {
        [_tableController addSectionUsingBlock:^(RKTableSection *section) {
            NSString *headerTitle = [self headerForSectionIndex:sectionIndex];
            TableSectionHeaderView *sectionView = [[TableSectionHeaderView alloc] initWithTitle:headerTitle width:self.tableView.width];
            section.headerTitle = headerTitle;
            section.headerHeight = TableSectionHeaderViewDefaultHeight;
            section.headerView = sectionView;
            [sectionView release];
        }];
    }         
}

- (void)configureTableItems {
    [self configureCommitteeInfoItems];
    [self configureResourceItems];
    [self configureMemberItems];
    [self configureTableHeader];
}

- (void)configureTableHeader {
    RKTableSection *headerSection = [RKTableSection sectionUsingBlock:^(RKTableSection *section) {
        GenericDetailHeader *header = [[GenericDetailHeader alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 100)];
        section.headerHeight = header.height;
        section.headerView = header;
        section.headerTitle = @"";
        header.title = _committee.committeeName;
        header.subtitle = _committee.chamberObj.name;
        header.detail = _committee.subcommittee;
        [header release];;
    }];
    [_tableController insertSection:headerSection atIndex:SectionHeader];
}

- (void)configureCommitteeInfoItems {
    // Nothing at this time.    
}

- (void)configureResourceItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    for (GenericAsset *source in _committee.sources) {
        NSString *subtitle = source.name;
        if (IsEmpty(subtitle))
            subtitle = source.url;
        [tableItems addObject:[self webPageItemWithTitle:NSLocalizedString(@"Web Site", @"") subtitle:subtitle url:source.url]];
    }
    [_tableController loadTableItems:tableItems inSection:SectionResources];
    [tableItems release];
}

- (void)configureMemberItems {
    [_tableController loadObjects:_committee.sortedMembers inSection:SectionMembers];    
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

- (NSString *)headerForSectionIndex:(NSInteger)sectionIndex {
    switch (sectionIndex) {
        case SectionHeader:
            return @"";
        case SectionResources:
            return SectionHeaderResources;
        case SectionMembers:
            return SectionHeaderMembers;
        default:
            return @"";
    }
}

@end
