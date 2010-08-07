//
//  GeneralTableViewController.m
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "UtilityMethods.h"

#import "GeneralTableViewController.h"

#import "MapsDetailViewController.h"
#import "TexLegeAppDelegate.h"
#import "TableDataSourceProtocol.h"

#import "CalendarDataSource.h"
#import "CalendarComboViewController.h"

#import "LinksMenuDataSource.h"
#import "LinksDetailViewController.h"
#import "MiniBrowserController.h"

@implementation GeneralTableViewController


@synthesize dataSource, detailViewController;
@synthesize menuButton, selectIndexPathOnAppear;

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
		//self.tableView = nil;
	self.dataSource = [[sourceClass alloc] initWithManagedObjectContext:context];
	self.title = [dataSource name];	
	// set the long name shown in the navigation bar
	//self.navigationItem.title=[dataSource navigationBarName];
}

- (void)dealloc {
	self.tableView = nil;
	self.dataSource = nil; 
	self.menuButton = nil;
	self.selectIndexPathOnAppear = nil;
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	if ([self.dataSource respondsToSelector:@selector(didReceiveMemoryWarning)])
		[self.dataSource performSelector:@selector(didReceiveMemoryWarning)];
	
	self.detailViewController = nil;
	self.selectIndexPathOnAppear = nil;
	[self resetStoredSelection];

    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)loadView {
	
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	CGRect tempFrame = [[UIScreen mainScreen] applicationFrame];
	self.tableView = [[UITableView alloc] initWithFrame:tempFrame 
														  style:[dataSource tableViewStyle]];
	
	// set the autoresizing mask so that the table will always fill the view
	self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	self.tableView.autoresizesSubviews = YES;
	
	// set the cell separator to a single straight line.
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.tableView.separatorColor = [UIColor lightGrayColor];
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	self.tableView.delegate = self;
	self.tableView.dataSource = dataSource;
	
	self.tableView.sectionIndexMinimumDisplayRowCount=15;
	
	// set the tableview as the controller view
	self.view = self.tableView;
}

-(void)viewDidLoad {
	[super viewDidLoad];
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
		self.tableView.allowsSelectionDuringEditing = YES;
	}
		
	TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
	if (appDelegate.savedLocation != nil && [[appDelegate.savedLocation objectAtIndex:0] integerValue] == [appDelegate indexForFunctionalViewController:self]) {
			// save off this level's selection to our AppDelegate
			//[self validateStoredSelection];
		NSInteger rowSelection = [[appDelegate.savedLocation objectAtIndex:1] integerValue];
		NSInteger sectionSelection = [[appDelegate.savedLocation objectAtIndex:2] integerValue];
		
		if (rowSelection != -1)
			self.selectIndexPathOnAppear = [NSIndexPath indexPathForRow:rowSelection inSection:sectionSelection];
	}
    
}


- (void)viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
	
	[self validateStoredSelection];
	
	if ([UtilityMethods isIPadDevice] && self.selectIndexPathOnAppear == nil) {
		NSIndexPath *currentIndexPath = [self.tableView indexPathForSelectedRow];
		if (currentIndexPath == nil && ![dataSource.name isEqualToString:@"Resources"])  {
			NSUInteger ints[2] = {0,0};
			currentIndexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
		}
		self.selectIndexPathOnAppear = currentIndexPath;
	}	
		// force the tableview to load
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self showPopoverMenus:[UtilityMethods isLandscapeOrientation]];
	
	if (self.selectIndexPathOnAppear)  {		// if we have prepared a particular selection, do it
		if (self.selectIndexPathOnAppear.row < [dataSource tableView:self.tableView numberOfRowsInSection:self.selectIndexPathOnAppear.section])
		{
			[self.tableView selectRowAtIndexPath:self.selectIndexPathOnAppear animated:animated scrollPosition:UITableViewScrollPositionTop];
			[self tableView:self.tableView didSelectRowAtIndexPath:self.selectIndexPathOnAppear];		
		}

	}	
	
	if (self.splitViewController == nil)
		[self resetStoredSelection];
	
}


#pragma -
#pragma UITableViewDelegate

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)newIndexPath {
	if (dataSource.name == @"Resources") { // just select the row, nothing special.
		[aTableView.delegate tableView:aTableView didSelectRowAtIndexPath:newIndexPath];
	}
}


- (NSIndexPath *)tableView:(UITableView *)aTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *rowToSelect = indexPath;
	if (dataSource.name == @"Resources" && aTableView.isEditing && indexPath.section == 0)
	{ 
		[aTableView deselectRowAtIndexPath:indexPath animated:YES];
		rowToSelect = nil;    
	}
		
	return rowToSelect;
}


// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {
	BOOL isSplitViewDetail = ([UtilityMethods isIPadDevice]) && (self.splitViewController != nil);

	UIViewController *openInController = (isSplitViewDetail) ? self.detailViewController : self;
	
	// deselect the new row using animation
	if ([UtilityMethods isIPadDevice] == NO)
		[aTableView deselectRowAtIndexPath:newIndexPath animated:animated];	
	
	if (!openInController) {
		NSLog(@"Error opening detail controller from GeneralTableViewController:didSelect ...");
		return;
	}
	
	if (isSplitViewDetail == NO)
		self.navigationController.toolbarHidden = YES;
		
	if (dataSource.name == @"Resources"){ // has it's own special controller...
		LinksMenuDataSource * tempDataSource = (LinksMenuDataSource *)dataSource;
		BOOL addLinkRow = [tempDataSource isAddLinkPlaceholderAtIndexPath:newIndexPath];
		
		if (addLinkRow || aTableView.isEditing) {
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
		else // we're not editing or adding web links, someone wants to really go somewhere
		{
			NSString * action = [tempDataSource getLinkForRowAtIndexPath:newIndexPath];
			
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
			}
		}
		
	}
	else if (dataSource.name == @"Meetings") {	
		if (!self.detailViewController) {
			self.detailViewController = [[CalendarComboViewController alloc] initWithNibName:@"CalendarComboViewController" bundle:nil];
		}
		
		NSArray *feedEntries = [dataSource feedEntriesForIndexPath:newIndexPath];
		if (feedEntries) {			
			if ([self.detailViewController respondsToSelector:@selector(setFeedEntries:)])
				[self.detailViewController setValue:feedEntries forKey:@"feedEntries"];
			NSArray *placeholderArray = [[NSArray alloc] initWithObjects:@"All upcoming meetings", @"House upcoming meetings",@"Senate upcoming meetings",@"Joint upcoming meetings", nil ];
			
			if (isSplitViewDetail == NO) {
					// push the detail view controller onto the navigation stack to display it
				((UIViewController *)self.detailViewController).hidesBottomBarWhenPushed = YES;
				
				[openInController.navigationController pushViewController:self.detailViewController animated:YES];
				[self.detailViewController searchDisplayController].searchBar.placeholder = [placeholderArray objectAtIndex:newIndexPath.row];
				self.detailViewController = nil;
			}		
			else
				[self.detailViewController searchDisplayController].searchBar.placeholder = [placeholderArray objectAtIndex:newIndexPath.row];
			[placeholderArray release];
		}
	}	
	else {
		if (dataSource.name != @"Maps")
			NSLog(@"GeneralTableViewController, unexpected datasource: %@", dataSource.name);

		// create an MapsDetailViewController. This controller will display the full size tile for the element
		if (self.detailViewController == nil) {
			self.detailViewController = [[MapsDetailViewController alloc] initWithNibName:@"MapsDetailViewController" bundle:nil];
		}
				
		CapitolMap *capitolMap = [dataSource capitolMapForIndexPath:newIndexPath];
		if (capitolMap) {
			[self.detailViewController setMap:capitolMap];
			if (isSplitViewDetail == NO) {
					// push the detail view controller onto the navigation stack to display it				
				[openInController.navigationController pushViewController:self.detailViewController animated:YES];
				self.detailViewController = nil;
			}
		}
	}
}

// the *user* selected a row in the table, so turn on animations and save their selection.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
	// they clicked a web link ... don't restore it or it might go to Safari on startup!
	if (dataSource.name == @"Resources") 
		[self resetStoredSelection];
	else // save off this item's selection to our AppDelegate
		[self setStoredSelectionWithRow:newIndexPath.row section:newIndexPath.section];
	
	[self tableView:aTableView didSelectRowAtIndexPath:newIndexPath withAnimation:YES];
	
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
		
		if (detailTable && dataSource.name == @"Meetings")
			[detailTable reloadData];		// don't we already do this in our own combo detail controller?
	}
}


#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { 	
	return YES;
}

#pragma mark -
#pragma mark Editing Table

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;

	if ([self.dataSource usesCoreData] && [self.dataSource canEdit]) {
		style = [self.dataSource tableView:aTableView editingStyleForRowAtIndexPath:indexPath];
    }
    return style;
}



- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	
    if ([dataSource usesCoreData] && [dataSource canEdit]) {
		[super setEditing:editing animated:animated];
		[self.navigationItem setHidesBackButton:editing animated:YES];

		[self.tableView setEditing:editing animated:YES];

		//[theTableView beginUpdates];
		[dataSource setEditing:editing animated:animated];
		//[theTableView endUpdates];

	}
}


- (NSIndexPath *)tableView:(UITableView *)aTableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	NSIndexPath * tempPath = nil;
    if ([dataSource usesCoreData] && [dataSource canEdit]) {
		tempPath = [dataSource tableView:aTableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
	}
	return tempPath;
}

@end
