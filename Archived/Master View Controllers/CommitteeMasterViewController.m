//
//  CommitteeMasterViewController.m
//  Created by Gregory Combs on 6/28/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "CommitteeMasterViewController.h"
#import "CommitteesDataSource.h"
#import "SLFDataModels.h"
#import "CommitteeDetailViewController.h"
#import "TexLegeTheme.h"
#import "UtilityMethods.h"
#import "SLFPersistenceManager.h"
#import "StateMetaLoader.h"

@interface CommitteeMasterViewController (Private)
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
@end

@implementation CommitteeMasterViewController
@synthesize chamberControl;

#pragma mark -
#pragma mark Main Menu Info

+ (NSString *)name
{ return NSLocalizedStringFromTable(@"Committees", @"StandardUI", @"The short title for buttons and tabs related to legislative committees"); }

- (NSString *)navigationBarName 
{ return NSLocalizedStringFromTable(@"Committee Information", @"StandardUI", @"The long title for buttons and tabs related to legislative committees"); }

+ (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"60-signpost-inv"]; }


#pragma mark -
#pragma mark Initialization

- (NSString *)nibName {
	return NSStringFromClass([self class]);
}

- (Class)dataSourceClass {
	return [CommitteesDataSource class];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	self.chamberControl = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.rowHeight = 44.0f;
	
	if ([UtilityMethods isIPadDevice])
		self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);

    CommitteesDataSource *dsource = (CommitteesDataSource *)self.dataSource;
    [dsource loadData];

	self.chamberControl.tintColor = [TexLegeTheme accent];

	self.searchDisplayController.searchBar.tintColor = [TexLegeTheme accent];
	self.searchDisplayController.delegate = self;
	self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchResultsDataSource = dsource;

	self.navigationItem.titleView = self.chamberControl;
	
}

- (void)viewDidUnload {
    self.chamberControl = nil;
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    CommitteesDataSource *dsource = (CommitteesDataSource *)self.dataSource;
    SLFState *state = [SLFState findFirstByAttribute:@"stateID" withValue:dsource.stateID];
    NSInteger index = 0;
    for (SLFChamber *chamber in state.chambers) {
        [self.chamberControl setTitle:chamber.shortName forSegmentAtIndex:index];
        index++;
    }
    
	NSDictionary *segPrefs = [[NSUserDefaults standardUserDefaults] objectForKey:kSegmentControlPrefKey];
	if (segPrefs) {
		NSNumber *segIndex = [segPrefs objectForKey:NSStringFromClass([self class])];
		if (segIndex)
			self.chamberControl.selectedSegmentIndex = [segIndex integerValue];
	}
			
	if ([UtilityMethods isIPadDevice])
		[self.tableView reloadData]; // popovers look bad without this
	
}


#pragma mark -
#pragma mark Table view delegate


//START:code.split.delegate
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {

    [aTableView deselectRowAtIndexPath:newIndexPath animated:YES];
	
	BOOL isSplitViewDetail = ([UtilityMethods isIPadDevice]) && (self.splitViewController != nil);
	
	id dataObject = [self.dataSource dataObjectForIndexPath:newIndexPath];
    if (!dataObject || NO == [dataObject isKindOfClass:[SLFCommittee class]]) {
		return;
    }
    
    SLFCommittee *committee = dataObject;

	SLFPersistenceManager *persistence = [SLFPersistenceManager sharedPersistence];
    [persistence setTableSelection:newIndexPath forKey:NSStringFromClass([self class])];
		
    CommitteeDetailViewController *comVC = self.detailViewController;
    
	if (comVC == nil) {
		comVC = [[[CommitteeDetailViewController alloc] initWithNibName:@"CommitteeDetailViewController" bundle:nil] autorelease];
	}
	comVC.detailObjectID = committee.committeeID;
    
    if (!isSplitViewDetail) {
            // push the detail view controller onto the navigation stack to display it				
        [self.navigationController pushViewController:comVC animated:YES];
        self.detailViewController = nil;
    }
    
    if (aTableView == self.searchDisplayController.searchResultsTableView) { // we've clicked in a search table
        [self searchBarCancelButtonClicked:self.searchDisplayController.searchBar];
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
    [super stateChanged:notification];
    
    [self filterChamber:notification];
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString*)searchString searchScope:(NSInteger)searchOption {
    
    NSPredicate *predicate = nil;
    CommitteesDataSource *dsource = (CommitteesDataSource *)self.dataSource;
    
    NSMutableString *predicateString = [[NSMutableString alloc] init];
    
    SLFState *state = [SLFState findFirstByAttribute:@"stateID" withValue:dsource.stateID];
    SLFChamber *chamber = [state.chambers objectAtIndex:searchOption];
    
    // A chamber/scope has been selected
    if (![chamber.type isEqualToString:@"all"]) {
        [predicateString appendFormat:@"(chamber LIKE[cd] '%@')", chamber.type];
        
        if (!IsEmpty(searchString) || !IsEmpty(dsource.stateID)) {
            [predicateString appendString:@" AND "];
        }
    }
    
    // we have some search terms typed in
    if (!IsEmpty(searchString)) {
        [predicateString appendFormat:@"(committeeName CONTAINS[cd] '%@')", searchString];
        
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


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if ([self.searchDisplayController respondsToSelector:@selector(searchBarCancelButtonClicked:)])
        [self.searchDisplayController performSelector:@selector(searchBarCancelButtonClicked:) withObject:searchBar];
    
    self.dataSource.fetchedResultsController = nil;
    [self.dataSource fetchedResultsController];
        //[self filterChamber:self.chamberControl];
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
    searchScope = MAX(searchScope, CHAMBER_ALL);
    searchScope = MIN(searchScope, CHAMBER_UPPER);
    
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

