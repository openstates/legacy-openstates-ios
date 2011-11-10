//
//  LegislatorDetailViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LegislatorDetailViewController.h"
#import "CommitteeDetailViewController.h"
#import "DistrictDetailViewController.h"
#import "SLFDataModels.h"
#import "SLFMappingsManager.h"
#import "SLFRestKitManager.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"
#import "UIImageView+RoundedCorners.h"
#import "SVWebViewController.h"
#import "SLFReachable.h"
#import "ContributionsViewController.h"
#import "TableSectionHeaderView.h"

enum SECTIONS {
    SectionMemberInfo = 1,
    SectionDistrict,
    SectionResources,
    SectionCommittees,
    SectionBills,
    kNumSections
};

@interface LegislatorDetailViewController()
@property (nonatomic, retain) RKTableViewModel *tableViewModel;
- (void)loadDataFromNetworkWithID:(NSString *)resourceID;
- (NSString *)headerForSectionIndex:(NSInteger)sectionIndex;
- (SubtitleCellMapping *)committeeRoleCellMap;
- (void)configureTableItems;
- (void)configureMemberInfoItems;
- (void)configureDistrictMapItems;
- (void)configureResourceItems;
- (void)configureCommitteeItems;
@end

@implementation LegislatorDetailViewController
@synthesize legislator;
@synthesize tableViewModel;

- (id)initWithLegislatorID:(NSString *)legislatorID {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [self loadDataFromNetworkWithID:legislatorID];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableViewModel = [RKTableViewModel tableViewModelForTableViewController:(UITableViewController*)self];
    self.tableViewModel.delegate = self;
    self.tableViewModel.variableHeightRows = YES;
    self.tableViewModel.objectManager = [RKObjectManager sharedManager];
    self.tableViewModel.pullToRefreshEnabled = NO;
    [self.tableViewModel mapObjectsWithClass:[CommitteeRole class] toTableCellsWithMapping:[self committeeRoleCellMap]];
    NSInteger sectionIndex;
    for (sectionIndex = SectionMemberInfo;sectionIndex < kNumSections; sectionIndex++) {
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
	self.legislator = nil;
    self.tableViewModel = nil;
    [super dealloc];
}

- (void)loadDataFromNetworkWithID:(NSString *)resourceID {
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY,@"apikey", resourceID, @"legislatorID", nil];
    NSString *resourcePath = RKMakePathWithObject(@"/legislators/:legislatorID?apikey=:apikey", queryParams);
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:self block:^(RKObjectLoader* loader) {
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[SLFLegislator class]];
        loader.cacheTimeoutInterval = 24 * 60 * 60;
    }];
}

- (void)configureTableItems {
    [self configureMemberInfoItems];     
    [self configureDistrictMapItems];
    [self configureResourceItems];
    [self configureCommitteeItems];
}

- (void)configureMemberInfoItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    RKTableItem *firstItemCell = [RKTableItem tableItemWithBlock:^(RKTableItem* tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        if (!IsEmpty(self.legislator.photoURL)) {
            tableItem.cellMapping.rowHeight = 88;
            tableItem.cellMapping.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
                cell.textLabel.textColor = [SLFAppearance cellTextColor];
                cell.backgroundColor = [SLFAppearance cellBackgroundDarkColor];
                [cell.imageView setImageWithURL:[NSURL URLWithString:self.legislator.photoURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                [cell.imageView roundTopLeftCorner];
            };
        }
        tableItem.cellMapping.style = UITableViewCellStyleValue1;
        tableItem.text = self.legislator.formalName;
    }];
    [tableItems addObject:firstItemCell];
    [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"Chamber", @"");
        tableItem.detailText = self.legislator.chamberObj.formalName;
    }]];
    [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = [NSString stringWithFormat:@"%@ %@", legislator.title, NSLocalizedString(@"Term", @"")];
        tableItem.detailText = self.legislator.term;
    }]];
    [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"Party", @"");
        tableItem.detailText = self.legislator.partyObj.name;
    }]];
    [self.tableViewModel loadTableItems:tableItems inSection:SectionMemberInfo];     
    [tableItems release];
}

- (void)configureDistrictMapItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"District", @"");
        tableItem.detailText = self.legislator.district;
    }]];
    [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [SubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"Map", @"");
        tableItem.detailText = self.legislator.districtMapLabel;
        tableItem.cellMapping.onSelectCell = ^(void) {
            DistrictDetailViewController *vc = [[DistrictDetailViewController alloc] initWithDistrictMapID:self.legislator.districtID];
            [self stackOrPushViewController:vc];
            [vc release];
        };
    }]];
    [self.tableViewModel loadTableItems:tableItems inSection:SectionDistrict];
    [tableItems release];
}

- (void)configureResourceItems {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    if (!IsEmpty(legislator.votesmartID)) {
        NSString *url = [NSString stringWithFormat:@"http://votesmart.org/bio.php?can_id=%@", legislator.votesmartID];
        [tableItems addObject:[self webPageItemWithTitle:NSLocalizedString(@"Vote Smart Bio", @"") subtitle:@"" url:url]];
    }
    if (!IsEmpty(legislator.transparencyID)) {
        [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
            tableItem.cellMapping = [SubtitleCellMapping cellMapping];
            tableItem.text = NSLocalizedString(@"Campaign Contributions", @"");
            tableItem.detailText = @"";
            tableItem.URL = @"";
            tableItem.cellMapping.onSelectCell = ^(void) {
                ContributionsViewController *controller = [[ContributionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                [controller setQueryEntityID:legislator.transparencyID type:[NSNumber numberWithInteger:kContributionQueryRecipient] cycle:@"-1"];
                [self stackOrPushViewController:controller];
                [controller release];
            };
        }]];
    }
    if (!IsEmpty(legislator.nimspID)) {
        NSString *url = [NSString stringWithFormat:@"http://www.followthemoney.org/database/uniquecandidate.phtml?uc=%@", legislator.nimspID];
        [tableItems addObject:[self webPageItemWithTitle:NSLocalizedString(@"Follow The Money Summary", @"") subtitle:@"" url:url]];
    }
    for (GenericAsset *source in self.legislator.sources) {
        NSString *subtitle = source.name;
        if (IsEmpty(subtitle))
            subtitle = source.url;
        [tableItems addObject:[self webPageItemWithTitle:NSLocalizedString(@"Web Resource", @"") subtitle:subtitle url:source.url]];
    }
    [self.tableViewModel loadTableItems:tableItems inSection:SectionResources];
    [tableItems release];
}

- (void)configureCommitteeItems {
    [self.tableViewModel loadObjects:self.legislator.sortedRoles inSection:SectionCommittees];    
}

- (SubtitleCellMapping *)committeeRoleCellMap {
    SubtitleCellMapping *roleCellMap = [SubtitleCellMapping cellMapping];
    [roleCellMap mapKeyPath:@"name" toAttribute:@"textLabel.text"];
    [roleCellMap mapKeyPath:@"type" toAttribute:@"detailTextLabel.text"];
    roleCellMap.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
        CommitteeRole *role = object;
        CommitteeDetailViewController *vc = [[CommitteeDetailViewController alloc] initWithCommitteeID:role.committeeID];
        [self stackOrPushViewController:vc];
        [vc release];
    };
    return roleCellMap;
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    self.title = NSLocalizedString(@"Load Error", @"");
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    if (object && [object isKindOfClass:[SLFLegislator class]])
        self.legislator = object;
    if (self.legislator)
        self.title = self.legislator.formalName;
    if (![self isViewLoaded]) { // finished loading too soon?  Would this ever happen?
        [self performSelector:@selector(objectLoader:didLoadObject:) withObject:object afterDelay:2];
        return;
    }
    [self configureTableItems];
}

- (NSString *)headerForSectionIndex:(NSInteger)sectionIndex {
    switch (sectionIndex) {
        case SectionMemberInfo:
            return NSLocalizedString(@"Member Details", @"");
        case SectionDistrict:
            return NSLocalizedString(@"District Map", @"");
        case SectionResources:
            return NSLocalizedString(@"Resources",@"");
        case SectionCommittees:
            return NSLocalizedString(@"Committees", @"");
        case SectionBills:
            return NSLocalizedString(@"Legislation", @"");
        default:
            return @"";
    }
}

@end
