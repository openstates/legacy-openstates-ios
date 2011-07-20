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

#import "LegislatorsDataSource.h"
#import "LegislatorMasterViewController.h"
#import "LegislatorDetailViewController.h"
#import "UtilityMethods.h"
#import "StatesLegeAppDelegate.h"
#import "TexLegeTheme.h"
#import "UIDevice-Hardware.h"
#import "LegislatorCell.h"

@interface LegislatorMasterViewController (Private)
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
- (IBAction)redisplayVisibleCells:(id)sender;

@end


@implementation LegislatorMasterViewController
@synthesize chamberControl;

#pragma mark -
#pragma mark Initialization

- (NSString *)nibName {
	return NSStringFromClass([self class]);
}


- (Class)dataSourceClass {
	return [LegislatorsDataSource class];
}


- (void)configure {
	[super configure];	
	if (!self.selectObjectOnAppear && [UtilityMethods isIPadDevice])
		self.selectObjectOnAppear = [self firstDataObject];
}


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
			
	self.tableView.rowHeight = 73.0f;
	
	if ([UtilityMethods isIPadDevice])
	    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	
	self.searchDisplayController.delegate = self;
	self.searchDisplayController.searchResultsDelegate = self;
	
	self.chamberControl.tintColor = [TexLegeTheme accent];
	self.searchDisplayController.searchBar.tintColor = [TexLegeTheme accent];
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

	//// ALL OF THE FOLLOWING MUST NOT RUN ON IPHONE (I.E. WHEN THERE'S NO SPLITVIEWCONTROLLER	
	if ([UtilityMethods isIPadDevice] && self.selectObjectOnAppear == nil) {
		id detailObject = self.detailViewController ? [self.detailViewController valueForKey:@"legislator"] : nil;
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
		[self.tableView reloadData]; // popovers look bad without this
	
	[self redisplayVisibleCells:nil];	
	// END: IPAD ONLY
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
	StatesLegeAppDelegate *appDelegate = [StatesLegeAppDelegate appDelegate];
	
	if (![UtilityMethods isIPadDevice])
		[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];
	
	BOOL isSplitViewDetail = ([UtilityMethods isIPadDevice]);
	
	id dataObject = [self.dataSource dataObjectForIndexPath:newIndexPath];
	if (!dataObject)
		return;
	
	if ([dataObject isKindOfClass:[RKManagedObject class]])
		[appDelegate setSavedTableSelection:[dataObject primaryKeyValue] forKey:NSStringFromClass([self class])];
	else
		[appDelegate setSavedTableSelection:newIndexPath forKey:NSStringFromClass([self class])];
	
	// create a LegislatorDetailViewController. This controller will display the full size tile for the element
	if (self.detailViewController == nil) {
		self.detailViewController = [[[LegislatorDetailViewController alloc] initWithNibName:@"LegislatorDetailViewController" bundle:nil] autorelease];
	}
	
	LegislatorObj *legislator = dataObject;
	if (legislator) {
		[self.detailViewController setLegislator:legislator];
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

	
- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL useDark = (indexPath.row % 2 == 0);

	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];

}

#pragma mark -
#pragma mark Filtering and Searching

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
	if (!self.dataSource)
		return;
	
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
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
	self.searchDisplayController.searchBar.text = @"";
	[self.dataSource removeFilter];
	[self.searchDisplayController setActive:NO animated:YES];
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
@end

