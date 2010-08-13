    //
//  LinksMasterViewController.m
//  TexLege
//
//  Created by Gregory Combs on 8/13/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "LinksMasterViewController.h"
#import "UtilityMethods.h"

#import "TexLegeAppDelegate.h"
#import "TableDataSourceProtocol.h"
#import "LinksMenuDataSource.h"
#import "LinksDetailViewController.h"

#import "MiniBrowserController.h"
#import "TexLegeTheme.h"
#import "TexLegeEmailComposer.h"
#import "CommonPopoversController.h"

@implementation LinksMasterViewController


@synthesize dataSource, detailViewController, aboutControl, miniBrowser;
@synthesize selectObjectOnAppear;

- (NSString *) viewControllerKey {
	return @"LinksMasterViewController";
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
}

- (void)dealloc {
	self.tableView = nil;
	self.dataSource = nil; 
	self.selectObjectOnAppear = nil;
	self.aboutControl = nil;
	self.miniBrowser = nil;
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	if ([self.dataSource respondsToSelector:@selector(didReceiveMemoryWarning)])
		[self.dataSource performSelector:@selector(didReceiveMemoryWarning)];
	
	//self.detailViewController = nil;
	self.selectObjectOnAppear = nil;
	self.aboutControl = nil;
	self.miniBrowser = nil;
	
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
	//self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	//self.tableView.separatorColor = [UIColor lightGrayColor];
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	self.tableView.delegate = self;
	self.tableView.dataSource = dataSource;
	
	self.tableView.sectionIndexMinimumDisplayRowCount=15;
	
	// set the tableview as the controller view
	self.view = self.tableView;
}

-(void)viewDidLoad {
	[super viewDidLoad];
	
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
	if ([UtilityMethods isIPadDevice]) {
		NSUInteger sectionCount = [self.tableView numberOfSections];
		CGFloat tableHeight = 0;
		NSInteger section = 0;
		for (section=0; section < sectionCount; section++) {
			tableHeight += [self.tableView rectForSection:section].size.height;
		}
		self.contentSizeForViewInPopover = CGSizeMake(320.0, tableHeight);
		//self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
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
		if (self.detailViewController && [self.detailViewController respondsToSelector:@selector(link)])
			detailObject = self.detailViewController ? [self.detailViewController valueForKey:@"link"] : nil;
		
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
		
		//if (![dataSource.name isEqualToString:@"Resources"])
		selectedPath = [self.dataSource indexPathForDataObject:self.selectObjectOnAppear];
		
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
	[aTableView.delegate tableView:aTableView didSelectRowAtIndexPath:newIndexPath];
}

// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {
	TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
	
	if (![UtilityMethods isIPadDevice])
		[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];
	
	BOOL isSplitViewDetail = ([UtilityMethods isIPadDevice]) && (self.splitViewController != nil);
	
	if (!isSplitViewDetail)
		self.navigationController.toolbarHidden = YES;
	
	id dataObject = [dataSource dataObjectForIndexPath:newIndexPath];
	// save off this item's selection to our AppDelegate
	if ([dataObject isKindOfClass:[NSManagedObject class]])
		[appDelegate setSavedTableSelection:[dataObject objectID] forKey:self.viewControllerKey];
	else
		[appDelegate setSavedTableSelection:newIndexPath forKey:self.viewControllerKey];
	
	NSString * action = [dataObject valueForKey:@"url"];
	
	if ([UtilityMethods isIPadDevice]) {
		if (!self.detailViewController || ![self.detailViewController isKindOfClass:[LinksDetailViewController class]]) {
			[self.detailViewController release];
			self.detailViewController = [[LinksDetailViewController alloc] init];
		}
		appDelegate.currentDetailViewController = self.detailViewController;
		[[appDelegate detailNavigationController] setViewControllers:[NSArray arrayWithObject:self.detailViewController] animated:NO];
		[self.detailViewController setValue:dataObject forKey:@"link"];
		
	}
	else {
		if ([action isEqualToString:@"aboutView"]) {
			self.miniBrowser = nil;
			
			if (!isSplitViewDetail) {
				[appDelegate showAboutDialog:self];
				return;
			}
			else if (!self.aboutControl) {
				if (self.detailViewController && [self.detailViewController isKindOfClass:[AboutViewController class]])
					self.aboutControl = (AboutViewController *) self.detailViewController;
				else
					self.aboutControl = [[AboutViewController alloc] initWithNibName:@"TexLegeInfo~ipad" bundle:nil];
			}
			
			if (!self.aboutControl) {
				debug_NSLog(@"Failure while attempting to allocate memory for AboutViewController");
				return;
			}
			appDelegate.currentDetailViewController = self.aboutControl;
			
			if (isSplitViewDetail) {
				[[appDelegate detailNavigationController] setViewControllers:[NSArray arrayWithObject:self.aboutControl] animated:YES];
				//appDelegate.splitViewController.delegate = self.aboutControl;
			}
		}
		else if ([action isEqualToString:@"contactMail"]) {
			[[TexLegeEmailComposer sharedTexLegeEmailComposer] presentMailComposerTo:@"support@texlege.com" 
																			 subject:@"TexLege Support Question / Concern" 
																				body:@""];
		}
		else {			
			NSURL *url = [UtilityMethods safeWebUrlFromString:action];
			
			if ([UtilityMethods canReachHostWithURL:url]) { // got a network connection
				self.aboutControl = nil;
				
				if (!self.miniBrowser) {
					if (self.detailViewController && [self.detailViewController isKindOfClass:[MiniBrowserController class]])
						self.miniBrowser = (MiniBrowserController *) self.detailViewController;
					else {
						self.miniBrowser = [MiniBrowserController sharedBrowserWithURL:url];
						appDelegate.currentDetailViewController = self.miniBrowser;
						if ([UtilityMethods isIPadDevice]) {
							[[appDelegate detailNavigationController] setViewControllers:[NSArray arrayWithObject:self.miniBrowser] animated:YES];
						}
					}
				}
				if (!self.miniBrowser) {
					debug_NSLog(@"Failure while attempting to allocate memory for MiniBrowserController");
					return;
				}
				
				[self.miniBrowser loadURL:url];
				
				if (![UtilityMethods isIPadDevice])
					[self.miniBrowser display:self];
			}
		}
	}
	//[[CommonPopoversController sharedCommonPopoversController] resetPopoverMenus:self];
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
	}
}


#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { 	
	return YES;
}


@end
