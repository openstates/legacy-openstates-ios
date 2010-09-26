//
//  MasterTableViewController.m
//  TexLege
//
//  Created by Gregory Combs on 6/28/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "LegislatorsDataSource.h"
#import "LegislatorMasterViewController.h"
#import "LegislatorDetailViewController.h"
#import "UtilityMethods.h"
#import "TexLegeAppDelegate.h"
#import "TexLegeTheme.h"
#import "UIDevice-Hardware.h"
#import "LegislatorMasterCell.h"

@interface LegislatorMasterViewController (Private)
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
- (IBAction)redisplayVisibleCells:(id)sender;

@end


@implementation LegislatorMasterViewController
@synthesize chamberControl;

#pragma mark -
#pragma mark Initialization

- (NSString *) viewControllerKey {
	return @"LegislatorMasterViewController";
}

- (NSString *)nibName {
	return [self viewControllerKey];
}


- (Class)dataSourceClass {
	return [LegislatorsDataSource class];
}


- (void)configureWithManagedObjectContext:(NSManagedObjectContext *)context {
	[super configureWithManagedObjectContext:context];	
	if (!self.selectObjectOnAppear && [UtilityMethods isIPadDevice])
		self.selectObjectOnAppear = [self firstDataObject];
}


- (void)dealloc {
	self.chamberControl = nil;
#ifdef AUTOMATED_TESTING_CHARTS
	[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"AUTOMATED_TESTING_CHARTS"];
#endif
    [super dealloc];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
		
#ifdef AUTOMATED_TESTING_CHARTS
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(automatedChartsNext:) name:@"AUTOMATED_TESTING_CHARTS" object:nil];
#endif
	
	self.tableView.rowHeight = 73.0f;
	
	if ([UtilityMethods isIPadDevice])
	    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	
	self.searchDisplayController.delegate = self;
	self.searchDisplayController.searchResultsDelegate = self;
	//self.dataSource.searchDisplayController = self.searchDisplayController;
	//self.searchDisplayController.searchResultsDataSource = self.dataSource;
	
	self.chamberControl.tintColor = [TexLegeTheme accent];
	self.searchDisplayController.searchBar.tintColor = [TexLegeTheme accent];
	self.navigationItem.titleView = self.chamberControl;
}

- (void)viewDidUnload {
	self.chamberControl = nil;
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	NSDictionary *segPrefs = [[NSUserDefaults standardUserDefaults] objectForKey:kSegmentControlPrefKey];
	if (segPrefs) {
		NSNumber *segIndex = [segPrefs objectForKey:[self viewControllerKey]];
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
		[self.tableView reloadData]; // popovers look like shit without this
	
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

#ifdef AUTOMATED_TESTING_CHARTS
NSIndexPath *current = nil;

- (void) automatedChartsNext:(id)sender {
	//NSManagedObjectID *theID = sender;
	//id object = [self.managedObjectContext objectWithID:theID];
	
	if (!current)
		current = [[NSIndexPath indexPathForRow:0 inSection:0] retain];
	
	NSInteger numSections = [self.dataSource numberOfSectionsInTableView:self.tableView];
	NSInteger numRowsInSection = [self.dataSource tableView:self.tableView  numberOfRowsInSection:current.section];

	NSInteger theRow = current.row;
	NSInteger theSection = current.section;
	
	BOOL stop = NO;
	if ((theRow + 1) < numRowsInSection)
		theRow++;
	else if ((theSection+1) < numSections) {
		theRow = 0;
		theSection++;
	}
	else {
		stop = YES;
		[current release];
	}
	
	if (!stop) {
		NSIndexPath *newPath = [NSIndexPath indexPathForRow:theRow inSection:theSection];
		[current release];
		current = [newPath retain];
		UINavigationController *nav = [self navigationController];
		//if (nav && [nav.viewControllers count]>1)
			[nav popToRootViewControllerAnimated:NO];
		
		[self.tableView selectRowAtIndexPath:newPath animated:NO scrollPosition:UITableViewScrollPositionTop];
		[self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:newPath];
	}
	
}
#endif

#pragma mark -
#pragma mark able view delegate

//START:code.split.delegate
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {
	TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
	
	if (![UtilityMethods isIPadDevice])
		[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];
	
	BOOL isSplitViewDetail = ([UtilityMethods isIPadDevice]);
	
	id dataObject = [self.dataSource dataObjectForIndexPath:newIndexPath];
	if (!dataObject)
		return;
	
	if ([dataObject isKindOfClass:[NSManagedObject class]])
		[appDelegate setSavedTableSelection:[dataObject objectID] forKey:self.viewControllerKey];
	else
		[appDelegate setSavedTableSelection:newIndexPath forKey:self.viewControllerKey];
	
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
			[newDict setObject:segIndex forKey:[self viewControllerKey]];
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

