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
#import "MiniBrowserController.h"
#import "TexLegeTheme.h"
#import "TexLegeEmailComposer.h"
#import "CommonPopoversController.h"

@implementation GeneralTableViewController


@synthesize dataSource, detailViewController, aboutControl, miniBrowser;
@synthesize selectObjectOnAppear;

- (NSString *) viewControllerKey {
	if ([dataSource.name isEqualToString:@"Resources"])
		return @"LinksMasterViewController";
	else if ([dataSource.name isEqualToString:@"Maps"])
		return @"MapsMasterViewController";
	else //([dataSource.name isEqualToString:@"Meetings"])
		return @"CalendarsMasterViewController";
}


- (void)configureWithDataSourceClass:(Class)sourceClass andManagedObjectContext:(NSManagedObjectContext *)context {
		//self.tableView = nil;
	self.dataSource = [[sourceClass alloc] initWithManagedObjectContext:context];
	self.title = [dataSource name];	
	// set the long name shown in the navigation bar
	//self.navigationItem.title=[dataSource navigationBarName];
	
	if ([dataSource usesCoreData]) {
		NSManagedObjectID *objectID = [[TexLegeAppDelegate appDelegate] savedTableSelectionForKey:self.viewControllerKey];
		if (objectID)
			self.selectObjectOnAppear = [self.dataSource.managedObjectContext objectWithID:objectID];
		
		if (self.selectObjectOnAppear && [self.selectObjectOnAppear isKindOfClass:[LinkObj class]]) {
			self.selectObjectOnAppear = nil; // let's not go hitting up websites on startup (Resources) 
		}
	}
	else if ([dataSource.name isEqualToString:@"Meetings"])
		self.selectObjectOnAppear = [[TexLegeAppDelegate appDelegate] savedTableSelectionForKey:self.viewControllerKey];
		
	
}

- (void)dealloc {
	self.miniBrowser = nil;
	self.tableView = nil;
	self.dataSource = nil; 
	self.selectObjectOnAppear = nil;
	self.aboutControl = nil;
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	if ([self.dataSource respondsToSelector:@selector(didReceiveMemoryWarning)])
		[self.dataSource performSelector:@selector(didReceiveMemoryWarning)];
	
	self.detailViewController = nil;
	self.selectObjectOnAppear = nil;
	self.aboutControl = nil;
	
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
	
	if ([UtilityMethods isIPadDevice])
		self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);

	self.clearsSelectionOnViewWillAppear = NO;

	self.tableView.separatorColor = [TexLegeTheme separator];
	self.tableView.backgroundColor = [TexLegeTheme tableBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];
	//self.searchDisplayController.searchBar.tintColor = [TexLegeTheme accent];
	//self.navigationItem.titleView = self.chamberControl;
	
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
}

- (IBAction)selectDefaultObject:(id)sender {
	NSIndexPath *selectFirst = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView selectRowAtIndexPath:selectFirst animated:NO scrollPosition:UITableViewScrollPositionNone];
	[self tableView:self.tableView didSelectRowAtIndexPath:selectFirst];
}


- (void)viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
	
	//// ALL OF THE FOLLOWING MUST *NOT* RUN ON IPHONE (I.E. WHEN THERE'S NO SPLITVIEWCONTROLLER
	
	if ([UtilityMethods isIPadDevice] && self.selectObjectOnAppear == nil) {
		id detailObject = nil;
		if ([dataSource.name isEqualToString:@"Maps"])
			detailObject = self.detailViewController ? [self.detailViewController valueForKey:@"map"] : nil;
		else if ([dataSource.name isEqualToString:@"Meetings"])
			detailObject = [NSNumber numberWithInteger:0];
				  
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

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.selectObjectOnAppear)  {	
		NSIndexPath *selectedPath = nil;
		
		if ([self.selectObjectOnAppear isKindOfClass:[NSManagedObject class]] && self.dataSource.fetchedResultsController)
			selectedPath = [self.dataSource.fetchedResultsController indexPathForObject:self.selectObjectOnAppear];
		else if ([dataSource.name isEqualToString:@"Meetings"] && [self.selectObjectOnAppear isKindOfClass:[NSNumber class]])
			selectedPath = [NSIndexPath indexPathForRow:[self.selectObjectOnAppear integerValue] inSection:0];
		
		if (selectedPath) {
			[self.tableView selectRowAtIndexPath:selectedPath animated:animated scrollPosition:UITableViewScrollPositionNone];
			[self tableView:self.tableView didSelectRowAtIndexPath:selectedPath];
		}
		self.selectObjectOnAppear = nil;

	}	
	
	// We're on an iphone, without a splitview or popovers, so if we get here, let's stop
	if ([UtilityMethods isIPadDevice] == NO) {
		[[TexLegeAppDelegate appDelegate] setSavedTableSelection:nil forKey:self.viewControllerKey];
	}
}


#pragma -
#pragma UITableViewDelegate

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
}


- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)newIndexPath {
	if (dataSource.name == @"Resources") { // just select the row, nothing special.
		[aTableView.delegate tableView:aTableView didSelectRowAtIndexPath:newIndexPath];
	}
}

// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {
	TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];

	if (![UtilityMethods isIPadDevice])
		[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];

	BOOL isSplitViewDetail = ([UtilityMethods isIPadDevice]) && (self.splitViewController != nil);
	UIViewController *openInController = (isSplitViewDetail) ? self.detailViewController : self;
		
	if (!openInController) {
		debug_NSLog(@"Error opening detail controller from GeneralTableViewController:didSelect ...");
		return;
	}
	
	if (isSplitViewDetail == NO)
		self.navigationController.toolbarHidden = YES;
	
	id dataObject = [dataSource dataObjectForIndexPath:newIndexPath];
	// save off this item's selection to our AppDelegate
	if ([dataSource.name isEqualToString:@"Resources"])
		[appDelegate setSavedTableSelection:nil forKey:self.viewControllerKey];
	else if ([dataObject isKindOfClass:[NSManagedObject class]])
		[appDelegate setSavedTableSelection:[dataObject objectID] forKey:self.viewControllerKey];
	else if ([dataSource.name isEqualToString:@"Meetings"])
		[appDelegate setSavedTableSelection:[NSNumber numberWithInteger:newIndexPath.row] forKey:self.viewControllerKey];

		
	if (dataSource.name == @"Resources"){ // has it's own special controller...
		if ([appDelegate.currentDetailViewController isKindOfClass:[MiniBrowserController class]])
			self.miniBrowser = appDelegate.currentDetailViewController;
		
		NSString * action = [dataObject valueForKey:@"url"];
		
		if ([action isEqualToString:@"aboutView"]) {
			if (![UtilityMethods isIPadDevice])
				[appDelegate showAboutDialog:openInController];
			else {
				if (!self.aboutControl) {
					self.aboutControl = [[AboutViewController alloc] initWithNibName:@"TexLegeInfo~ipad" bundle:nil];
					//self.aboutControl.delegate = self;
				}
				[[appDelegate detailNavigationController] setViewControllers:[NSArray arrayWithObject:self.aboutControl] animated:YES];
				appDelegate.currentDetailViewController = self.aboutControl;
				//appDelegate.splitViewController.delegate = self.aboutControl;
			}
		}
		else if ([action isEqualToString:@"contactMail"]) {
			[[TexLegeEmailComposer sharedTexLegeEmailComposer] presentMailComposerTo:@"support@texlege.com" 
																			 subject:@"TexLege Support Question / Concern" 
																				body:@""];
		}
		else {
			if (self.aboutControl)
				self.aboutControl = nil;
			
			[[appDelegate detailNavigationController] setViewControllers:[NSArray arrayWithObject:self.miniBrowser] animated:YES];
			appDelegate.currentDetailViewController = self.miniBrowser;
			
			NSURL *url = [UtilityMethods safeWebUrlFromString:action];
			
			if ([UtilityMethods canReachHostWithURL:url]) { // got a network connection
				if ([UtilityMethods isIPadDevice]) {
					self.aboutControl = nil;
					[[appDelegate detailNavigationController] setViewControllers:[NSArray arrayWithObject:self.miniBrowser] animated:YES];
					appDelegate.currentDetailViewController = self.miniBrowser;
					//appDelegate.splitViewController.delegate = self.miniBrowser;					
				}
				
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
		[[CommonPopoversController sharedCommonPopoversController] resetPopoverMenus:self];
		
	}
	else if (dataSource.name == @"Meetings") {	
		if (!self.detailViewController) {
			if ([UtilityMethods isIPadDevice])
				self.detailViewController = [[CalendarComboViewController alloc] initWithNibName:@"CalendarComboViewController~ipad" bundle:nil];
			else
				self.detailViewController = [[CalendarComboViewController alloc] initWithNibName:@"CalendarComboViewController~iphone" bundle:nil];
		}
		
		NSArray *feedEntries = nil;
		if ([dataObject isKindOfClass:[NSArray class]])
			feedEntries = dataObject;
		
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
			debug_NSLog(@"GeneralTableViewController, unexpected datasource: %@", dataSource.name);

		// create an MapsDetailViewController. This controller will display the full size tile for the element
		if (self.detailViewController == nil) {
			self.detailViewController = [[MapsDetailViewController alloc] initWithNibName:@"MapsDetailViewController" bundle:nil];
		}
				
		CapitolMap *capitolMap = dataObject;
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


@end
