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
#import "LinksDataSource.h"

#import "MiniBrowserController.h"
#import "TexLegeTheme.h"
#import "TexLegeEmailComposer.h"

@implementation LinksMasterViewController


@synthesize dataSource, detailViewController, aboutControl, miniBrowser;
@synthesize selectObjectOnAppear;

- (NSString *) viewControllerKey {
	return @"LinksMasterViewController";
}

- (Class)dataSourceClass {
	return [LinksDataSource class];
}

- (id)init {
	if (self = [super init]) {
		debug_NSLog(@"AppDelegate Managed Context %@", [[[TexLegeAppDelegate appDelegate] managedObjectContext] description]);
	
	}
	return self;
}


- (void)configureWithManagedObjectContext:(NSManagedObjectContext *)context {
	[super configureWithManagedObjectContext:context];
			
//	if (self.selectObjectOnAppear && [self.selectObjectOnAppear isKindOfClass:[LinkObj class]]) {
		self.selectObjectOnAppear = nil; // let's not go hitting up websites on startup (Resources) 
//	}
	
}

- (void)dealloc {
	self.aboutControl = nil;
	self.miniBrowser = nil;
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	self.aboutControl = nil;
	self.miniBrowser = nil;
	
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)loadView {	
	[super runLoadView];	
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if (!self.selectObjectOnAppear && [UtilityMethods isIPadDevice])
		self.selectObjectOnAppear = [self firstDataObject];
}

- (void)viewDidUnload {
	self.aboutControl = nil;
	self.miniBrowser = nil;
	[super viewDidUnload];
}



/*- (void)viewWillAppear:(BOOL)animated
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
}*/

#pragma -
#pragma UITableViewDelegate

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)newIndexPath {
	[aTableView.delegate tableView:aTableView didSelectRowAtIndexPath:newIndexPath];
}

// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {
	TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
	
	[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];
	
	BOOL isSplitViewDetail = ([UtilityMethods isIPadDevice]) && (self.splitViewController != nil);
	
	if (!isSplitViewDetail)
		self.navigationController.toolbarHidden = YES;
	
	id dataObject = [self.dataSource dataObjectForIndexPath:newIndexPath];
	
	LinkObj *link = dataObject;
	
	if (link) {
		
		// create a CapitolMapsDetailViewController. This controller will display the full size tile for the element
		if (self.detailViewController == nil) {
			self.detailViewController = [[[MiniBrowserController alloc] initWithNibName:@"MiniBrowserView" bundle:nil] autorelease];
		}
		
		MiniBrowserController *detailVC = self.detailViewController;
		if ([link.url isEqualToString:@"contactMail"]) {
			[[TexLegeEmailComposer sharedTexLegeEmailComposer] presentMailComposerTo:@"support@texlege.com" 
																			 subject:@"TexLege Support Question / Concern" 
																				body:@"" commander:self];
			return;
		}

		
		if ([link.url isEqualToString:@"aboutView"]) {
			NSString *path = nil;
			if ([UtilityMethods isIPadDevice])
				path = [[NSBundle mainBundle] pathForResource:@"TexLegeInfo~ipad" ofType:@"htm"];
			else
				path = [[NSBundle mainBundle] pathForResource:@"TexLegeInfo~iphone" ofType:@"htm"];
			
			link.url = [NSString stringWithFormat:@"file://%@", path];
			
		}
		[detailVC view];
		detailVC.m_shouldHideDoneButton = YES;
		[detailVC removeDoneButton];
		
		// save off this item's selection to our AppDelegate
		[appDelegate setSavedTableSelection:newIndexPath forKey:self.viewControllerKey];

		[detailVC setLink:link];
		if (isSplitViewDetail == NO) {
			// push the detail view controller onto the navigation stack to display it				
			[self.navigationController pushViewController:self.detailViewController animated:YES];
			self.detailViewController = nil;
		}
	}
}

@end
