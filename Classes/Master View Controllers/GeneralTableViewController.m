//
//  GeneralTableViewController.m
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "UtilityMethods.h"

#import "GeneralTableViewController.h"

#import "TexLegeAppDelegate.h"
#import "TableDataSourceProtocol.h"

#import "TexLegeTheme.h"

@implementation GeneralTableViewController


@synthesize dataSource, detailViewController;
@synthesize selectObjectOnAppear, managedObjectContext;

- (NSString *) viewControllerKey {
	return @"GENERALTABLEVIEWCONTROLLER_TEMPLATE";
}

- (Class)dataSourceClass {
	return [NSObject class];
}

- (void)configureWithManagedObjectContext:(NSManagedObjectContext *)context {
	self.managedObjectContext = context;
	
		//self.tableView = nil;
	self.dataSource = [[[[self dataSourceClass] alloc] initWithManagedObjectContext:self.managedObjectContext] autorelease];
	self.title = [self.dataSource name];	
	// set the long name shown in the navigation bar
	//self.navigationItem.title=[dataSource navigationBarName];
	
	// FETCH CORE DATA
	if ([self.dataSource usesCoreData])
	{		
		NSError *error;
		// You've got to delete the cache, or disable caching before you modify the predicate...
		[NSFetchedResultsController deleteCacheWithName:[[self.dataSource fetchedResultsController] cacheName]];
		
		if (![[self.dataSource fetchedResultsController] performFetch:&error]) {
			// Handle the error...
		}		
	}
	
	if ([self.dataSource usesCoreData]) {
		id objectID = [[TexLegeAppDelegate appDelegate] savedTableSelectionForKey:self.viewControllerKey];
		if (objectID && [objectID isKindOfClass:[NSManagedObjectID class]])
			self.selectObjectOnAppear = [self.dataSource.managedObjectContext objectWithID:objectID];		
	}
	else { // Let's just do this for maps, and meetings, ... we'll handle them like integer row selections
		id object = [[TexLegeAppDelegate appDelegate] savedTableSelectionForKey:self.viewControllerKey];
		if (!object)
			return;
		
		if ([object isKindOfClass:[NSIndexPath class]]) {
			self.selectObjectOnAppear = [self.dataSource dataObjectForIndexPath:object];
		}
	}
}

- (void)dealloc {
	self.tableView = nil;
	self.dataSource = nil; 
	self.selectObjectOnAppear = nil;
	self.managedObjectContext = nil;
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	//if ([self.dataSource respondsToSelector:@selector(didReceiveMemoryWarning)])
	//	[self.dataSource performSelector:@selector(didReceiveMemoryWarning)];
	
	[[TexLegeAppDelegate appDelegate] setSavedTableSelection:nil forKey:self.viewControllerKey];

	if (![UtilityMethods isIPadDevice]) {
		debug_NSLog(@"about to release a view controller %@", self.detailViewController);
		self.detailViewController = nil;
	}
	
	self.selectObjectOnAppear = nil;
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
}

- (void)runLoadView {	
	[super loadView];
	
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	CGRect tempFrame = [[UIScreen mainScreen] applicationFrame];
	self.tableView = [[[UITableView alloc] initWithFrame:tempFrame style:[self.dataSource tableViewStyle]] autorelease];
	
	// set the autoresizing mask so that the table will always fill the view
	self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	self.tableView.autoresizesSubviews = YES;
	
	// set the cell separator to a single straight line.
	//self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	//self.tableView.separatorColor = [UIColor lightGrayColor];
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	self.tableView.delegate = self;
	self.tableView.dataSource = self.dataSource;
	
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

- (void)viewDidUnload {
	self.tableView.dataSource = nil;
	self.selectObjectOnAppear = nil;
	self.tableView = nil;
	[super viewDidUnload];
}

- (IBAction)selectDefaultObject:(id)sender {
	NSIndexPath *selectFirst = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView selectRowAtIndexPath:selectFirst animated:NO scrollPosition:UITableViewScrollPositionNone];
	[self tableView:self.tableView didSelectRowAtIndexPath:selectFirst];
}

- (id)firstDataObject {
	NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	id detailObject = [self.dataSource dataObjectForIndexPath:currentIndexPath];			
	return detailObject;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.selectObjectOnAppear)  {	
		NSIndexPath *selectedPath = nil;
		
		//if (![self.dataSource.name isEqualToString:@"Resources"])
			selectedPath = [self.dataSource indexPathForDataObject:self.selectObjectOnAppear];
				
		if (selectedPath) {
			[self.tableView selectRowAtIndexPath:selectedPath animated:animated scrollPosition:UITableViewScrollPositionNone];
			[self tableView:self.tableView didSelectRowAtIndexPath:selectedPath];
		}
		self.selectObjectOnAppear = nil;
	}
	
	// We're on an iphone, without a splitview or popovers, so if we get here, let's stop
	if (![UtilityMethods isIPadDevice]) {
		[[TexLegeAppDelegate appDelegate] setSavedTableSelection:nil forKey:self.viewControllerKey];
	}
}


#pragma -
#pragma UITableViewDelegate

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
}


// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {
	return ; // just a placeholder for children
}

// the *user* selected a row in the table, so turn on animations and save their selection.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
	[self tableView:aTableView didSelectRowAtIndexPath:newIndexPath withAnimation:YES];
	
	// if we have a stack of view controllers and someone selected a new cell from our master list, 
	//	lets go all the way back to accomodate their selection.
	if ([UtilityMethods isIPadDevice]) {
		UINavigationController *detailNav = nil;
		if ([self.detailViewController respondsToSelector:@selector(navigationController)])
			detailNav = [self.detailViewController performSelector:@selector(navigationController)];
		
		if (detailNav && detailNav.viewControllers && [detailNav.viewControllers count] > 1) { 
			[detailNav popToRootViewControllerAnimated:YES];
			
			if ([self.detailViewController respondsToSelector:@selector(tableView)]) {
				UITableView *detailTable = [self.detailViewController performSelector:@selector(tableView)];
				if (detailTable) {
					CGRect guessTop = CGRectMake(0, 0, 10.0f, 10.0f);
					[detailTable scrollRectToVisible:guessTop animated:YES];
				}
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
