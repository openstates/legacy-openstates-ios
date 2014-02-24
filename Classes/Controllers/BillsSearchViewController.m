//
//  BillsSearchViewController.m
//  Created by Greg Combs on 11/21/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "BillsSearchViewController.h"
#import "SLFDataModels.h"
#import "BillSearchParameters.h"
#import "BillsViewController.h"
#import "TableSectionHeaderView.h"
#import "ActionSheetStringPicker.h"

enum SECTIONS {
    SectionSearchInfo = 1,
    kNumSections
};


@interface BillsSearchViewController()
@property (nonatomic, retain) RKTableController *tableController;
@property (nonatomic, copy) NSString *selectedSession;
- (NSString *)headerForSectionIndex:(NSInteger)sectionIndex;
- (void)configureTableItems;
- (void)configureSearchInfo;
@end

@implementation BillsSearchViewController
@synthesize state = _state;
@synthesize tableController = _tableController;
@synthesize selectedSession = _selectedSession;

- (id)initWithState:(SLFState *)state {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.stackWidth = 400;
        self.state = state;
        if (state)
            self.selectedSession = SLFSelectedSessionForState(state);
    }
    return self;
}

- (void)dealloc {
    self.state = nil;
    self.selectedSession = nil;
    self.tableController = nil;
    [super dealloc];
}

- (void)viewDidUnload {
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
    CGFloat headerHeight = [TableSectionHeaderView heightForTableViewStyle:self.tableViewStyle];
    NSInteger sectionIndex;
    __block __typeof__(self) bself = self;
   for (sectionIndex = SectionSearchInfo;sectionIndex < kNumSections; sectionIndex++) {
        [_tableController addSectionUsingBlock:^(RKTableSection *section) {
            NSString *headerTitle = [bself headerForSectionIndex:sectionIndex];
            TableSectionHeaderView *headerView = [[TableSectionHeaderView alloc] initWithTitle:headerTitle width:bself.tableView.width style:bself.tableViewStyle];
            section.headerTitle = headerTitle;
            section.headerHeight = headerHeight;
            section.headerView = headerView;
            [headerView release];
        }];
    }
    [self configureTableItems];
    self.screenName = @"Bills Search Screen";
}

- (NSString *)actionPath {
    return [[self class] actionPathForObject:self.state];
}

- (NSString *)headerForSectionIndex:(NSInteger)sectionIndex {
    switch (sectionIndex) {
        case SectionSearchInfo:
            return NSLocalizedString(@"Settings",@"");
        default:
            return @"";
    }
}

- (void)configureTableItems {
    if (!self.state)
        return;
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Search %@ Bills",@""), self.state.name];
    __block __typeof__(self) bself = self;
    [self configureSearchBarWithPlaceholder:NSLocalizedString(@"HB 1, Budget, etc", @"") withConfigurationBlock:^(UISearchBar *searchBar) {
        [bself configureChamberScopeTitlesForSearchBar:searchBar withState:bself.state];
    }];
    [self configureSearchInfo];
}

- (void)configureSearchInfo {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];    
    __block __typeof__(self) bself = self;
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StyledCellMapping cellMappingWithStyle:UITableViewCellStyleValue1 alternatingColors:NO largeHeight:NO selectable:NO];
        tableItem.text = NSLocalizedString(@"State", @"");
        tableItem.detailText = bself.state.name;
    }]];
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        tableItem.text = NSLocalizedString(@"Selected Session", @"");
        if (IsEmpty(bself.selectedSession))
            bself.selectedSession = [bself.state latestSession];
        tableItem.detailText = [bself.state displayNameForSession:bself.selectedSession];
        StyledCellMapping *cellMapping = [StyledCellMapping cellMappingWithStyle:UITableViewCellStyleValue1 alternatingColors:NO largeHeight:NO selectable:YES];
        tableItem.cellMapping = cellMapping;
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell *cell, id obj, NSIndexPath *indexPath) {
            NSArray *displayNames = bself.state.sessionDisplayNames;
            if (IsEmpty(displayNames))
                return;
            NSString *currentDisplayName = cell.detailTextLabel.text;
            NSInteger initialSelection = [bself.state sessionIndexForDisplayName:currentDisplayName];
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                bself.selectedSession = [bself.state.sessions objectAtIndex:selectedIndex];
                SLFSaveSelectedSessionForState(bself.selectedSession, bself.state);
                [bself configureSearchInfo];
            };
            ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:NSLocalizedString(@"Select a Session", @"") rows:displayNames initialSelection:initialSelection doneBlock:done cancelBlock:nil origin:bself.tableView];
            picker.presentFromRect = [bself.tableView rectForRowAtIndexPath:indexPath];
            [picker showActionSheetPicker];
            [picker autorelease];
        };
    }]];
    [_tableController loadTableItems:tableItems inSection:SectionSearchInfo];
    [tableItems release];
}

#pragma mark - Search Bar Delegate

/*
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"stuff4");
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"stuff6");
}*/
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSInteger scopeIndex = SLFSelectedScopeIndexForKey(NSStringFromClass([self class]));
    NSString *chamber = [SLFChamber chamberTypeForSearchScopeIndex:scopeIndex];;
    NSString *resourcePath = [BillSearchParameters pathForText:searchBar.text state:self.state.stateID session:self.selectedSession chamber:chamber];
    BillsViewController *vc = [[BillsViewController alloc] initWithState:self.state resourcePath:resourcePath];
    [self stackOrPushViewController:vc];
    [vc release];
    [searchBar resignFirstResponder];
}
@end
