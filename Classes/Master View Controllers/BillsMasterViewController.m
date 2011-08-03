//
//  BillsMasterViewController.m
//  Created by Gregory Combs on 2/6/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "BillsMasterViewController.h"
#import "BillsDetailViewController.h"
#import "SLFDataModels.h"

#import "UtilityMethods.h"

#import "AppDelegate.h"
#import "SLFPersistenceManager.h"

#import "TableDataSourceProtocol.h"

#import "TexLegeTheme.h"
#import "OpenLegislativeAPIs.h"

#import "BillsMenuDataSource.h"
#import "BillSearchDataSource.h"
#import "OpenLegislativeAPIs.h"
#import "LocalyticsSession.h"
#import "StateMetaLoader.h"
#import "ActionSheetPicker.h"

#import <objc/message.h>

#define LIVE_SEARCHING 1

#warning use the feature flag to remove unavailable items (like subjects/categories)

@interface BillsMasterViewController()

- (NSString *)sessionLabelText;
- (IBAction)showSessionControl:(id)sender;
- (IBAction)sessonControlChanged:(NSNumber *)selectedIndex:(id)element;
- (void)createSessionPicker;
- (void)destroySessionPicker;

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
@end

@implementation BillsMasterViewController
@synthesize billSearchDS;
@synthesize activeSessionLabel;

#pragma mark -
#pragma mark Main Menu Info

+ (NSString *)name
{ return NSLocalizedStringFromTable(@"Bills", @"StandardUI", @"Short name for bills (legislative documents, pre-law) tab"); }

- (NSString *)navigationBarName 
{ return [self name]; }

+ (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"gavel-inv"]; }


////////////////////////////////////////

// Set this to non-nil whenever you want to automatically enable/disable the view controller based on network/host reachability
- (NSString *)reachabilityStatusKey {
	return @"openstatesConnectionStatus";
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.billSearchDS = nil;
	self.activeSessionLabel = nil;
	[super dealloc];
}

- (NSString *)nibName {
	return NSStringFromClass([self class]);
}


- (void)viewDidLoad {
	[super viewDidLoad];
					
	if (!self.billSearchDS)
		self.billSearchDS = [[[BillSearchDataSource alloc] initWithSearchDisplayController:self.searchDisplayController] autorelease];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tableDataChanged:) name:kBillSearchNotifyDataLoaded object:billSearchDS];	
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSessionLabel:) name:kStateMetaNotifySessionChange object:nil];
    
	self.searchDisplayController.searchBar.tintColor = [TexLegeTheme accent];	
	
	self.searchDisplayController.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:
																stringForChamber(BOTH_CHAMBERS, TLReturnAbbrev),
																stringForChamber(HOUSE, TLReturnAbbrev),
																stringForChamber(SENATE, TLReturnAbbrev),
																nil];
	
	if ([UtilityMethods isIPadDevice]) {	
		self.contentSizeForViewInPopover = CGSizeMake(320.0, 400.0);
	    	
		/* This "avoids" a bug on iPads where the scope bar get's crammed into the top line in landscape. */
		if ([self.searchDisplayController.searchBar respondsToSelector:@selector(setCombinesLandscapeBars:)]) 
		{ 
			objc_msgSend(self.searchDisplayController.searchBar, @selector(setCombinesLandscapeBars:), NO );
		}
	}
		
/*	for (id subview in self.searchDisplayController.searchBar.subviews )
	{
		if([subview isMemberOfClass:[UISegmentedControl class]])
		{
			UISegmentedControl *scopeBar=(UISegmentedControl *) subview;
			scopeBar.segmentedControlStyle = UISegmentedControlStyleBar; //required for color change
			scopeBar.tintColor =  [TexLegeTheme accent];         
		}
	}
*/	
}

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [self destroySessionPicker];
    
	self.activeSessionLabel = nil;
	self.toolbarItems = nil;
	self.billSearchDS = nil;
    
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
	UINavigationController *nav = [self navigationController];
	if (nav && [nav.viewControllers count]>3) {
		[nav popToRootViewControllerAnimated:YES];
	}
	
	[super didReceiveMemoryWarning];
}

- (void)tableDataChanged:(NSNotification *)notification {
	[self.tableView reloadData];
	if (self.searchDisplayController.searchResultsTableView)
		[self.searchDisplayController.searchResultsTableView reloadData];
}

- (Class)dataSourceClass {
	return [BillsMenuDataSource class];
}

- (void)viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
		    
	// this has to be here because GeneralTVC will overwrite it once anyone calls self.dataSource,
	//		if we remove this, it will wind up setting our searchResultsDataSource to the BillsMenuDataSource
	self.searchDisplayController.searchResultsDataSource = self.billSearchDS;	
	[self.searchDisplayController.searchBar setHidden:NO];

#if LIVE_SEARCHING == 0
	self.searchDisplayController.searchBar.delegate = self;
#endif
    
    self.searchDisplayController.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:
																stringForChamber(BOTH_CHAMBERS, TLReturnAbbrev),
																stringForChamber(HOUSE, TLReturnAbbrev),
																stringForChamber(SENATE, TLReturnAbbrev),
																nil];
	
    
    [self createSessionPicker];
    
	if ([UtilityMethods isIPadDevice])
		[self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    //[self destroySessionPicker];
    [super viewDidDisappear:animated];
}

#pragma -
#pragma UITableViewDelegate

// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {	
	if (![UtilityMethods isIPadDevice])
		[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];
	
	BOOL isSplitViewDetail = ([UtilityMethods isIPadDevice]) && (self.splitViewController != nil);
	
	//if (!isSplitViewDetail)
	//	self.navigationController.toolbarHidden = YES;
	
	id dataObject = nil;
	BOOL changingDetails = NO;

//	IF WE'RE CLICKING ON SOME SEARCH RESULTS ... PULL UP THE BILL DETAIL VIEW CONTROLLER
	if (aTableView == self.searchDisplayController.searchResultsTableView) { // we've clicked in a search table
		dataObject = [self.billSearchDS dataObjectForIndexPath:newIndexPath];
		//[self searchBarCancelButtonClicked:nil];
		
		if (dataObject) {

			if (!self.detailViewController || ![self.detailViewController isKindOfClass:[BillsDetailViewController class]]) {
				self.detailViewController = [[[BillsDetailViewController alloc] initWithNibName:@"BillsDetailViewController" bundle:nil] autorelease];
				changingDetails = YES;
			}
			if ([self.detailViewController respondsToSelector:@selector(setDataObject:)])
				[self.detailViewController performSelector:@selector(setDataObject:) withObject:dataObject];
			
			[[OpenLegislativeAPIs sharedOpenLegislativeAPIs] queryOpenStatesBillWithID:[dataObject objectForKey:@"bill_id"] 
																			   session:[dataObject objectForKey:@"session"] 
																			  delegate:self.detailViewController];			
			if (isSplitViewDetail == NO) {
				// push the detail view controller onto the navigation stack to display it				
				[self.navigationController pushViewController:self.detailViewController animated:YES];
				self.detailViewController = nil;
			}
			else if (changingDetails)
				[[[AppDelegate appDelegate] detailNavigationController] setViewControllers:[NSArray arrayWithObject:self.detailViewController] animated:NO];
		}			
	}
	
//	WE'RE CLICKING ON ONE OF OUR STANDARD MENU ITEMS
	else {
		dataObject = [self.dataSource dataObjectForIndexPath:newIndexPath];
	
		[[SLFPersistenceManager sharedPersistence] setTableSelection:newIndexPath forKey:NSStringFromClass([self class])];
	
		if (!dataObject || ![dataObject isKindOfClass:[NSDictionary class]])
			return;

		NSString *theClass = [dataObject objectForKey:@"class"];
		if (!theClass || !NSClassFromString(theClass))
			return;
		
		UITableViewController *tempVC = nil;
		tempVC = [[[NSClassFromString(theClass) alloc] initWithStyle:UITableViewStylePlain] autorelease];	// we don't want a nib for this one
		
		if (aTableView == self.searchDisplayController.searchResultsTableView) { // we've clicked in a search table
			[self searchBarCancelButtonClicked:nil];
		}
		
		NSDictionary *tagMenu = [[NSDictionary alloc] initWithObjectsAndKeys:theClass, @"FEATURE", nil];
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"BILL_MENU" attributes:tagMenu];
		[tagMenu release];
		
		tempVC.toolbarItems = self.toolbarItems;
		
		// push the detail view controller onto the navigation stack to display it				
		[self.navigationController pushViewController:tempVC animated:YES];
	}
}

#pragma mark -
#pragma mark Search Distplay Controller

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
#if LIVE_SEARCHING == 1
	nice_release(_searchString);

	if (searchString && [searchString length]) {
		_searchString = [searchString copy];
		if (_searchString && [_searchString length] >= 3) {
			[self.billSearchDS startSearchForText:_searchString 
										  chamber:self.searchDisplayController.searchBar.selectedScopeButtonIndex];
		}		
	}
#endif
	return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
	if (!controller || !controller.searchBar || !controller.searchBar.text || ![controller.searchBar.text length]) 
		return NO;
	
	nice_release(_searchString);

	_searchString = [controller.searchBar.text copy];
	[self.billSearchDS startSearchForText:_searchString chamber:searchOption];
	return NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
	nice_release(_searchString);

	_searchString = [[NSString alloc] initWithString:@""];

	self.searchDisplayController.searchBar.text = _searchString;
	[self.searchDisplayController setActive:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
#if LIVE_SEARCHING == 0
	if (IsEmpty(searchBar.text)) 
		return;
	
	nice_release(_searchString);

	_searchString = [searchBar.text copy];
	//if ([_searchString length] >= 3) {
		[self.billSearchDS startSearchForText:_searchString 
										 chamber:self.searchDisplayController.searchBar.selectedScopeButtonIndex];
	//}		
#endif
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	////////self.dataSource.hideTableIndex = YES;
	// for some reason, these get zeroed out after we restart searching.
	if (self.tableView && self.searchDisplayController.searchResultsTableView) {
		self.searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;
		self.searchDisplayController.searchResultsTableView.backgroundColor = self.tableView.backgroundColor;
		self.searchDisplayController.searchResultsTableView.sectionIndexMinimumDisplayRowCount = self.tableView.sectionIndexMinimumDisplayRowCount;
	}
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	////////self.dataSource.hideTableIndex = NO;
}

#pragma mark -
#pragma mark Legislative Session Picker

- (void)createSessionPicker {
	[self.navigationController setToolbarHidden:NO animated:YES];
	self.navigationController.toolbar.tintColor = [TexLegeTheme accent];
	self.hidesBottomBarWhenPushed = NO;
	
	UILabel *sessionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds)-60.f, 23.f)];
	sessionLabel.font = [UIFont boldSystemFontOfSize:15];
	sessionLabel.textColor = [TexLegeTheme backgroundLight];
	sessionLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
	sessionLabel.textAlignment = UITextAlignmentRight;
    sessionLabel.lineBreakMode = UILineBreakModeTailTruncation;
	sessionLabel.text = [self sessionLabelText];
	sessionLabel.opaque = NO;
	sessionLabel.backgroundColor = [UIColor clearColor];
    sessionLabel.adjustsFontSizeToFitWidth = YES;
    sessionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	self.activeSessionLabel = sessionLabel;
	
	UIBarButtonItem *labelButton = [[UIBarButtonItem alloc] initWithCustomView:sessionLabel];
	UIBarButtonItem *iconButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"138-scales-inv"] 
																   style:UIBarButtonItemStylePlain 
																  target:self 
																  action:@selector(showSessionControl:)];
	
	[self setToolbarItems:[NSArray arrayWithObjects:labelButton, iconButton, nil] animated:YES];
	[sessionLabel release];
	[labelButton release];
	[iconButton release];	
}

- (void)destroySessionPicker {
	[self setToolbarItems:nil animated:YES];
	self.activeSessionLabel = nil;
	[self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)changeSessionLabel:(id)sender {
    self.activeSessionLabel.text = [self sessionLabelText];
}

- (NSString *)sessionLabelText {
    
    StateMetaLoader *meta = [StateMetaLoader sharedStateMeta];
    SLFState *aState = meta.selectedState;
    NSString *tempLabel = [aState displayNameForSession:meta.selectedSession];
    if (!tempLabel)
        tempLabel = @"";
    
    return tempLabel;
}

- (IBAction)sessonControlChanged:(NSNumber *)selectedIndex:(id)element {	
	//Session selection was made
	NSInteger sessionIndex = [selectedIndex intValue];
	
	StateMetaLoader *meta = [StateMetaLoader sharedStateMeta];
    
    NSArray *displayNames = [[meta sessionDisplayNames] keysSortedByValueUsingSelector:@selector(compare:)];
        	
	if (displayNames && sessionIndex < [displayNames count]) {
        
        
		NSString *selectedDisplay = [displayNames objectAtIndex:sessionIndex];
        
        NSNumber *numValue = [[meta sessionDisplayNames] objectForKey:selectedDisplay];
        
        if (numValue) {
            
            NSString *selectedSession = [meta.sessions objectAtIndex:[numValue integerValue]];
        
            if (!IsEmpty(selectedSession)) {
                
                meta.selectedSession = selectedSession;
                
                if (self.activeSessionLabel) {
                    self.activeSessionLabel.text = selectedDisplay;
                }
            }
        }
	}
	
}

- (IBAction)showSessionControl:(id)sender {
	StateMetaLoader *meta = [StateMetaLoader sharedStateMeta];
	
	NSString *selectedSession = [meta selectedSession];
	NSArray *sessions = [meta sessions];
	
	if (IsEmpty(sessions) || IsEmpty(selectedSession)) {
		NSLog(@"Error when attempting to display legislative sessions control:  state=%@", meta.selectedState);
		return;
	}
    
    NSArray *displayNames = [[meta sessionDisplayNames] keysSortedByValueUsingSelector:@selector(compare:)];
	
	NSInteger selectedItem = [sessions indexOfObject:selectedSession];
	if (selectedItem==NSNotFound)
		selectedItem = 0;
	
	[ActionSheetPicker displayActionPickerFrom:sender 
											  data:displayNames
									 selectedIndex:selectedItem 
											target:self 
											action:@selector(sessonControlChanged::) 
											 title:NSLocalizedStringFromTable(@"Select a Session", @"StandardUI", @"Legislative session control label")];
	
}


@end
