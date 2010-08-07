//
//  MasterTableViewController.m
//  TexLege
//
//  Created by Gregory Combs on 6/28/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "MasterTableViewController.h"
#import "LegislatorDetailViewController.h"
#import "LegislatorMasterTableViewCell.h"
#import "UtilityMethods.h"
#import "TexLegeAppDelegate.h"
#import "TexLegeTheme.h"

@interface MasterTableViewController (Private)
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
@end


@implementation MasterTableViewController
@synthesize detailViewController;
@synthesize dataSource, selectObjectOnAppear;
@synthesize chamberControl, menuButton;

#pragma mark -
#pragma mark Initialization

- (NSString *) viewControllerKey {
	return @"MasterTableViewController";
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
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self.dataSource;
	//self.tableView.rowHeight = 73.0f;

	self.dataSource.searchDisplayController = self.searchDisplayController;
	self.searchDisplayController.searchResultsDataSource = self.dataSource;
	
	if ([dataSource usesCoreData]) {
		NSManagedObjectID *objectID = [[TexLegeAppDelegate appDelegate] savedTableSelectionForKey:self.viewControllerKey];
		if (objectID)
			self.selectObjectOnAppear = [self.dataSource.managedObjectContext objectWithID:objectID];
	}
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
		
	if ([UtilityMethods isIPadDevice]) {
		self.navigationItem.leftBarButtonItem = self.menuButton;
	    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
		self.menuButton.target = [TexLegeAppDelegate appDelegate];
		self.menuButton.action = @selector(showOrHideMenuPopover:);
	}
	
    //self.title=@"Legislators";
    self.clearsSelectionOnViewWillAppear = NO;
	
	self.searchDisplayController.delegate = self;
	self.searchDisplayController.searchResultsDelegate = self;
	self.dataSource.searchDisplayController = self.searchDisplayController;
	self.searchDisplayController.searchResultsDataSource = self.dataSource;
	
	self.tableView.separatorColor = [TexLegeTheme separator];
	self.tableView.backgroundColor = [TexLegeTheme tableBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.chamberControl.tintColor = [TexLegeTheme segmentCtl];
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];
	self.searchDisplayController.searchBar.tintColor = [TexLegeTheme accent];
	self.navigationItem.titleView = self.chamberControl;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if (![UtilityMethods isIPadDevice])
		return;
	
	
	//// ALL OF THE FOLLOWING MUST NOT RUN ON IPHONE (I.E. WHEN THERE'S NO SPLITVIEWCONTROLLER
	
	// We don't want menus and such in our popover menu or search results table
	if ([UtilityMethods isLandscapeOrientation] == NO) {	
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.rightBarButtonItem = nil;
	}
	else {
		if (self.menuButton)
			self.navigationItem.leftBarButtonItem = self.menuButton;
		//self.menuButton = nil;
	}
	
	if (self.selectObjectOnAppear == nil) {
		LegislatorObj* legislator = self.detailViewController ? self.detailViewController.legislator : nil;
		if (!legislator) {
			NSIndexPath *currentIndexPath = [self.tableView indexPathForSelectedRow];
			if (!currentIndexPath) {			
				NSUInteger ints[2] = {0,0};	// just pick the first one then
				currentIndexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
			}
			legislator = [self.dataSource legislatorDataForIndexPath:currentIndexPath];				
		}
		self.selectObjectOnAppear = legislator;
	}	
	[self.tableView reloadData]; // this "fixes" an issue where it's using cached (bogus) values for our vote index sliders

	// END: IPAD ONLY
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (self.selectObjectOnAppear)  {		// if we have prepared a particular selection, do it
		if ([self.selectObjectOnAppear isKindOfClass:[LegislatorObj class]])
		{
			NSIndexPath *selectedPath = [self.dataSource.fetchedResultsController indexPathForObject:self.selectObjectOnAppear];
			[self.tableView selectRowAtIndexPath:selectedPath animated:animated scrollPosition:UITableViewScrollPositionTop];
			[self tableView:self.tableView didSelectRowAtIndexPath:selectedPath];
		}
		self.selectObjectOnAppear = nil;
	}	

	// We're on an iphone, without a splitview or popovers, so if we get here, let's stop
	if ([UtilityMethods isIPadDevice] == NO) {
		[[TexLegeAppDelegate appDelegate] setSavedTableSelection:nil forKey:self.viewControllerKey];
	}
}


#pragma mark -
#pragma mark Table view delegate

//START:code.split.delegate
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	LegislatorObj *legislator = [self.dataSource legislatorDataForIndexPath:indexPath];
	// save off this item's selection to our AppDelegate
	[[TexLegeAppDelegate appDelegate] setSavedTableSelection:[legislator objectID] forKey:self.viewControllerKey];

	if (self.splitViewController) {
		self.detailViewController.legislator = legislator;
		
		if (aTableView == self.searchDisplayController.searchResultsTableView) { // we've clicked in a search table
			[self searchBarCancelButtonClicked:nil];
		}
		
		// if we have a stack of view controllers and someone selected a new cell from our master list, 
		//	lets go all the way back to accomodate their selection, and scroll to the top.
		if ([self.detailViewController.navigationController.viewControllers count] > 1) { 
			CGRect topish = CGRectMake(0, 0, 10, 10);
			[self.detailViewController.tableView scrollRectToVisible:topish animated:YES];
		}
	}
	else {
		if (self.detailViewController == nil)
			self.detailViewController = [[LegislatorDetailViewController alloc] initWithNibName:@"LegislatorDetailViewController" bundle:nil];

		self.detailViewController.legislator = legislator;
		[self.navigationController pushViewController:self.detailViewController animated:YES];
		self.detailViewController = nil;

	}

	
}
//END:code.split.delegate

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL useDark = (indexPath.row % 2 == 0);
	[((LegislatorMasterTableViewCell *)cell) setUseDarkBackground:useDark];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	[[TexLegeAppDelegate appDelegate] setSavedTableSelection:nil forKey:self.viewControllerKey];

	//[self searchBarCancelButtonClicked:self.searchDisplayController.searchBar];
	self.detailViewController = nil;
    [super didReceiveMemoryWarning];	
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	self.detailViewController = nil;
	self.menuButton = nil;	
	self.selectObjectOnAppear = nil;
}


- (void)dealloc {
	self.chamberControl = nil;
	self.dataSource = nil;
	self.selectObjectOnAppear = nil;
	self.detailViewController = nil;
	self.menuButton = nil;
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
	self.searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;
	self.searchDisplayController.searchResultsTableView.backgroundColor = self.tableView.backgroundColor;
	self.searchDisplayController.searchResultsTableView.sectionIndexMinimumDisplayRowCount = self.tableView.sectionIndexMinimumDisplayRowCount;
	
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	[self.dataSource setHideTableIndex:NO];	
}
@end

