//
//  MasterTableViewController.m
//  Created by Gregory Combs on 6/28/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LegislatorMasterViewController.h"
#import "LegislatorsDataSource.h"
#import "SLFDataModels.h"
#import "LegislatorDetailViewController.h"
#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "LegislatorCell.h"
#import "StateMetaLoader.h"
#import "SLFPersistenceManager.h"

@interface LegislatorMasterViewController (Private)
//- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
- (IBAction)redisplayVisibleCells:(id)sender;

@end


@implementation LegislatorMasterViewController
@synthesize chamberControl;

#pragma mark -
#pragma mark Main Menu Info

+ (NSString *)name
{ return NSLocalizedStringFromTable(@"Legislators", @"StandardUI", @"The short title for buttons and tabs related to legislators"); }

- (NSString *)navigationBarName 
{ return NSLocalizedStringFromTable(@"Legislator Directory", @"StandardUI", @"The long title for buttons and tabs related to legislators"); }

+ (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"123-id-card-inv"]; }


#pragma mark -
#pragma mark Initialization

- (NSString *)nibName {
	return NSStringFromClass([self class]);
}


- (Class)dataSourceClass {
	return [LegislatorsDataSource class];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.chamberControl = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
			
	self.tableView.rowHeight = 73.0f;
	
	if ([UtilityMethods isIPadDevice])
	    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	
	
    LegislatorsDataSource *dsource = self.dataSource;
    [dsource loadData];

	self.chamberControl.tintColor = [TexLegeTheme accent];
    
	self.searchDisplayController.searchBar.tintColor = [TexLegeTheme accent];
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDelegate = self;
	self.searchDisplayController.searchResultsDataSource = dsource;

	self.navigationItem.titleView = self.chamberControl;
    
}

- (void)viewDidUnload {	
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.chamberControl setTitle:stringForChamber(BOTH_CHAMBERS, TLReturnAbbrev) forSegmentAtIndex:0];
	[self.chamberControl setTitle:stringForChamber(HOUSE, TLReturnAbbrev) forSegmentAtIndex:1];
	[self.chamberControl setTitle:stringForChamber(SENATE, TLReturnAbbrev) forSegmentAtIndex:2];
    
	NSDictionary *segPrefs = [[NSUserDefaults standardUserDefaults] objectForKey:kSegmentControlPrefKey];
	if (segPrefs) {
		NSNumber *segIndex = [segPrefs objectForKey:NSStringFromClass([self class])];
		if (segIndex)
			self.chamberControl.selectedSegmentIndex = [segIndex integerValue];
	}
    
	if ([UtilityMethods isIPadDevice])
		[self.tableView reloadData]; // popovers look bad without this
	
	[self redisplayVisibleCells:nil];	
}

- (IBAction)redisplayVisibleCells:(id)sender {
	NSArray *visibleCells = self.tableView.visibleCells;
	for (id cell in visibleCells) {
		if ([cell respondsToSelector:@selector(redisplay)])
			[cell performSelector:@selector(redisplay)];
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {	
	[self redisplayVisibleCells:nil];	
}

#pragma mark -
#pragma mark Table view delegate

//START:code.split.delegate
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {
	
    [aTableView deselectRowAtIndexPath:newIndexPath animated:YES];
	
	BOOL isSplitViewDetail = ([UtilityMethods isIPadDevice]);
	
	id dataObject = [self.dataSource dataObjectForIndexPath:newIndexPath];
	if (!dataObject || NO == [dataObject isKindOfClass:[SLFLegislator class]]) {
		return;
    }
    SLFLegislator *legislator = dataObject;

    SLFPersistenceManager *persistence = [SLFPersistenceManager sharedPersistence];
    [persistence setTableSelection:newIndexPath forKey:NSStringFromClass([self class])];
	
	if (self.detailViewController == nil) {
		self.detailViewController = [[[LegislatorDetailViewController alloc] initWithNibName:@"LegislatorDetailViewController" bundle:nil] autorelease];
	}
	
    [self.detailViewController setLegislator:legislator];
    if (aTableView == self.searchDisplayController.searchResultsTableView) { // we've clicked in a search table
        //[self searchBarCancelButtonClicked:nil];
    }
    
    if (!isSplitViewDetail) {
        // push the detail view controller onto the navigation stack to display it				
        [self.navigationController pushViewController:self.detailViewController animated:YES];
        self.detailViewController = nil;
    }
}
//END:code.split.delegate

	
- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL useDark = (indexPath.row % 2 == 0);

	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];

}

#pragma mark -
#pragma mark Filtering and Searching

- (void)stateChanged:(NSNotification *)notification {
    LegislatorsDataSource *dsource = self.dataSource;
    dsource.stateID = [[[StateMetaLoader sharedStateMeta] selectedState] abbreviation];
    [self filterChamber:notification];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString*)searchString searchScope:(NSInteger)searchOption {
    
    NSPredicate *predicate = nil;
    LegislatorsDataSource *dsource = self.dataSource;

    NSMutableString *predicateString = [[NSMutableString alloc] init];
    
    
    // A chamber/scope has been selected
    if (searchOption > 0) {
        NSString *searchScope = stringForChamber(searchOption, TLReturnOpenStates);
        [predicateString appendFormat:@"(chamber LIKE[cd] '%@')", searchScope];
        
        if (!IsEmpty(searchString) || !IsEmpty(dsource.stateID)) {
            [predicateString appendString:@" AND "];
        }
    }
    
    // we have some search terms typed in
    if (!IsEmpty(searchString)) {
        [predicateString appendFormat:@"(fullName CONTAINS[cd] '%@')", searchString];
        
        if (!IsEmpty(dsource.stateID)) {
            [predicateString appendString:@" AND "];
        }
    }
    
    // we have a solid state ID
    if (!IsEmpty(dsource.stateID)) {
        [predicateString appendFormat:@"(stateID LIKE[cd] '%@')", dsource.stateID];
    }

    
    // we have some filters, set up the predicate
    if ([predicateString length]) {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    [predicateString release];
    
    
    NSFetchedResultsController *frc = dsource.fetchedResultsController;
    
    if (frc.cacheName) {
        [NSFetchedResultsController deleteCacheWithName:frc.cacheName];
    }

    [frc.fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    if (![frc performFetch:&error]) {
        RKLogError(@"Unresolved error %@, %@", [error localizedDescription], [error userInfo]);
    }           
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSInteger searchOption = controller.searchBar.selectedScopeButtonIndex;
    return [self searchDisplayController:controller shouldReloadTableForSearchString:searchString searchScope:searchOption];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    NSString* searchString = controller.searchBar.text;
    return [self searchDisplayController:controller shouldReloadTableForSearchString:searchString searchScope:searchOption];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	self.dataSource.hideTableIndex = YES;
	// for some reason, these get zeroed out after we restart searching.
	self.searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;
	self.searchDisplayController.searchResultsTableView.backgroundColor = self.tableView.backgroundColor;
	self.searchDisplayController.searchResultsTableView.sectionIndexMinimumDisplayRowCount = self.tableView.sectionIndexMinimumDisplayRowCount;
	
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	self.dataSource.hideTableIndex = NO;
}

- (IBAction) filterChamber:(id)sender {
    if (!self.chamberControl)
        return;
                    
    NSInteger searchScope = self.chamberControl.selectedSegmentIndex;
    searchScope = MAX(searchScope, BOTH_CHAMBERS);
    searchScope = MIN(searchScope, SENATE);
    
    NSString *searchText = self.searchDisplayController.searchBar.text;
    if (IsEmpty(searchText))
        searchText = @"";

    [self searchDisplayController:self.searchDisplayController 
                        shouldReloadTableForSearchString:searchText
                                             searchScope:searchScope];
            
    NSDictionary *segPrefs = [[NSUserDefaults standardUserDefaults] objectForKey:kSegmentControlPrefKey];
    if (segPrefs) {
        NSNumber *segIndex = [NSNumber numberWithInteger:self.chamberControl.selectedSegmentIndex];
        NSMutableDictionary *newDict = [segPrefs mutableCopy];
        [newDict setObject:segIndex forKey:NSStringFromClass([self class])];
        [[NSUserDefaults standardUserDefaults] setObject:newDict forKey:kSegmentControlPrefKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [newDict release];
    }
    
    [self.tableView reloadData];
}

@end

