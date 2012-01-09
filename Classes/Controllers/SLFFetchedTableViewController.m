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

@interface SLFFetchedTableViewController()
- (NSString *)chamberFilterForScopeIndex:(NSInteger )scopeIndex;
- (void)resetToDefaultFilterPredicateWithScopeIndex:(NSInteger)scopeIndex;
- (void)applyCustomFilterWithScopeIndex:(NSInteger)scopeIndex withText:(NSString *)searchText;
- (void)resetChamberScopeForSearchBar:(UISearchBar *)searchBar;
- (NSPredicate *)defaultPredicate;
@end

@implementation SLFFetchedTableViewController

@synthesize state;
@synthesize tableController = _tableController;
@synthesize resourcePath = __resourcePath;
@synthesize dataClass = __dataClass;

- (id)initWithState:(SLFState *)newState resourcePath:(NSString *)path dataClass:(Class)dataClass {
    self = [super init];
    if (self) {
        self.stackWidth = 380;
        self.state = newState;
        self.resourcePath = path;
        self.dataClass = dataClass;
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
    _tableController.delegate = self;
    _tableController.objectManager = [RKObjectManager sharedManager];
    _tableController.resourcePath = self.resourcePath;
    _tableController.autoRefreshFromNetwork = YES;
    _tableController.autoRefreshRate = 360;
    _tableController.pullToRefreshEnabled = YES;
    _tableController.imageForError = [UIImage imageNamed:@"error"];
    CGFloat panelWidth = SLFIsIpad() ? self.stackWidth : self.tableView.width;
    MTInfoPanel *offlinePanel = [MTInfoPanel staticPanelWithFrame:CGRectMake(0,0,panelWidth,60) type:MTInfoPanelTypeError title:NSLocalizedString(@"Offline", @"") subtitle:NSLocalizedString(@"The server is unavailable.",@"") image:nil];
    _tableController.imageForOffline = [UIImage imageFromView:offlinePanel];    
    MTInfoPanel *panel = [MTInfoPanel staticPanelWithFrame:CGRectMake(0,0,panelWidth,60) type:MTInfoPanelTypeActivity title:NSLocalizedString(@"Updating", @"") subtitle:NSLocalizedString(@"Downloading new data",@"") image:nil];
    _tableController.loadingView = panel;
    _tableController.predicate = nil;
    RKTableItem *emptyItem = [RKTableItem tableItemWithText:NSLocalizedString(@"No Entries Found",@"") detailText:NSLocalizedString(@"There were no entries found. You may refresh the results by dragging down on the table.",@"")];
    emptyItem.cellMapping = [LargeStaticSubtitleCellMapping cellMapping];
    [emptyItem.cellMapping addDefaultMappings];
    _tableController.emptyItem = emptyItem;
    NSAssert(self.dataClass != NULL, @"Must set a data class before loading the view");
    [_tableController setObjectMappingForClass:__dataClass];
    self.tableController.sortDescriptors = [self.dataClass sortDescriptors];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Loading ...",@"");
    NSAssert(self.resourcePath != NULL, @"Must set a resource path before attempting to download table data.");
    [self configureTableController];
    if (_tableController.sectionNameKeyPath) {
        _tableController.heightForHeaderInSection = 18;
        __block __typeof__(self) bself = self;
        _tableController.onViewForHeaderInSection = ^UIView*(NSUInteger sectionIndex, NSString* sectionTitle) {
            UIColor *sectionColor =  SLFColorWithRGB(207,208,194);
            UIView *sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, bself.tableView.bounds.size.width, 18)] autorelease];
            sectionView.backgroundColor = sectionColor;
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, bself.tableView.bounds.size.width-10, 18)];
            label.backgroundColor = sectionColor;
            label.text = [sectionTitle capitalizedString];
            label.textColor = [UIColor whiteColor];
            label.font = SLFFont(12);
            [sectionView addSubview:label];
            [label release];
            return sectionView;
        };   
    }
    [self.tableController loadTable];
    if ([self hasSearchableDataClass]) {
        __block __typeof__(self) bself = self;
        [self configureSearchBarWithPlaceholder:NSLocalizedString(@"Filter results", @"") withConfigurationBlock:^(UISearchBar *searchBar) {
            if ([bself shouldShowChamberScopeBar]) {
                [bself configureChamberScopeTitlesForSearchBar:searchBar withState:bself.state];
                [bself performSelector:@selector(resetChamberScopeForSearchBar:) withObject:searchBar afterDelay:.3];
            }
        }];
    }
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

- (void)setResourcePath:(NSString *)resourcePath {
    self.tableController.predicate = nil;
    SLFRelease(__resourcePath);
    __resourcePath = [resourcePath copy];
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
