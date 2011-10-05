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

#define SectionHeaderMemberInfo NSLocalizedString(@"Member Details", @"")
#define SectionHeaderDistrict NSLocalizedString(@"District Map", @"")
#define SectionHeaderCommittees NSLocalizedString(@"Committees", @"")
#define SectionHeaderBills NSLocalizedString(@"Legislation", @"")

enum SECTIONS {
    SectionMemberInfoIndex = 1,
    SectionDistrictIndex,
    SectionCommitteesIndex,
    SectionBillsIndex,
    kNumSections
};

@interface LegislatorDetailViewController()
@property (nonatomic, retain) RKTableViewModel *tableViewModel;

- (void)configureTableItems;
- (void)loadDataFromNetworkWithID:(NSString *)resourceID;
- (NSString *)headerForSectionIndex:(NSInteger)sectionIndex;
- (SubtitleCellMapping *)committeeRoleCellMap;
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
    /*
    self.tableController.heightForHeaderInSection = 22;
    self.tableController.onViewForHeaderInSection = ^UIView*(NSUInteger sectionIndex, NSString* sectionTitle) {
        UIView* headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 22)] autorelease];
        headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sectionheader_bg.png"]];
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.tableView.bounds.size.width, 22)];
        label.text = sectionTitle;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:12];        
        [headerView addSubview:label];
        [label release];
        return headerView;
    };*/
    NSInteger sectionIndex;
    for (sectionIndex = SectionMemberInfoIndex;sectionIndex < kNumSections; sectionIndex++) {
        [self.tableViewModel addSectionWithBlock:^(RKTableViewSection *section) {
            section.headerTitle = [self headerForSectionIndex:sectionIndex];
            section.headerHeight = 26;
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, self.tableView.width - 10, section.headerHeight-10)];
            label.textColor = [SLFAppearance tableSectionColor];
            label.shadowOffset = CGSizeMake(0, 1);
            label.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.7];
            label.backgroundColor = [UIColor clearColor];
            label.font = [SLFAppearance boldFifteen];
            label.text = section.headerTitle;

            UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, section.headerHeight)];
            sectionView.backgroundColor = [UIColor clearColor];
            [sectionView addSubview:label];
            [label release];
            section.headerView =sectionView;
            [sectionView release];
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
    }];
}

- (void)configureTableItems {
    
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
        tableItem.text = self.legislator.demoLongName;
    }];
    [tableItems addObject:firstItemCell];
    [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = self.legislator.title;
        tableItem.detailText = self.legislator.term;
    }]];
    for (NSString *website in self.legislator.sources)
        [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
            tableItem.cellMapping = [SubtitleCellMapping cellMapping];
            tableItem.text = NSLocalizedString(@"Web Site", @"");
            tableItem.detailText = website;
            tableItem.URL = website;
        }]];  
    [self.tableViewModel loadTableItems:tableItems inSection:SectionMemberInfoIndex];

    [self.tableViewModel loadObjects:self.legislator.sortedRoles inSection:SectionCommitteesIndex];

    [tableItems removeAllObjects];
    [tableItems addObject:[RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [SubtitleCellMapping cellMapping];
        tableItem.text = self.legislator.districtMapLabel;
        tableItem.detailText = NSLocalizedString(@"Map", @"");
        tableItem.cellMapping.onSelectCell = ^(void) {
            DistrictDetailViewController *vc = [[DistrictDetailViewController alloc] initWithDistrictMapID:self.legislator.districtID];
            [self stackOrPushViewController:vc];
            [vc release];
        };
    }]];
    [self.tableViewModel loadTableItems:tableItems inSection:SectionDistrictIndex];
    [tableItems release];
}

- (SubtitleCellMapping *)committeeRoleCellMap {
    SubtitleCellMapping *roleCellMap = [SubtitleCellMapping cellMapping];
    [roleCellMap mapKeyPath:@"committeeName" toAttribute:@"textLabel.text"];
    [roleCellMap mapKeyPath:@"role" toAttribute:@"detailTextLabel.text"];
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
    RKLogError(@"Error loading resource path %@, %@", objectLoader.resourcePath, error);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    if (object && [object isKindOfClass:[SLFLegislator class]])
        self.legislator = object;
    if (self.legislator)
        self.title = self.legislator.shortNameForButtons;
    if (![self isViewLoaded]) { // finished loading too soon?  Would this ever happen?
        [self performSelector:@selector(objectLoader:didLoadObject:) withObject:object afterDelay:2];
        return;
    }
    [self configureTableItems];
}

- (NSString *)headerForSectionIndex:(NSInteger)sectionIndex {
    switch (sectionIndex) {
        case SectionMemberInfoIndex:
            return SectionHeaderMemberInfo;
        case SectionDistrictIndex:
            return SectionHeaderDistrict;
        case SectionCommitteesIndex:
            return SectionHeaderCommittees;
        case SectionBillsIndex:
            return SectionHeaderBills;
        default:
            return @"";
    }
}


@end
