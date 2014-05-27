//
//  SLFFetchedTableViewController.m
//  Created by Greg Combs on 11/24/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFFetchedTableViewController.h"
#import "SLFDataModels.h"
#import "SLFRestKitManager.h"
#import "NSString+SLFExtensions.h"
#import "MTInfoPanel.h"
#import "SLFDrawingExtensions.h"
#import "TableSectionHeaderView.h"

@interface SLFFetchedTableViewController()
- (NSString *)chamberFilterForScopeIndex:(NSInteger )scopeIndex;
- (void)resetToDefaultFilterPredicateWithScopeIndex:(NSInteger)scopeIndex;
- (void)applyCustomFilterWithScopeIndex:(NSInteger)scopeIndex withText:(NSString *)searchText;
- (void)resetChamberScopeForSearchBar:(UISearchBar *)searchBar;
- (NSPredicate *)defaultPredicate;
@end

@implementation SLFFetchedTableViewController

@synthesize state;
@synthesize tableController;
@synthesize resourcePath = _resourcePath;
@synthesize dataClass;
@synthesize omitSearchBar;
@synthesize defaultEmptyItem;

- (id)initWithState:(SLFState *)newState resourcePath:(NSString *)path dataClass:(Class)class {
    self = [super init];
    if (self) {
        self.stackWidth = 380;
        self.state = newState;
        self.resourcePath = path;
        self.dataClass = class;
    }
    return self;
}

- (id)initWithState:(SLFState *)newState resourcePath:(NSString *)path {
    self = [self initWithState:newState resourcePath:path dataClass:nil];
    return self;
}

- (id)initWithState:(SLFState *)newState {
    self = [self initWithState:newState resourcePath:nil];
    return self;
}

- (NSString *)actionPath {
    return [[self class] actionPathForObject:self.state];
}

- (void)configureTableController {
    self.tableController = [RKFetchedResultsTableController tableControllerForTableViewController:(UITableViewController*)self];
    self.tableController.delegate = self;
    self.tableController.objectManager = [RKObjectManager sharedManager];
    self.tableController.resourcePath = self.resourcePath;
    self.tableController.autoRefreshFromNetwork = YES;
    self.tableController.autoRefreshRate = 360;
    self.tableController.pullToRefreshEnabled = YES;
        //self.tableController.imageForError = [UIImage imageNamed:@"error"];
    CGFloat panelWidth = SLFIsIpad() ? self.stackWidth : self.tableView.width;
    MTInfoPanel *offlinePanel = [MTInfoPanel staticPanelWithFrame:CGRectMake(0,0,panelWidth,60) type:MTInfoPanelTypeError title:NSLocalizedString(@"Offline", @"") subtitle:NSLocalizedString(@"The server is unavailable.",@"") image:nil];
    self.tableController.imageForOffline = [UIImage imageFromView:offlinePanel];    
    MTInfoPanel *panel = [MTInfoPanel staticPanelWithFrame:CGRectMake(0,0,panelWidth,60) type:MTInfoPanelTypeActivity title:NSLocalizedString(@"Updating", @"") subtitle:NSLocalizedString(@"Downloading new data",@"") image:nil];
    self.tableController.loadingView = panel;
    self.tableController.predicate = nil;
    self.defaultEmptyItem = [RKTableItem tableItemWithText:NSLocalizedString(@"No Entries Found",@"") detailText:NSLocalizedString(@"There were no entries found. You may refresh the results by dragging down on the table.",@"")];
    self.defaultEmptyItem.cellMapping = [StyledCellMapping cellMappingWithStyle:UITableViewCellStyleSubtitle alternatingColors:NO largeHeight:YES selectable:NO];
    [self.defaultEmptyItem.cellMapping addDefaultMappings];    
    self.tableController.emptyItem = self.defaultEmptyItem;
    NSAssert(self.dataClass != NULL, @"Must set a data class before loading the view");
    [self.tableController setObjectMappingForClass:self.dataClass];
    self.tableController.sortDescriptors = [self.dataClass sortDescriptors];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Loading...",@"");
    [self configureTableController];
    if (self.tableController.sectionNameKeyPath) {
        
        SLF_FIXME("RKFetchedResultsController.emptyItem breaks tableView updates when sections are involved");
        self.tableController.emptyItem = nil; // don't use emptyItem with sections like this ... kills FRC tableView updates
        
        UITableViewStyle style = self.tableViewStyle;
        self.tableController.heightForHeaderInSection = [TableSectionHeaderView heightForTableViewStyle:style];
        __block __typeof__(self) bself = self;
        self.tableController.onViewForHeaderInSection = ^UIView*(NSUInteger sectionIndex, NSString* sectionTitle) {
            TableSectionHeaderView *sectionView = [[[TableSectionHeaderView alloc] initWithTitle:[sectionTitle capitalizedString] width:CGRectGetWidth(bself.tableView.bounds) style:style] autorelease];
            return sectionView;
        };   
    }
    if (self.resourcePath)
        [self.tableController loadTable];
    if ([self hasSearchableDataClass] && !self.omitSearchBar) {
        __block __typeof__(self) bself = self;
        [self configureSearchBarWithPlaceholder:NSLocalizedString(@"Filter results", @"") withConfigurationBlock:^(UISearchBar *searchBar) {
            if ([bself shouldShowChamberScopeBar]) {
                [bself configureChamberScopeTitlesForSearchBar:searchBar withState:bself.state];
                [bself performSelector:@selector(resetChamberScopeForSearchBar:) withObject:searchBar afterDelay:.3];
            }
        }];
    }
    self.screenName = @"Fetched Table Screen";
}

- (void)viewDidUnload {
    self.tableController = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    self.tableController = nil;
    self.state = nil;
    self.resourcePath = nil;
    self.dataClass = nil;
    [super dealloc];
}

- (void)resizeLoadingView {
    if (!self.tableController.loadingView)
        return;
    self.tableController.loadingView.width = self.tableView.width;
}

- (void)tableControllerDidStartLoad:(RKAbstractTableController *)tableController {
    [self resizeLoadingView];
}

- (void)setResourcePath:(NSString *)path {
    self.tableController.predicate = nil;
    SLFRelease(_resourcePath);
    _resourcePath = [path copy];
    if (self.isViewLoaded && self.tableController) {
        self.tableController.resourcePath = path;
    }
}

- (BOOL)hasSearchableDataClass {
    return (self.dataClass && [self.dataClass isSubclassOfClass:[RKSearchableManagedObject class]]);
}

- (BOOL)shouldShowChamberScopeBar {
    return (NO == [self hasExistingChamberPredicate]);
}

- (void)resetChamberScopeForSearchBar:(UISearchBar *)searchBar {
    [self searchBar:searchBar selectedScopeButtonIndexDidChange:searchBar.selectedScopeButtonIndex];
}

- (NSString *)chamberFilterForScopeIndex:(NSInteger )scopeIndex {
    NSString *chamberFilter = @"";
    NSString *chamber = [SLFChamber chamberTypeForSearchScopeIndex:scopeIndex];
    if (chamber)
        chamberFilter = [NSString stringWithFormat:@"AND chamber == \"%@\"", chamber];
    return chamberFilter;
}

- (NSPredicate *)defaultPredicate {
    id<RKManagedObjectCache> cache = self.tableController.objectManager.objectStore.managedObjectCache;
    NSAssert(cache != NULL, @"Must have a managed object cache");
    NSFetchRequest *fetchRequest = [cache fetchRequestForResourcePath:self.resourcePath];
    if (!fetchRequest)
        return [NSPredicate predicateWithValue:TRUE];
    return fetchRequest.predicate;
}

- (NSPredicate *)compoundPredicate:(NSPredicate *)pred1 withPredicate:(NSPredicate *)pred2 {
    return [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:pred1, pred2, nil]];
}

#pragma mark - SearchBar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (!IsEmpty(searchBar.text)) {
        NSPredicate *predicate = [self.dataClass predicateForSearchWithText:searchBar.text searchMode:RKSearchModeOr];
        self.tableController.predicate = [self compoundPredicate:[self defaultPredicate] withPredicate:predicate];
        if ([self shouldShowChamberScopeBar]) {
            NSString *chamberFilter = [self chamberFilterForScopeIndex:searchBar.selectedScopeButtonIndex];
            [self filterCustomPredicateWithChamberFilter:chamberFilter];
        }
        [self.tableController loadTable];
    }
    [super searchBarSearchButtonClicked:searchBar];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [super searchBar:searchBar selectedScopeButtonIndexDidChange:selectedScope];
    NSString *chamberFilter = [self chamberFilterForScopeIndex:selectedScope];
    if (!IsEmpty(searchBar.text)) {
        [self applyCustomFilterWithScopeIndex:selectedScope withText:searchBar.text];
        RKLogDebug(@"Built-In Predicate = %@", self.tableController.fetchRequest.predicate.predicateFormat);
        if (self.tableController.predicate)
            RKLogDebug(@"Custom Predicate = %@", self.tableController.predicate.predicateFormat);
        return;
    }
    [self filterDefaultFetchRequestWithChamberFilter:chamberFilter];
    RKLogDebug(@"Built-In Predicate = %@", self.tableController.fetchRequest.predicate.predicateFormat);
    if (self.tableController.predicate)
        RKLogDebug(@"Custom Predicate = %@", self.tableController.predicate.predicateFormat);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self resetToDefaultFilterPredicateWithScopeIndex:searchBar.selectedScopeButtonIndex];
    [super searchBarCancelButtonClicked:searchBar];
}

- (void)resetToDefaultFilterPredicateWithScopeIndex:(NSInteger)scopeIndex {
    self.tableController.predicate = nil;
    if ([self shouldShowChamberScopeBar]) {
        NSString *chamberFilter = [self chamberFilterForScopeIndex:scopeIndex];
        [self filterDefaultFetchRequestWithChamberFilter:chamberFilter];
    }
    [self.tableController loadTable];
}

- (void)applyCustomFilterWithScopeIndex:(NSInteger)scopeIndex withText:(NSString *)searchText {
    NSPredicate *predicate = [self.dataClass predicateForSearchWithText:searchText searchMode:RKSearchModeOr];
    self.tableController.predicate = [self compoundPredicate:[self defaultPredicate] withPredicate:predicate];
    if ([self shouldShowChamberScopeBar]) {
        NSString *chamberFilter = [self chamberFilterForScopeIndex:scopeIndex];
        [self filterCustomPredicateWithChamberFilter:chamberFilter];
    }
    [self.tableController loadTable];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [super searchBar:searchBar textDidChange:searchText];
    if (IsEmpty(searchText)) {
        [self resetToDefaultFilterPredicateWithScopeIndex:searchBar.selectedScopeButtonIndex];
        return;
    }
    [self applyCustomFilterWithScopeIndex:searchBar.selectedScopeButtonIndex withText:searchText];
}

- (BOOL)hasExistingChamberPredicate {
    @try {
        NSString *predicateString = [[self defaultPredicate] predicateFormat];
        if (predicateString && [predicateString hasSubstring:@"chamber"])
            return YES;
    }
    @catch (NSException *exception) {
    }
    return NO;
}

- (BOOL)filterDefaultFetchRequestWithChamberFilter:(NSString *)newChamberFilter {
    NSString *newPredicateString = [[self defaultPredicate].predicateFormat stringByAppendingFormat:@" %@", newChamberFilter];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:newPredicateString];
    self.tableController.predicate = predicate;
    [self.tableController loadTable];
    return YES;
}

- (BOOL)filterCustomPredicateWithChamberFilter:(NSString *)newChamberFilter {
    NSPredicate *predicate = self.tableController.predicate;
    if (!predicate)
        return NO;
    NSString *oldPredicateString = [predicate predicateFormat];
    NSString *newPredicateString = nil;
    NSString *replaceTerm = nil;
    if ([oldPredicateString hasSubstring:@"AND chamber == \"lower\""])
        replaceTerm = @"AND chamber == \"lower\"";
    else if ([oldPredicateString hasSubstring:@"AND chamber == \"upper\""])
        replaceTerm = @"AND chamber == \"upper\"";
    if (!IsEmpty(replaceTerm))
        newPredicateString = [oldPredicateString stringByReplacingOccurrencesOfString:replaceTerm withString:newChamberFilter];
    else if (!IsEmpty(newChamberFilter))
        newPredicateString = [oldPredicateString stringByAppendingFormat:@" %@", newChamberFilter];
    if (newPredicateString) {
        predicate = [NSPredicate predicateWithFormat:newPredicateString];
        self.tableController.predicate = predicate;
        [self.tableController loadTable];
        return YES;
    }
    return NO;
}

@end
