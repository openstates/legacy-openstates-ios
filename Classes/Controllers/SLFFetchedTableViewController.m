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
@end

@implementation SLFFetchedTableViewController


@synthesize state;
@synthesize tableViewModel = __tableViewModel;
@synthesize resourcePath;

- (id)initWithState:(SLFState *)newState resourcePath:(NSString *)path {
    self = [super init];
    if (self) {
        self.stackWidth = 380;
        self.state = newState;
        self.resourcePath = path;
    }
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
    __tableViewModel.imageForOffline = [UIImage imageNamed:@"offline"];
    UILabel *loadingLabel = [[[UILabel alloc] init] autorelease];
    loadingLabel.text = @"Updating";
    loadingLabel.font = SLFTitleFont(34);
    loadingLabel.backgroundColor = [UIColor colorWithWhite:.5 alpha:.75];
    loadingLabel.textColor = [SLFAppearance menuTextColor];
    loadingLabel.layer.cornerRadius = 15;
    loadingLabel.shadowColor = [UIColor colorWithWhite:0 alpha:.75];
    loadingLabel.shadowOffset = CGSizeMake(0, 1);
    [loadingLabel sizeToFit];
    CGPoint center = self.tableViewModel.tableView.center;
    center.y = (center.y / 2);
    loadingLabel.center = center;
    __tableViewModel.loadingView = loadingLabel;
    __tableViewModel.predicate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSAssert(self.resourcePath != NULL, @"Must set a resource path before attempting to download table data.");
    [self configureTableViewModel];
    [self.tableViewModel loadTable];
    [self configureSearchBarWithPlaceholder:NSLocalizedString(@"Filter results", @"") withConfigurationBlock:^(UISearchBar *searchBar) {
        if (NO == [self hasExistingChamberPredicate])
            [self configureChamberScopeTitlesForSearchBar:searchBar withState:self.state];
    }];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.tableViewModel = nil;
}

- (void)dealloc {
    self.tableViewModel = nil;
    self.state = nil;
    self.resourcePath = nil;
    [super dealloc];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.tableViewModel.predicate = nil;
    [self.tableViewModel loadTable];
    [super searchBarCancelButtonClicked:searchBar];
}

- (BOOL)hasExistingChamberPredicate {
    @try {
        NSString *predicateString = self.tableViewModel.fetchRequest.predicate.predicateFormat;
        if (predicateString && [predicateString hasSubstring:@"chamber"])
            return YES;
    }
    @catch (NSException *exception) {
    }
    return NO;
}

- (BOOL)filterDefaultFetchRequestWithChamberFilter:(NSString *)newChamberFilter {
    NSPredicate *predicate = self.tableViewModel.fetchRequest.predicate;
    if (!predicate)
        return NO;
    NSString *newPredicateString = [[predicate predicateFormat] stringByAppendingFormat:@" %@", newChamberFilter];
    predicate = [NSPredicate predicateWithFormat:newPredicateString];
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

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [super searchBar:searchBar selectedScopeButtonIndexDidChange:selectedScope];
    NSString *newChamberFilter = @"";
    NSString *chamber = [SLFChamber chamberTypeForSearchScopeIndex:selectedScope];
    if (chamber)
        newChamberFilter = [NSString stringWithFormat:@"AND chamber == \"%@\"", chamber];
    if (![self filterCustomPredicateWithChamberFilter:newChamberFilter])
        [self filterDefaultFetchRequestWithChamberFilter:newChamberFilter];
}
@end
