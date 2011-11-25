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

@interface SLFFetchedTableViewController()
- (NSString *)chamberFilterForScopeIndex:(NSInteger )scopeIndex;
- (void)resetToDefaultFilterPredicateWithScopeIndex:(NSInteger)scopeIndex;
- (void)applyCustomFilterWithScopeIndex:(NSInteger)scopeIndex withText:(NSString *)searchText;
- (void)resetChamberScopeForSearchBar:(UISearchBar *)searchBar;
- (NSPredicate *)defaultPredicate;
@end

@implementation SLFFetchedTableViewController

@synthesize state;
@synthesize tableViewModel = __tableViewModel;
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

- (void)configureTableViewModel {
    self.tableViewModel = [RKFetchedResultsTableViewModel tableViewModelForTableViewController:(UITableViewController*)self];
    __tableViewModel.delegate = self;
    __tableViewModel.objectManager = [RKObjectManager sharedManager];
    __tableViewModel.resourcePath = self.resourcePath;
    __tableViewModel.autoRefreshFromNetwork = YES;
    __tableViewModel.autoRefreshRate = 360;
    __tableViewModel.pullToRefreshEnabled = YES;
    __tableViewModel.imageForError = [UIImage imageNamed:@"error"];
        //__tableViewModel.imageForOffline = [UIImage imageNamed:@"offline"];
    UILabel *loadingLabel = [[[UILabel alloc] init] autorelease];
    loadingLabel.text = @"Updating";
    loadingLabel.font = SLFTitleFont(28);
    loadingLabel.backgroundColor = [UIColor colorWithWhite:.5 alpha:.7];
    loadingLabel.textColor = [SLFAppearance menuTextColor];
    loadingLabel.layer.cornerRadius = 15;
    loadingLabel.shadowColor = [UIColor colorWithWhite:0 alpha:.75];
    loadingLabel.shadowOffset = CGSizeMake(0, 2);
    loadingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [loadingLabel sizeToFit];
    loadingLabel.center = CGPointMake(PSIsIpad() ? 190 : 160, 100);
    __tableViewModel.loadingView = loadingLabel;
    __tableViewModel.predicate = nil;
    NSAssert(self.dataClass != NULL, @"Must set a data class before loading the view");
    [__tableViewModel setObjectMappingForClass:__dataClass];
    self.tableViewModel.sortDescriptors = [self.dataClass sortDescriptors];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSAssert(self.resourcePath != NULL, @"Must set a resource path before attempting to download table data.");
    [self configureTableViewModel];
    [self.tableViewModel loadTable];
    if ([self hasSearchableDataClass]) {
        [self configureSearchBarWithPlaceholder:NSLocalizedString(@"Filter results", @"") withConfigurationBlock:^(UISearchBar *searchBar) {
            if ([self shouldShowChamberScopeBar]) {
                [self configureChamberScopeTitlesForSearchBar:searchBar withState:self.state];
                [self performSelector:@selector(resetChamberScopeForSearchBar:) withObject:searchBar afterDelay:.3];
            }
        }];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.tableViewModel = nil;
}

- (void)dealloc {
    self.tableViewModel = nil;
    self.state = nil;
    self.resourcePath = nil;
    self.dataClass = nil;
    [super dealloc];
}

- (void)setResourcePath:(NSString *)resourcePath {
    self.tableViewModel.predicate = nil;
    nice_release(__resourcePath);
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
    id<RKManagedObjectCache> cache = self.tableViewModel.objectManager.objectStore.managedObjectCache;
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
        self.tableViewModel.predicate = [self compoundPredicate:[self defaultPredicate] withPredicate:predicate];
        if ([self shouldShowChamberScopeBar]) {
            NSString *chamberFilter = [self chamberFilterForScopeIndex:searchBar.selectedScopeButtonIndex];
            [self filterCustomPredicateWithChamberFilter:chamberFilter];
        }
        [self.tableViewModel loadTable];
    }
    [super searchBarSearchButtonClicked:searchBar];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [super searchBar:searchBar selectedScopeButtonIndexDidChange:selectedScope];
    NSString *chamberFilter = [self chamberFilterForScopeIndex:selectedScope];
    if (!IsEmpty(searchBar.text)) {
        [self applyCustomFilterWithScopeIndex:selectedScope withText:searchBar.text];
        RKLogDebug(@"Built-In Predicate = %@", self.tableViewModel.fetchRequest.predicate.predicateFormat);
        if (self.tableViewModel.predicate)
            RKLogDebug(@"Custom Predicate = %@", self.tableViewModel.predicate.predicateFormat);
        return;
    }
    [self filterDefaultFetchRequestWithChamberFilter:chamberFilter];
    RKLogDebug(@"Built-In Predicate = %@", self.tableViewModel.fetchRequest.predicate.predicateFormat);
    if (self.tableViewModel.predicate)
        RKLogDebug(@"Custom Predicate = %@", self.tableViewModel.predicate.predicateFormat);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self resetToDefaultFilterPredicateWithScopeIndex:searchBar.selectedScopeButtonIndex];
    [super searchBarCancelButtonClicked:searchBar];
}

- (void)resetToDefaultFilterPredicateWithScopeIndex:(NSInteger)scopeIndex {
    self.tableViewModel.predicate = nil;
    if ([self shouldShowChamberScopeBar]) {
        NSString *chamberFilter = [self chamberFilterForScopeIndex:scopeIndex];
        [self filterDefaultFetchRequestWithChamberFilter:chamberFilter];
    }
    [self.tableViewModel loadTable];
}

- (void)applyCustomFilterWithScopeIndex:(NSInteger)scopeIndex withText:(NSString *)searchText {
    NSPredicate *predicate = [self.dataClass predicateForSearchWithText:searchText searchMode:RKSearchModeOr];
    self.tableViewModel.predicate = [self compoundPredicate:[self defaultPredicate] withPredicate:predicate];
    if ([self shouldShowChamberScopeBar]) {
        NSString *chamberFilter = [self chamberFilterForScopeIndex:scopeIndex];
        [self filterCustomPredicateWithChamberFilter:chamberFilter];
    }
    [self.tableViewModel loadTable];
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
    self.tableViewModel.predicate = predicate;
    [self.tableViewModel loadTable];
    return YES;
}

- (BOOL)filterCustomPredicateWithChamberFilter:(NSString *)newChamberFilter {
    NSPredicate *predicate = self.tableViewModel.predicate;
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
        self.tableViewModel.predicate = predicate;
        [self.tableViewModel loadTable];
        return YES;
    }
    return NO;
}

@end
