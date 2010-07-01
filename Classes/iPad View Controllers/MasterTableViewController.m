//
//  MasterTableViewController.m
//  TexLege
//
//  Created by Gregory Combs on 6/28/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "MasterTableViewController.h"
#import "LegislatorDetailViewController.h"

@implementation MasterTableViewController
@synthesize legDetailViewController;
@synthesize dataSource;
@synthesize searchBar, m_searchDisplayController, chamberControl;

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
	
	self.tableView.dataSource = self.dataSource;
	self.dataSource.searchDisplayController = self.m_searchDisplayController;
	self.m_searchDisplayController.searchResultsDataSource = self.dataSource;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.rowHeight = 73.0f;
		
    //self.title=@"Legislators";
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	
	if (self.m_searchDisplayController == nil) {
		self.m_searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
	}
	self.m_searchDisplayController.delegate = self;
	self.m_searchDisplayController.searchResultsDelegate = self;
		
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	//if (self.legDetailViewController.legislator == nil)
	if ([self.tableView indexPathForSelectedRow] == nil)  {
		NSUInteger ints[2] = {0,0};
		NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
		[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
		self.legDetailViewController.legislator = [self.dataSource legislatorDataForIndexPath:indexPath];
	}
}

/*
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	// this is a hack so that the index does not show up on top of the search bar
	//if ([dataSource usesSearchbar]) {
	//	[self.searchDisplayController setActive:YES];
	//	[self.searchDisplayController setActive:NO];
	//}
}
 
*/
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
	//[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	self.legDetailViewController.legislator = [self.dataSource legislatorDataForIndexPath:indexPath];
}
//END:code.split.delegate



#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	self.chamberControl = nil;
	self.legDetailViewController = nil;
	self.dataSource = nil;
	
	self.searchDisplayController.searchResultsDataSource = nil;  // default is nil. delegate can provide
	self.searchDisplayController.searchResultsDelegate = nil;    // default is nil. delegate can provide
	self.searchDisplayController.delegate = nil;
	self.m_searchDisplayController = nil;
}


- (void)dealloc {
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

