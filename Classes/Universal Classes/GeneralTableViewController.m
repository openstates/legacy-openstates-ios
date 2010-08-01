//
//  GeneralTableViewController.m
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "UtilityMethods.h"

#import "GeneralTableViewController.h"

#import "CommitteeDetailViewController.h"
#import "LegislatorDetailViewController.h"
#import "LegislatorMasterTableViewCell.h"

#import "MapsDetailViewController.h"
#import "TexLegeAppDelegate.h"
#import "TableDataSourceProtocol.h"
#import "DirectoryDataSource.h"
#import "CommitteesDataSource.h"

#import "CalendarDataSource.h"
#import "CalendarComboViewController.h"

#import "LinksMenuDataSource.h"
#import "LinksDetailViewController.h"
#import "MiniBrowserController.h"

/*
 Predefined colors to alternate the background color of each cell row by row
 (see tableView:cellForRowAtIndexPath: and tableView:willDisplayCell:forRowAtIndexPath:).
 */
#define DARK_BACKGROUND  [UIColor colorWithRed:151.0/255.0 green:152.0/255.0 blue:155.0/255.0 alpha:1.0]
#define LIGHT_BACKGROUND [UIColor colorWithRed:172.0/255.0 green:173.0/255.0 blue:175.0/255.0 alpha:1.0]


@implementation GeneralTableViewController


@synthesize theTableView, dataSource, detailViewController;
@synthesize menuButton;

@synthesize searchBar, savedSearchTerm, searchWasActive;
#if _searchcontroller_
@synthesize searchController, savedScopeButtonIndex;
#endif


- (void)setStoredSelectionWithRow:(NSInteger)row section:(NSInteger)section {
	// we have moved to level 1, remove it's stored row/section selection
	TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
	if (appDelegate.savedLocation != nil) {
		NSInteger functionIndex = [appDelegate indexForFunctionalViewController:self];
		//[appDelegate.savedLocation replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:appDelegate.tabBarController.selectedIndex]]; //tab
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
	TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
	NSInteger functionIndex = [appDelegate indexForFunctionalViewController:self];
	//	NSInteger tabSelection = appDelegate.tabBarController.selectedIndex;

	NSInteger tabSavedSelection = [[appDelegate.savedLocation objectAtIndex:0] integerValue];
	
	if (functionIndex != tabSavedSelection) { // we're out of sync with the selection, clear the unknown
		[self resetStoredSelection];
	}
}	


- (void)configureWithDataSourceClass:(Class)sourceClass andManagedObjectContext:(NSManagedObjectContext *)context {
	theTableView = nil;
	self.dataSource = [[sourceClass alloc] initWithManagedObjectContext:context];
	self.title = [dataSource name];	
	// set the long name shown in the navigation bar
	//self.navigationItem.title=[dataSource navigationBarName];
}

- (void)dealloc {
	self.theTableView = nil;
	self.dataSource = nil; 
	self.searchBar = nil;
	self.menuButton = nil;
			
#if _searchcontroller_
	self.searchController = nil;
#endif
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	if ([self.dataSource respondsToSelector:@selector(didReceiveMemoryWarning)])
		[self.dataSource performSelector:@selector(didReceiveMemoryWarning)];
	
	[self resetStoredSelection];

    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)loadView {
	
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	CGRect tempFrame = [[UIScreen mainScreen] applicationFrame];
	UITableView *tableView = [[UITableView alloc] initWithFrame:tempFrame 
														  style:[dataSource tableViewStyle]];
	
	// set the autoresizing mask so that the table will always fill the view
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	tableView.autoresizesSubviews = YES;
	
	// set the cell separator to a single straight line.
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.separatorColor = [UIColor lightGrayColor];
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	tableView.delegate = self;
	tableView.dataSource = dataSource;
	
	tableView.sectionIndexMinimumDisplayRowCount=15;
	
	if (dataSource.name == @"Directory")
		tableView.rowHeight = dataSource.rowHeight;

	// set the tableview as the controller view
    self.theTableView = tableView;
	self.view = tableView;
	[tableView release];	
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)newIndexPath {
	if (dataSource.name == @"Resources") { // just select the row, nothing special.
		[self tableView:tableView didSelectRowAtIndexPath:newIndexPath];
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (dataSource.name == @"Resources"){ // has it's own special controller...
		 return [(LinksMenuDataSource *) dataSource tableView:tableView willSelectRowAtIndexPath:indexPath];
	}
	else 
		return indexPath;
}	

// the user selected a row in the table.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {
	BOOL isSplitViewDetail = ([UtilityMethods isIPadDevice]) && (self.splitViewController != nil);

	UIViewController *openInController = (isSplitViewDetail) ? self.detailViewController : self;
	
	// deselect the new row using animation
	if ([UtilityMethods isIPadDevice] == NO)
		[tableView deselectRowAtIndexPath:newIndexPath animated:animated];	
	
	if (!openInController) {
		NSLog(@"Error opening detail controller from GeneralTableViewController:didSelect ...");
		return;
	}
	
	if (isSplitViewDetail == NO)
		self.navigationController.toolbarHidden = YES;
		
	if (dataSource.name == @"Resources"){ // has it's own special controller...
		LinksMenuDataSource * tempDataSource = (LinksMenuDataSource *)dataSource;
		BOOL addLinkRow = [tempDataSource isAddLinkPlaceholderAtIndexPath:newIndexPath];
		
		if (addLinkRow || theTableView.isEditing) {
			// we're editing links, or adding new ones.
			
			LinksDetailViewController *linksDetail = 
			[[LinksDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
			
			// If we got a new view controller, push it .
			if (linksDetail) {
				linksDetail.fetchedResultsController = [dataSource fetchedResultsController];
				
				if (!addLinkRow) { // we're editing an existing link
					linksDetail.link = [[linksDetail fetchedResultsController] objectAtIndexPath:newIndexPath];
				}
				
				[[openInController navigationController] pushViewController:linksDetail animated:animated];

				[linksDetail release];
			}
		}
		else // we're not editing web links
		{
			NSArray * actionArray = [tempDataSource getActionForRowAtIndexPath:newIndexPath];
			
			NSString * action = [NSString stringWithString:[actionArray objectAtIndex:1]];
			NSNumber * destination = [actionArray objectAtIndex:0];
			TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
			
			if ([action isEqualToString:@"aboutView"]) {
				if (appDelegate != nil) [appDelegate showAboutDialog:openInController];
			}
			else if ([action isEqualToString:@"voteInfoView"]) {
				if (appDelegate != nil) [appDelegate showVoteInfoDialog:openInController];
			}
			else {
				NSURL *url = [UtilityMethods safeWebUrlFromString:action];
				
				if ([UtilityMethods canReachHostWithURL:url]) { // got a network connection
					if (destination.integerValue == URLAction_internalBrowser) {
						MiniBrowserController *mbc = nil;
						
						// we might already have a browser loaded and ready to go
						if (self.detailViewController && [self.detailViewController isKindOfClass:[MiniBrowserController class]]) {
							mbc = (MiniBrowserController *) self.detailViewController;
							[mbc loadURL:url];
						}
						else
							mbc = [MiniBrowserController sharedBrowserWithURL:url];

						if (isSplitViewDetail == NO)
							[mbc display:openInController];
					}
					else { // (destination == URLAction_externalBrowser)
						[UtilityMethods openURLWithTrepidation:url];
					}
				}
			}
		}
		
	}
	else if (dataSource.name == @"Committees") {
		if (self.detailViewController == nil)
			self.detailViewController = [[CommitteeDetailViewController alloc] initWithNibName:@"CommitteeDetailViewController" bundle:nil];
		
		[self.detailViewController setValue:[dataSource committeeDataForIndexPath:newIndexPath] forKey:@"committee"];
		
		if (isSplitViewDetail == NO) {
			// push the detail view controller onto the navigation stack to display it
			[self.navigationController pushViewController:self.detailViewController animated:YES];
			self.detailViewController = nil;
		}		
	}
	else if (dataSource.name == @"Directory") {
		if (self.detailViewController == nil)	// just assume it's a typical legislator detail (could be corePlot though)
			self.detailViewController = [[LegislatorDetailViewController alloc] initWithNibName:@"LegislatorDetailViewController" bundle:nil];

		if ([self.detailViewController respondsToSelector:@selector(setLegislator:)])
			[self.detailViewController performSelector:@selector(setLegislator:) withObject:[dataSource legislatorDataForIndexPath:newIndexPath]];
		
		//((LegislatorDetailViewController *)self.detailViewController).legislator = [dataSource legislatorDataForIndexPath:newIndexPath];
		//[self.detailViewController setValue:[dataSource legislatorDataForIndexPath:newIndexPath] forKey:@"legislator"];
		
		if (isSplitViewDetail == NO) {
			// push the detail view controller onto the navigation stack to display it
			[openInController.navigationController pushViewController:self.detailViewController animated:YES];
			self.detailViewController = nil;
		}
	}
	else if (dataSource.name == @"Meetings") {
		if (self.detailViewController == nil) {
			if ([UtilityMethods isIPadDevice])
				self.detailViewController = [[CalendarComboViewController alloc] initWithNibName:@"CalendarComboViewController" bundle:nil];
			else
				self.detailViewController = [[TKCalendarMonthTableViewController alloc] init];
		}
		if ([self.detailViewController respondsToSelector:@selector(setFeedEntries:)])
			[self.detailViewController setValue:[dataSource feedEntriesForIndexPath:newIndexPath] forKey:@"feedEntries"];
		
		if (isSplitViewDetail == NO) {
			// push the detail view controller onto the navigation stack to display it
			[self.navigationController pushViewController:self.detailViewController animated:YES];
			self.detailViewController = nil;
		}		
	}	
	else {
		if (dataSource.name != @"Maps")
			NSLog(@"GeneralTableViewController, unexpected datasource: %@", dataSource.name);

		// create an MapsDetailViewController. This controller will display the full size tile for the element
		if (self.detailViewController == nil) {
			self.detailViewController = [[MapsDetailViewController alloc] initWithNibName:@"MapsDetailViewController" bundle:nil];
		}
				
		[self.detailViewController setMap:[dataSource capitolMapForIndexPath:newIndexPath]];
		
		if (isSplitViewDetail == NO) {
			// push the detail view controller onto the navigation stack to display it
			[[self navigationController] pushViewController:self.detailViewController animated:animated];
			self.detailViewController = nil;
		}
	}
}

// the *user* selected a row in the table, so turn on animations and save their selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
	// they clicked a web link ... don't restore it or it might go to Safari on startup!
	if (dataSource.name == @"Resources") 
		[self resetStoredSelection];
	else // save off this item's selection to our AppDelegate
		[self setStoredSelectionWithRow:newIndexPath.row section:newIndexPath.section];
	
	[self tableView:tableView didSelectRowAtIndexPath:newIndexPath withAnimation:YES];
	
	// if we have a stack of view controllers and someone selected a new cell from our master list, 
	//	lets go all the way back to accomodate their selection, and scroll to the top.
	if (self.splitViewController) {
		UITableView *detailTable = nil;
		UINavigationController *detailNav = nil;
		if ([self.detailViewController respondsToSelector:@selector(tableView)])
			detailTable = [self.detailViewController performSelector:@selector(tableView)];
		if ([self.detailViewController respondsToSelector:@selector(navigationController)])
			detailNav = [self.detailViewController performSelector:@selector(navigationController)];
		
		if (detailTable && detailNav) {
			if ([detailNav.viewControllers count] > 1) { 
				CGRect guessTop = CGRectMake(0, 0, 10.0f, 10.0f);
				[detailNav popToRootViewControllerAnimated:YES];
				[detailTable scrollRectToVisible:guessTop animated:YES];
			}
		}
	}
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

	if (self.dataSource.name == @"Directory") {
		// let's override some of the datasource's settings ... specifically, the background color.
		cell.backgroundColor = ((LegislatorMasterTableViewCell *)cell).useDarkBackground ? DARK_BACKGROUND : LIGHT_BACKGROUND;
	}
}

- (void)showPopoverMenus:(BOOL)show {
	if (self.splitViewController && show) {
		TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
		if (self.menuButton == nil) {
			self.menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:appDelegate 
															  action:@selector(showOrHideMenuPopover:)];
		}
		[self.navigationItem setLeftBarButtonItem:self.menuButton animated:YES];
	}
	else {
		[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	}
}

-(void)viewWillAppear:(BOOL)animated
{
	
	[self validateStoredSelection];

	if (/*[UtilityMethods isIPadDevice] == NO &&*/ [dataSource usesToolbar])
		self.navigationController.toolbarHidden = NO;
	
	[self showPopoverMenus:[UtilityMethods isLandscapeOrientation]];
	
	if ([UtilityMethods isIPadDevice]) {
		if ([self.theTableView indexPathForSelectedRow] == nil && ![dataSource.name isEqualToString:@"Resources"])  {
			NSUInteger ints[2] = {0,0};
			NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
			[self.theTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
			[self tableView:self.theTableView didSelectRowAtIndexPath:indexPath];
			//self.detailViewController.legislator = [self.dataSource legislatorDataForIndexPath:indexPath];
		}
	}	
	
	if ([dataSource usesSearchbar]) {
		
		if (self.searchBar == nil) {
			self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectZero] retain];
			self.searchBar.placeholder = @"Search";	
			self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo; // Don't get in the way of user typing.
			self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone; // Don't capitalize each word.
			self.searchBar.delegate = self; // Become delegate to detect changes in scope.
			self.searchBar.contentMode = UIViewContentModeTopLeft;
			self.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"All", @"House", @"Senate", nil];
			//self.searchBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
			self.searchBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
			//self.searchBar.tintColor = [[UIColor alloc] initWithRed:0.75 green:0.80 blue:0.80 alpha:1.0];
			self.searchBar.barStyle = UIBarStyleBlack;
			self.searchBar.showsScopeBar = NO;
			[self.searchBar sizeToFit];

		}
		CGRect searchBounds = self.searchBar.bounds;
		searchBounds.size.width = self.view.bounds.size.width;
		self.searchBar.bounds = searchBounds;
		
		
#if _searchcontroller_
		if (self.searchController == nil) {
			self.searchController = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] retain];
			[self.searchController setSearchResultsDataSource:dataSource];
			[self.searchController setSearchResultsDelegate:self];
			[self.searchController setDelegate:self];
		}
		[self.view addSubview:self.searchController.searchBar];
		[self.dataSource setHideTableIndex:YES];

#else
		self.navigationItem.titleView = self.searchBar;
#endif
		
		self.navigationController.navigationBar.clipsToBounds = TRUE;
		
	}
	
	// force the tableview to load
	[theTableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
	if ([UtilityMethods isIPadDevice] == NO && [dataSource usesSearchbar]) {
		self.navigationItem.titleView = nil;
	}
}

-(void)viewDidLoad {
	
	//self.clearsSelectionOnViewWillAppear = NO;

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
	
	if ([dataSource canEdit]) { // later change this to "usesEditing" or something
	    self.navigationItem.rightBarButtonItem = self.editButtonItem;		
		self.theTableView.allowsSelectionDuringEditing = YES;
	}

	if ([dataSource usesToolbar]) {
		[self toolBarSetup];
	}
	
	if ([dataSource usesSearchbar])
	{		
		// Restore search settings if they were saved in didReceiveMemoryWarning.
		if (self.savedSearchTerm)
		{
#if _searchcontroller_
			[self.searchController setActive:self.searchWasActive];
			[self.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
#endif
			[self.searchBar setText:savedSearchTerm];
			self.savedSearchTerm = nil;
		}
	}	
	
	TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];

	if (appDelegate.savedLocation != nil) {
		// save off this level's selection to our AppDelegate
		[self validateStoredSelection];
		NSInteger rowSelection = [[appDelegate.savedLocation objectAtIndex:1] integerValue];
		NSInteger sectionSelection = [[appDelegate.savedLocation objectAtIndex:2] integerValue];
		
		//debug_NSLog(@"Restoring Selection: Row: %d    Section: %d", rowSelection, sectionSelection);
		
		if (rowSelection != -1) {
			NSIndexPath *selectionPath = [NSIndexPath indexPathForRow:rowSelection inSection:sectionSelection];
			
			[self.theTableView selectRowAtIndexPath:selectionPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
			[self tableView:self.theTableView didSelectRowAtIndexPath:selectionPath withAnimation:NO];
			
		}
	}
    
}

- (void)viewDidAppear:(BOOL)animated {
#if _searchcontroller_
	// this is a hack so that the index does not show up on top of the search bar
	if ([dataSource usesSearchbar]) {
		[self.searchDisplayController setActive:YES];
		[self.searchDisplayController setActive:NO];
		[super viewDidAppear:animated];
	}
#endif
	
	if (self.splitViewController == nil)
		[self resetStoredSelection];
	
}


#pragma mark -
#pragma mark ToolBar Methods

- (void) toolBarSetup {
	
	if ( [dataSource usesToolbar])
	{
		UIBarButtonItem *flexLeft = [[UIBarButtonItem alloc] 
									 initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
									 target:nil action:nil];
		UIBarButtonItem *flexRight = [[UIBarButtonItem alloc] 
									  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
									  target:nil action:nil];
		UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:
										  [NSArray arrayWithObjects:@"All", @"House", @"Senate", nil]];
		[segControl addTarget:self action:@selector(toolbarAction:) forControlEvents:UIControlEventValueChanged];
		segControl.selectedSegmentIndex = 0;	
		
		segControl.segmentedControlStyle = UISegmentedControlStyleBar;
		segControl.backgroundColor = [UIColor clearColor];
		segControl.tintColor = [UIColor darkGrayColor];
		//segControl.contentMode = UIViewContentModeScaleToFill; //****
		//segControl.autoresizesSubviews = YES;
		//segControl.autoresizingMask =  (UIViewAutoresizingFlexibleWidth);
		//[segControl sizeToFit];	
		//	CGRect segControlFrame = CGRectMake(5.0f,0.0f, 
		//			self.navigationController.toolbar.bounds.size.width - (5.0f * 2.0), 40.0f);
		CGRect segControlFrame = segControl.bounds;
		segControlFrame.size.width = 280.0f;
		segControl.bounds = segControlFrame;
		
		UIBarButtonItem *plainButton = [[UIBarButtonItem alloc]
										initWithCustomView:segControl];
		
		NSArray *items = [NSArray arrayWithObjects: flexLeft, plainButton, flexRight, nil];
		
		self.toolbarItems = items;
		self.navigationController.toolbarHidden = NO;
		self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
		
		[flexLeft release];
		[flexRight release];
		[segControl release];
		[plainButton release]; 
	}
}


- (void)toolbarAction:(id)sender
{
	if ( [dataSource usesToolbar] )
	{
		[self filterContentForSearchText:self.searchBar.text scope:[sender selectedSegmentIndex]];
		[self.theTableView reloadData];
	}
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[(DirectoryDataSource *)self.dataSource setFilterChamber:scope];
	
	// start filtering names...
	if (searchText.length > 0) {
		[(DirectoryDataSource *)self.dataSource setFilterByString:searchText];
	}
	else {
		[(DirectoryDataSource *)self.dataSource removeFilter];
	}
	
}


#pragma mark -
#pragma mark SearchBar Methods

#if _searchcontroller_ == 0

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self.searchBar setShowsCancelButton:YES animated:YES];
	
	if (searchText.length > 0)
		[self.dataSource setFilterByString:searchText];  // start filtering names...
	else
		[self.dataSource removeFilter];
	
	[self.theTableView reloadData];

}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {                     // called when text starts editing
	[self.dataSource setHideTableIndex:YES];
	[self.searchBar setShowsCancelButton:YES animated:YES];	
	//[self.theTableView reloadData];
	
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar { // called when text ends editing
	if([self.searchBar.text isEqualToString:@""]) {
		[self.dataSource setHideTableIndex:NO];
		[self.searchBar setShowsCancelButton:NO animated:YES];
	}
	[self.theTableView reloadData];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {                     // called when keyboard search button pressed
	//[self.searchBar setShowsCancelButton:NO animated:YES];
	[self.searchBar resignFirstResponder];
}
#endif

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
	self.searchBar.text = @"";
	[self.dataSource removeFilter];

#if _searchcontroller_ == 0
	[self.dataSource setHideTableIndex:NO];
#endif
	
	[self.searchBar setShowsCancelButton:NO animated:YES];
	[self.searchBar setNeedsDisplay];
	[self.searchBar resignFirstResponder];
}


#if _searchcontroller_

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
	// Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:searchOption];
    return YES;  // Return YES to cause the search result table view to be reloaded.
}


#endif

#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
	return YES;
}

#pragma mark -
#pragma mark Editing Table

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;

	if ([dataSource usesCoreData] && [dataSource canEdit]) {
		style = [dataSource tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    }
    return style;
}



- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	
    if ([dataSource usesCoreData] && [dataSource canEdit]) {
		[super setEditing:editing animated:animated];
		[self.navigationItem setHidesBackButton:editing animated:YES];

		[theTableView setEditing:editing animated:YES];

		//[theTableView beginUpdates];
		[dataSource setEditing:editing animated:animated];
		//[theTableView endUpdates];

	}
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	NSIndexPath * tempPath = nil;
    if ([dataSource usesCoreData] && [dataSource canEdit]) {
		tempPath = [dataSource tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
	}
	return tempPath;
}

@end
