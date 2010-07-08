//
//  MasterTableViewController.m
//  TexLege
//
//  Created by Gregory Combs on 6/28/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "MasterTableViewController.h"
#import "LegislatorDetailViewController.h"
#import "UtilityMethods.h"
#import "LegislatorMasterTableViewCell.h"
#import "TexLegeAppDelegate.h"

/*
 Predefined colors to alternate the background color of each cell row by row
 (see tableView:cellForRowAtIndexPath: and tableView:willDisplayCell:forRowAtIndexPath:).
 */
#define DARK_BACKGROUND  [UIColor colorWithRed:151.0/255.0 green:152.0/255.0 blue:155.0/255.0 alpha:1.0]
#define LIGHT_BACKGROUND [UIColor colorWithRed:172.0/255.0 green:173.0/255.0 blue:175.0/255.0 alpha:1.0]

@interface MasterTableViewController (Private)

- (void)setStoredSelectionWithRow:(NSInteger)row section:(NSInteger)section;
- (void)resetStoredSelection;
- (void)validateStoredSelection;

@end


@implementation MasterTableViewController
@synthesize detailViewController;
@synthesize dataSource;
@synthesize searchBar, m_searchDisplayController, chamberControl;
@synthesize menuButton, aboutButton;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/

- (NSString *)functionalViewControllerName 
{ 
	return @"MasterTableViewController";
}

- (NSString *)detailViewControllerName 
{ 
	return @"LegislatorDetailViewController";
}


- (void)configureWithDataSourceClass:(Class)sourceClass andManagedObjectContext:(NSManagedObjectContext *)context {
	self.dataSource = [[sourceClass alloc] initWithManagedObjectContext:context];
	self.title = [dataSource name];	
	// set the long name shown in the navigation bar
	//self.navigationItem.title=[dataSource navigationBarName];
	

	// FETCH CORE DATA
	if ([dataSource usesCoreData])
	{		
		NSError *error;
		// You've got to delete the cache, or disable caching before you modify the predicate...
		[NSFetchedResultsController deleteCacheWithName:[[dataSource fetchedResultsController] cacheName]];
		
		if (![[dataSource fetchedResultsController] performFetch:&error]) {
			// Handle the error...
		}				
	}
	
	// GREG do we need this one?  does it break things?
	self.tableView.delegate = self;
	self.tableView.dataSource = self.dataSource;
	self.tableView.rowHeight = self.dataSource.rowHeight;

	self.dataSource.searchDisplayController = self.m_searchDisplayController;
	self.m_searchDisplayController.searchResultsDataSource = self.dataSource;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
		
	if (!self.menuButton)
		self.menuButton = self.navigationItem.leftBarButtonItem;
	
	if (!self.aboutButton)
		self.aboutButton = self.navigationItem.rightBarButtonItem;
	
    //self.title=@"Legislators";
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	
	if (self.m_searchDisplayController == nil) {
		self.m_searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
	}
	self.m_searchDisplayController.delegate = self;
	self.m_searchDisplayController.searchResultsDelegate = self;
	
	self.tableView.backgroundColor = DARK_BACKGROUND;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
		
	[self validateStoredSelection];
	
	if ([UtilityMethods isLandscapeOrientation] == NO) {		
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.rightBarButtonItem = nil;
	}
	else {
		if (self.menuButton)
			self.navigationItem.leftBarButtonItem = self.menuButton;
		//self.menuButton = nil;
		if (self.aboutButton)
			self.navigationItem.rightBarButtonItem = self.aboutButton;
		//self.aboutButton = nil;
		
	}

	
	// if we are in in portrait then we're in a popover, hide buttons as needed ....
	
	
	TexLegeAppDelegate *appDelegate = (TexLegeAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (appDelegate.savedLocation != nil) {
		// save off this level's selection to our AppDelegate
		[self validateStoredSelection];
		NSInteger rowSelection = [[appDelegate.savedLocation objectAtIndex:1] integerValue];
		NSInteger sectionSelection = [[appDelegate.savedLocation objectAtIndex:2] integerValue];
		
		//debug_NSLog(@"Restoring Selection: Row: %d    Section: %d", rowSelection, sectionSelection);
		
		if (rowSelection != -1) {
			
			NSIndexPath *selectionPath = [NSIndexPath indexPathForRow:rowSelection inSection:sectionSelection];
						
			// I'm not sure if this is how you do the "selector" business, so I've commented it out
			//if ([self.tableView.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)
			//	[self.tableView.delegate tableView:self.tableView willSelectRowAtIndexPath:selectionPath];

			[self.tableView selectRowAtIndexPath:selectionPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
			[self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:selectionPath];

			//if ([self.tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)
			//	[self.tableView.delegate tableView:self.tableView willSelectRowAtIndexPath:selectionPath];
			
		}
	}
	
	//if (self.detailViewController.legislator == nil)
	if ([self.tableView indexPathForSelectedRow] == nil)  {
		NSUInteger ints[2] = {0,0};
		NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
		[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
		self.detailViewController.legislator = [self.dataSource legislatorDataForIndexPath:indexPath];
	}
	
	if ([UtilityMethods isIPadDevice])
		[self.tableView reloadData]; // this "fixes" an issue where it's using cached (bogus) values for our vote index sliders
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	// this is a hack so that the index does not show up on top of the search bar
	//if ([dataSource usesSearchbar]) {
	//	[self.searchDisplayController setActive:YES];
	//	[self.searchDisplayController setActive:NO];
	//}
	[self resetStoredSelection];
}
 

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];	
	
}


#pragma mark -
#pragma mark Table view delegate

//START:code.split.delegate
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// save off this item's selection to our AppDelegate
	[self setStoredSelectionWithRow:indexPath.row section:indexPath.section];
	
	//[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	self.detailViewController.legislator = [self.dataSource legislatorDataForIndexPath:indexPath];
	
	if (self.splitViewController) {
		// if we have a stack of view controllers and someone selected a new cell from our master list, 
		//	lets go all the way back to accomodate their selection, and scroll to the top.
		if ([self.detailViewController.navigationController.viewControllers count] > 1) { 
			[self.detailViewController.navigationController popToRootViewControllerAnimated:YES];
			[self.detailViewController.tableView scrollRectToVisible:self.detailViewController.headerView.bounds animated:YES];
		}
	}
	
}
//END:code.split.delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	// let's override some of the datasource's settings ... specifically, the background color.
	cell.backgroundColor = ((LegislatorMasterTableViewCell *)cell).useDarkBackground ? DARK_BACKGROUND : LIGHT_BACKGROUND;
	
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    
	[self resetStoredSelection];

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	

    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	self.chamberControl = nil;
	self.detailViewController = nil;
	self.dataSource = nil;
	self.aboutButton = self.menuButton = nil;
	
	self.searchDisplayController.searchResultsDataSource = nil;  // default is nil. delegate can provide
	self.searchDisplayController.searchResultsDelegate = nil;    // default is nil. delegate can provide
	self.searchDisplayController.delegate = nil;
	self.m_searchDisplayController = nil;
	self.searchBar = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Save Location

- (void)setStoredSelectionWithRow:(NSInteger)row section:(NSInteger)section {
	// we have moved to level 1, remove it's stored row/section selection
	TexLegeAppDelegate *appDelegate = (TexLegeAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate.savedLocation != nil) {
		NSInteger functionIndex = [appDelegate indexForFunctionalViewController:self];
		[appDelegate.savedLocation replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:functionIndex]]; //tab
		[appDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:row]];
		[appDelegate.savedLocation replaceObjectAtIndex:2 withObject:[NSNumber numberWithInteger:section]];
	}
	
}

- (void)resetStoredSelection {
	// we have moved to level 1, remove it's stored row/section selection
	[self setStoredSelectionWithRow:-1 section:-1]; 	
}

- (void)validateStoredSelection {
	TexLegeAppDelegate *appDelegate = (TexLegeAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSInteger functionIndex = [appDelegate indexForFunctionalViewController:self];
	NSInteger tabSavedSelection = [[appDelegate.savedLocation objectAtIndex:0] integerValue];
	
	if (functionIndex != tabSavedSelection) { // we're out of sync with the selection, clear the unknown
		[self resetStoredSelection];
	}
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
			[self.dataSource setFilterByString:searchText];
	}	
	else {
		if ([self.dataSource respondsToSelector:@selector(removeFilter)])
			[self.dataSource removeFilter];
	}
	
}

- (IBAction) filterChamber:(id)sender {
	if (sender == chamberControl) {
		[self filterContentForSearchText:self.searchBar.text scope:chamberControl.selectedSegmentIndex];
		[self.tableView reloadData];
	}
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:chamberControl.selectedSegmentIndex];
    
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
	self.m_searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;
	self.m_searchDisplayController.searchResultsTableView.backgroundColor = self.tableView.backgroundColor;
	self.m_searchDisplayController.searchResultsTableView.sectionIndexMinimumDisplayRowCount = self.tableView.sectionIndexMinimumDisplayRowCount;
	
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	[self.dataSource setHideTableIndex:NO];	
}
@end

