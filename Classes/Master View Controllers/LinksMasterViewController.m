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
	
	if (![UtilityMethods isIPadDevice])
		[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];
	
	BOOL isSplitViewDetail = ([UtilityMethods isIPadDevice]);
	
	if (!isSplitViewDetail)
		self.navigationController.toolbarHidden = YES;
	
	id dataObject = [self.dataSource dataObjectForIndexPath:newIndexPath];
/*
 // save off this item's selection to our AppDelegate
	if ([dataObject isKindOfClass:[NSManagedObject class]])
		[appDelegate setSavedTableSelection:[dataObject objectID] forKey:self.viewControllerKey];
	else
		[appDelegate setSavedTableSelection:newIndexPath forKey:self.viewControllerKey];
*/	
	NSString * action = [dataObject valueForKey:@"url"];
	
	if ([UtilityMethods isIPadDevice]) {
		if (!self.detailViewController || ![self.detailViewController isKindOfClass:[LinksDetailViewController class]]) {
			[self.detailViewController release];
			self.detailViewController = [[LinksDetailViewController alloc] init];
		}
		if ([action isEqualToString:@"contactMail"])
			[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];
		
		[self.detailViewController setValue:dataObject forKey:@"link"];
		
	}
	else {
		if ([action isEqualToString:@"aboutView"]) {
			self.miniBrowser = nil;
			
			[appDelegate showAboutDialog:self];

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
					}
				}
				if (!self.miniBrowser) {
					debug_NSLog(@"Failure while attempting to allocate memory for MiniBrowserController");
					return;
				}
				
				[self.miniBrowser loadURL:url];
				[self.miniBrowser display:self];
			}
		}
	}
}


@end
