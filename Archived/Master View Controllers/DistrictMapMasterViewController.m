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
#import "SLFDataModels.h"
#import "LegislatorCell.h"

#import "MapViewController.h"
#import "UtilityMethods.h"
#import "SLFPersistenceManager.h"
#import "TexLegeTheme.h"

@interface DistrictMapMasterViewController (Private)
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
- (IBAction)redisplayVisibleCells:(id)sender;
@end


@implementation DistrictMapMasterViewController
@synthesize chamberControl, sortControl, filterControls;

#pragma mark -
#pragma mark Main Menu Info

+ (NSString *)name
{ return NSLocalizedStringFromTable(@"District Maps", @"StandardUI", @"Short name for district maps tab"); }

- (NSString *)navigationBarName 
{ return [self name]; }

+ (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"73-radar-inv"]; }

///////////////////////////////////////////////


// Set this to non-nil whenever you want to automatically enable/disable the view controller based on network/host reachability
- (NSString *)reachabilityStatusKey {
	return @"googleConnectionStatus";
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
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)dealloc {
	self.chamberControl = nil;
	self.sortControl = nil;
	self.filterControls = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.rowHeight = 73.f;
    
    DistrictMapDataSource *dsource = (DistrictMapDataSource *)self.dataSource;
    [dsource loadData];
	
	if ([UtilityMethods isIPadDevice])
	    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	
	self.searchDisplayController.delegate = self;
	self.searchDisplayController.searchResultsDelegate = self;
	
	self.chamberControl.tintColor = [TexLegeTheme accent];
	self.sortControl.tintColor = [TexLegeTheme accent];
	self.searchDisplayController.searchBar.tintColor = [TexLegeTheme accent];
	self.navigationItem.titleView = self.filterControls;
	
}

- (void)viewDidUnload {
    self.chamberControl = nil;
    self.sortControl = nil;
    self.filterControls = nil;
	[super viewDidUnload];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DistrictMapDataSource *dsource = (DistrictMapDataSource *)self.dataSource;
    SLFState *state = [SLFState findFirstByAttribute:@"stateID" withValue:dsource.stateID];
        //SLFState *state = [[StateMetaLoader sharedStateMeta] selectedState];
    NSInteger index = 0;
    for (SLFChamber *chamber in state.chambers) {
        [self.chamberControl setTitle:chamber.shortName forSegmentAtIndex:index];
        index++;
    }
    
	NSDictionary *segPrefs = [[NSUserDefaults standardUserDefaults] objectForKey:kSegmentControlPrefKey];
	if (segPrefs) {
		NSNumber *segIndex = [segPrefs objectForKey:@"DistrictMapChamberKey"];
		if (segIndex)
			self.chamberControl.selectedSegmentIndex = [segIndex integerValue];
		segIndex = [segPrefs objectForKey:@"DistrictMapSortTypeKey"];
		if (segIndex)
			self.sortControl.selectedSegmentIndex = [segIndex integerValue];
	}
    
    if ([UtilityMethods isIPadDevice])
		[self.tableView reloadData]; // popovers look bad without this

    [self redisplayVisibleCells:nil];	
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
	
    [aTableView deselectRowAtIndexPath:newIndexPath animated:YES];
		
    BOOL isSplitViewDetail = ([UtilityMethods isIPadDevice]);

	id dataObject = [self.dataSource dataObjectForIndexPath:newIndexPath];
	if (!dataObject || NO == [dataObject isKindOfClass:[SLFDistrict class]]) {
		return;
    }

    [[SLFPersistenceManager sharedPersistence] setTableSelection:nil forKey:NSStringFromClass([self class])];

    MapViewController *mapVC = self.detailViewController;
	if (mapVC == nil) {
		mapVC = [[[MapViewController alloc] init] autorelease];
	}
        
    [mapVC setMapDetailObject:dataObject];

    if (!isSplitViewDetail) {
        // push the detail view controller onto the navigation stack to display it				
        [self.navigationController pushViewController:mapVC animated:YES];
        self.detailViewController = nil;
    }
    
    if (aTableView == self.searchDisplayController.searchResultsTableView) { // we've clicked in a search table
        [self searchBarCancelButtonClicked:self.searchDisplayController.searchBar];
    }
/*    
	if (map) {
		MapViewController *mapVC = (MapViewController *)self.detailViewController;
		[mapVC view];
		
		MKMapView *mapView = mapVC.mapView;
		if (mapVC && mapView) {			
			[mapVC clearAnnotationsAndOverlays];

			[mapView addAnnotation:map];
			[mapVC moveMapToAnnotation:map];	
			[mapView performSelector:@selector(addOverlay:) withObject:map.districtPolygon afterDelay:1.0f];
		}
		if (aTableView == self.searchDisplayController.searchResultsTableView) { // we've clicked in a search table
			[self searchBarCancelButtonClicked:nil];
		}
		
		if (![UtilityMethods isIPadDevice]) {
			// push the detail view controller onto the navigation stack to display it				
			[self.navigationController pushViewController:self.detailViewController animated:YES];
			self.detailViewController = nil;
		}
		[[SLFDistrict managedObjectContext] refreshObject:map mergeChanges:YES];
	}
	*/
}
//END:code.split.delegate

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL useDark = (indexPath.row % 2 == 0);
    
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
    
}

#pragma mark -
#pragma mark Filtering and Searching

#pragma mark -
#pragma mark Filtering and Searching

- (void)stateChanged:(NSNotification *)notification {
    [super stateChanged:notification];
    
    [self filterChamber:notification];
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString*)searchString searchScope:(NSInteger)searchOption {
    
    NSPredicate *predicate = nil;
    DistrictMapDataSource *dsource = (DistrictMapDataSource *)self.dataSource;
    SLFState *state = [SLFState findFirstByAttribute:@"stateID" withValue:dsource.stateID];
                       
    NSMutableString *predicateString = [[NSMutableString alloc] init];
    
    searchOption = MAX(searchOption, CHAMBER_ALL);
    searchOption = MIN(searchOption, CHAMBER_UPPER);
   
    // A chamber/scope has been selected
    if (searchOption > CHAMBER_ALL) {
        SLFChamber *chamber = [state.chambers objectAtIndex:searchOption];
        [predicateString appendFormat:@"(chamber LIKE[cd] '%@')", chamber.type];
        
        if (!IsEmpty(searchString) || !IsEmpty(dsource.stateID)) {
            [predicateString appendString:@" AND "];
        }
    }
    
    // we have some search terms typed in
    if (!IsEmpty(searchString)) {
        [predicateString appendFormat:@"(legislators.fullName CONTAINS[cd] '%@' OR name CONTAINS[cd] '%@')", searchString, searchString];
        
        if (!IsEmpty(dsource.stateID)) {
            [predicateString appendString:@" AND "];
        }
    }
    
    // we have a solid state ID
    if (!IsEmpty(dsource.stateID)) {
        [predicateString appendFormat:@"(stateID LIKE[cd] '%@')", dsource.stateID];
    }
    
    
    // we have some filters, set up the predicate
    if ([predicateString length]) {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    [predicateString release];
        
    dsource.fetchedResultsController = nil;
    NSFetchedResultsController *frc = [dsource fetchedResultsController];
        //NSFetchedResultsController *frc = dsource.fetchedResultsController;    
        //[NSFetchedResultsController deleteCacheWithName:frc.cacheName];
    
    [frc.fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    if (![frc performFetch:&error]) {
        RKLogError(@"Unresolved error %@, %@", [error localizedDescription], [error userInfo]);
    }           
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if ([self.searchDisplayController respondsToSelector:@selector(searchBarCancelButtonClicked:)])
        [self.searchDisplayController performSelector:@selector(searchBarCancelButtonClicked:) withObject:searchBar];
    
    self.dataSource.fetchedResultsController = nil;
    [self.dataSource fetchedResultsController];
    //[self filterChamber:self.chamberControl];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return [self searchDisplayController:controller shouldReloadTableForSearchString:searchString searchScope:self.chamberControl.selectedSegmentIndex];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    return [self searchDisplayController:controller shouldReloadTableForSearchString:controller.searchBar.text searchScope:searchOption];
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

- (IBAction) filterChamber:(id)sender {    
    NSString *searchText = self.searchDisplayController.searchBar.text;
    if (IsEmpty(searchText))
        searchText = @"";
    
    [self searchDisplayController:self.searchDisplayController shouldReloadTableForSearchString:searchText];
    
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

- (IBAction) sortType:(id)sender {
	if (sender == self.sortControl) {
/*
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
 */
	}
}

@end

