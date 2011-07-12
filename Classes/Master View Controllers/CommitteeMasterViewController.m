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

#import "TexLegeCoreDataUtils.h"
#import "CommitteesDataSource.h"
#import "CommitteeMasterViewController.h"
#import "CommitteeDetailViewController.h"
#import "CommitteeObj.h"

#import "UtilityMethods.h"
#import "StatesLegeAppDelegate.h"
#import "TexLegeTheme.h"

@interface CommitteeMasterViewController (Private)
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
@end

@implementation CommitteeMasterViewController
@synthesize chamberControl;

#pragma mark -
#pragma mark Initialization

- (NSString *)nibName {
	return NSStringFromClass([self class]);
}

- (Class)dataSourceClass {
	return [CommitteesDataSource class];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.rowHeight = 44.0f;
	
	if ([UtilityMethods isIPadDevice])
		self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);

	self.searchDisplayController.delegate = self;
	self.searchDisplayController.searchResultsDelegate = self;
	//self.dataSource.searchDisplayController = self.searchDisplayController;
	//self.searchDisplayController.searchResultsDataSource = self.dataSource;
	
	self.chamberControl.tintColor = [TexLegeTheme accent];
	self.searchDisplayController.searchBar.tintColor = [TexLegeTheme accent];
	self.navigationItem.titleView = self.chamberControl;
	/*
	NSError *error = nil;
	NSInteger count = [CommitteeObj count:&error];
	if (error || count == 0) {
		self.navigationController.tabBarItem.enabled = NO;
		return;
	}*/	
	
	if (!self.selectObjectOnAppear && [UtilityMethods isIPadDevice])
			self.selectObjectOnAppear = [self firstDataObject];

	[self.chamberControl setTitle:stringForChamber(BOTH_CHAMBERS, TLReturnFull) forSegmentAtIndex:0];
	[self.chamberControl setTitle:stringForChamber(HOUSE, TLReturnFull) forSegmentAtIndex:1];
	[self.chamberControl setTitle:stringForChamber(SENATE, TLReturnFull) forSegmentAtIndex:2];
		
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
		
	NSDictionary *segPrefs = [[NSUserDefaults standardUserDefaults] objectForKey:kSegmentControlPrefKey];
	if (segPrefs) {
		NSNumber *segIndex = [segPrefs objectForKey:NSStringFromClass([self class])];
		if (segIndex)
			self.chamberControl.selectedSegmentIndex = [segIndex integerValue];
	}
			
	//// ALL OF THE FOLLOWING MUST *NOT* RUN ON IPHONE (I.E. WHEN THERE'S NO SPLITVIEWCONTROLLER
	if ([UtilityMethods isIPadDevice] && self.selectObjectOnAppear == nil) {
		id detailObject = self.detailViewController ? [self.detailViewController valueForKey:@"committee"] : nil;
		if (!detailObject) {
			NSIndexPath *currentIndexPath = [self.tableView indexPathForSelectedRow];
			if (!currentIndexPath) {			
				NSUInteger ints[2] = {0,0};	// just pick the first one then
				currentIndexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
			}
			detailObject = [self.dataSource dataObjectForIndexPath:currentIndexPath];				
		}
		self.selectObjectOnAppear = detailObject;
	}	
	if ([UtilityMethods isIPadDevice])
		[self.tableView reloadData]; // this "fixes" an issue where it's using cached (bogus) values for our vote index sliders
	
	// END: IPAD ONLY
}


#pragma mark -
#pragma mark Table view delegate

//START:code.split.delegate
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {
	StatesLegeAppDelegate *appDelegate = [StatesLegeAppDelegate appDelegate];

	if (![UtilityMethods isIPadDevice])
		[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];
	
	BOOL isSplitViewDetail = ([UtilityMethods isIPadDevice]) && (self.splitViewController != nil);
	
	id dataObject = [self.dataSource dataObjectForIndexPath:newIndexPath];
	if ([dataObject isKindOfClass:[RKManagedObject class]])
		[appDelegate setSavedTableSelection:[dataObject primaryKeyValue] forKey:NSStringFromClass([self class])];
	else
		[appDelegate setSavedTableSelection:newIndexPath forKey:NSStringFromClass([self class])];
		
	// create a CommitteeDetailViewController. This controller will display the full size tile for the element
	if (self.detailViewController == nil) {
		self.detailViewController = [[[CommitteeDetailViewController alloc] initWithNibName:@"CommitteeDetailViewController" bundle:nil] autorelease];
	}
	
	CommitteeObj *committee = dataObject;
	if (committee) {
		[self.detailViewController setCommittee:committee];
		if (aTableView == self.searchDisplayController.searchResultsTableView) { // we've clicked in a search table
			[self searchBarCancelButtonClicked:nil];
		}
		
		if (!isSplitViewDetail) {
			// push the detail view controller onto the navigation stack to display it				
			[self.navigationController pushViewController:self.detailViewController animated:YES];
			self.detailViewController = nil;
		}
	}
	
}
//END:code.split.delegate

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
#pragma mark Filtering and Searching

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	if ([self.dataSource respondsToSelector:@selector(setFilterChamber:)])
		[self.dataSource setFilterChamber:scope];
	
	// start filtering names...
	if (searchText.length > 0) {
		if ([self.dataSource respondsToSelector:@selector(setFilterByString:)])
			[self.dataSource performSelector:@selector(setFilterByString:) withObject:searchText];
	}	
	else {
		if ([self.dataSource respondsToSelector:@selector(removeFilter)])
			[self.dataSource performSelector:@selector(removeFilter)];
	}
	
}

- (IBAction) filterChamber:(id)sender {
	if (sender == chamberControl) {
		[self filterContentForSearchText:self.searchDisplayController.searchBar.text 
								   scope:self.chamberControl.selectedSegmentIndex];

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
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:self.chamberControl.selectedSegmentIndex];
    
	// Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
	self.searchDisplayController.searchBar.text = @"";
	[self.dataSource removeFilter];
	
	[self.searchDisplayController setActive:NO animated:YES];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	[self.dataSource setHideTableIndex:YES];	
	// for some reason, these get zeroed out after we restart searching.
	self.searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;
	self.searchDisplayController.searchResultsTableView.backgroundColor = self.tableView.backgroundColor;
	self.searchDisplayController.searchResultsTableView.sectionIndexMinimumDisplayRowCount = self.tableView.sectionIndexMinimumDisplayRowCount;
	
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	[self.dataSource setHideTableIndex:NO];	
}
@end

