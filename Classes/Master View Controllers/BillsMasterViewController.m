//
//  BillsMasterViewController.m
//  TexLege
//
//  Created by Gregory Combs on 2/6/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "BillsMasterViewController.h"
#import "UtilityMethods.h"

#import "TexLegeAppDelegate.h"
#import "TableDataSourceProtocol.h"

#import "MiniBrowserController.h"
#import "TexLegeTheme.h"

#import "BillsMenuDataSource.h"

#import "BillSearchDataSource.h"

@interface BillsMasterViewController (Private)
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
@end

@implementation BillsMasterViewController
@synthesize billSearchDS;

- (void) dealloc {
	[super dealloc];
}

- (NSString *)nibName {
	return [self viewControllerKey];
}

- (NSString *) viewControllerKey {
	return @"BillsMasterViewController";
}

/*- (void)loadView {	
	[super runLoadView];
}*/

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if (!billSearchDS)
		billSearchDS = [[[BillSearchDataSource alloc] initWithSearchDisplayController:self.searchDisplayController] retain];
	
	self.searchDisplayController.delegate = self;
	self.searchDisplayController.searchResultsDelegate = self;
	self.searchDisplayController.searchResultsDataSource = self.billSearchDS;

	//self.dataSource.searchDisplayController = self.searchDisplayController;
	//self.searchDisplayController.searchResultsDataSource = self.dataSource;
	
	self.searchDisplayController.searchBar.tintColor = [TexLegeTheme accent];
	//self.navigationItem.titleView = self.chamberControl;
	
	if (!self.selectObjectOnAppear && [UtilityMethods isIPadDevice])
		self.selectObjectOnAppear = [self firstDataObject];
}

- (void)viewDidUnload {
	[billSearchDS release];
	billSearchDS = nil;
	
	[super viewDidUnload];
}

- (Class)dataSourceClass {
	return [BillsMenuDataSource class];
}

- (void)viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
	
	[self.searchDisplayController.searchBar setHidden:NO];
	
	//// ALL OF THE FOLLOWING MUST *NOT* RUN ON IPHONE (I.E. WHEN THERE'S NO SPLITVIEWCONTROLLER
	
	if ([UtilityMethods isIPadDevice] && self.selectObjectOnAppear == nil) {
		id detailObject = self.detailViewController ? [self.detailViewController valueForKey:@"selectedMenu"] : nil;
		
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

#pragma -
#pragma UITableViewDelegate

// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {
	TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
	
	if (![UtilityMethods isIPadDevice])
		[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];
	
	BOOL isSplitViewDetail = ([UtilityMethods isIPadDevice]) && (self.splitViewController != nil);
	
	//if (!isSplitViewDetail)
	//	self.navigationController.toolbarHidden = YES;
	
	id dataObject = [self.dataSource dataObjectForIndexPath:newIndexPath];
	// save off this item's selection to our AppDelegate
	[appDelegate setSavedTableSelection:newIndexPath forKey:self.viewControllerKey];
	
	// create a BillsMenuDetailViewController. This controller will display the full size tile for the element
	if (self.detailViewController == nil) {
		if (!dataObject || [dataObject isKindOfClass:[NSDictionary class]])
			return;
		
		NSString *theClass = [dataObject objectForKey:@"class"];
		if (!theClass || !NSClassFromString(theClass))
			return;
		
		self.detailViewController = [[[NSClassFromString(theClass) alloc] initWithNibName:theClass bundle:nil] autorelease];
	}
	
	if (dataObject) {
		[self.detailViewController setValue:dataObject forKey:@"selectedMenu"];
		if (aTableView == self.searchDisplayController.searchResultsTableView) { // we've clicked in a search table
			[self searchBarCancelButtonClicked:nil];
		}
		if (isSplitViewDetail == NO) {
			// push the detail view controller onto the navigation stack to display it				
			[self.navigationController pushViewController:self.detailViewController animated:YES];
			self.detailViewController = nil;
		}
	}
}

#pragma mark -
#pragma mark Search Distplay Controller

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	if (_searchString) {
		[_searchString release];
		_searchString = nil;
	}
	
	if (searchString) {
		_searchString = [searchString retain];
		
		if ([_searchString length] > 3) {
			[self.billSearchDS startSearchWithString:_searchString chamber:self.searchDisplayController.searchBar.selectedScopeButtonIndex+1];
		}		
	}
	return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
	[self.billSearchDS startSearchWithString:_searchString chamber:searchOption+1];
	return NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
	if (_searchString) {
		[_searchString release];
		_searchString = nil;
	}
	_searchString = [[[NSString alloc] initWithString:@""] retain];

	self.searchDisplayController.searchBar.text = _searchString;
	[self.searchDisplayController setActive:NO animated:YES];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	////////self.dataSource.hideTableIndex = YES;
	// for some reason, these get zeroed out after we restart searching.
	self.searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;
	self.searchDisplayController.searchResultsTableView.backgroundColor = self.tableView.backgroundColor;
	self.searchDisplayController.searchResultsTableView.sectionIndexMinimumDisplayRowCount = self.tableView.sectionIndexMinimumDisplayRowCount;
	
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	////////self.dataSource.hideTableIndex = NO;
}

@end
