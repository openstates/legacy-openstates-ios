//
//  DistrictOfficeMasterViewController.m
//  Created by Gregory Combs on 8/23/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "DistrictMapMasterViewController.h"
#import "DistrictMapDataSource.h"
#import "DistrictMapObj+MapKit.h"
#import "MapViewController.h"
#import "UtilityMethods.h"
#import "TexLegeAppDelegate.h"
#import "TexLegeTheme.h"
#import "DistrictMapObj.h"
#import "TexLegeCoreDataUtils.h"

@interface DistrictMapMasterViewController (Private)
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
@end


@implementation DistrictMapMasterViewController
@synthesize chamberControl, sortControl, filterControls;

// Set this to non-nil whenever you want to automatically enable/disable the view controller based on network/host reachability
- (NSString *)reachabilityStatusKey {
	return @"googleConnectionStatus";
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Initialization

- (NSString *)nibName {
	return NSStringFromClass([self class]);
}

- (Class)dataSourceClass {
	return [DistrictMapDataSource class];
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
	self.sortControl.tintColor = [TexLegeTheme accent];
	self.searchDisplayController.searchBar.tintColor = [TexLegeTheme accent];
	self.navigationItem.titleView = self.filterControls;
	
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
		NSNumber *segIndex = [segPrefs objectForKey:@"DistrictMapChamberKey"];
		if (segIndex)
			self.chamberControl.selectedSegmentIndex = [segIndex integerValue];
		segIndex = [segPrefs objectForKey:@"DistrictMapSortTypeKey"];
		if (segIndex)
			self.sortControl.selectedSegmentIndex = [segIndex integerValue];
		
	}
}


#pragma mark -
#pragma mark Table view delegate

//START:code.split.delegate
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {
	TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
	
	//if (![UtilityMethods isIPadDevice])
		[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];
		
	
	id dataObject = [self.dataSource dataObjectForIndexPath:newIndexPath];
	
/*	if ([dataObject isKindOfClass:[NSManagedObject class]])
		[appDelegate setSavedTableSelection:[dataObject objectID] forKey:NSStringFromClass([self class])];
	else
		[appDelegate setSavedTableSelection:newIndexPath forKey:NSStringFromClass([self class])];
*/
	[appDelegate setSavedTableSelection:nil forKey:NSStringFromClass([self class])];
	
	DistrictMapObj *map = dataObject;

	if (!self.detailViewController) {
		MapViewController *tempVC = [[MapViewController alloc] init];
		self.detailViewController = tempVC;
		[tempVC release];
	}

	if (map) {
		MapViewController *mapVC = (MapViewController *)self.detailViewController;
		[mapVC view];
		
		MKMapView *mapView = mapVC.mapView;
		if (mapVC && mapView) {			
			[mapVC clearAnnotationsAndOverlays];

			[mapView addAnnotation:map];
			[mapVC moveMapToAnnotation:map];	
			[mapView performSelector:@selector(addOverlay:) withObject:[map polygon] afterDelay:1.0f];
		}
		if (aTableView == self.searchDisplayController.searchResultsTableView) { // we've clicked in a search table
			[self searchBarCancelButtonClicked:nil];
		}
		
		if (![UtilityMethods isIPadDevice]) {
			// push the detail view controller onto the navigation stack to display it				
			[self.navigationController pushViewController:self.detailViewController animated:YES];
			self.detailViewController = nil;
		}
		[[DistrictMapObj managedObjectContext] refreshObject:map mergeChanges:YES];
	}
	
}
//END:code.split.delegate


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	self.chamberControl = nil;
	self.sortControl = nil;
	self.filterControls = nil;
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
			[newDict setObject:segIndex forKey:@"DistrictMapChamberKey"];
			[[NSUserDefaults standardUserDefaults] setObject:newDict forKey:kSegmentControlPrefKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
			[newDict release];
		}
		
		[self.tableView reloadData];
	}
}

- (IBAction) sortType:(id)sender {
	if (sender == self.sortControl) {
		BOOL byDistrict = (self.sortControl.selectedSegmentIndex == 1);
		
		[(DistrictMapDataSource *) self.dataSource setByDistrict:byDistrict];
		[(DistrictMapDataSource *) self.dataSource sortByType:sender];
				
		NSDictionary *segPrefs = [[NSUserDefaults standardUserDefaults] objectForKey:kSegmentControlPrefKey];
		if (segPrefs) {
			NSNumber *segIndex = [NSNumber numberWithInteger:self.sortControl.selectedSegmentIndex];
			NSMutableDictionary *newDict = [segPrefs mutableCopy];
			[newDict setObject:segIndex forKey:@"DistrictMapSortTypeKey"];
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

