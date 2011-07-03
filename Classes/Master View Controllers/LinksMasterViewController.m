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

#import "SVWebViewController.h"
#import "TexLegeTheme.h"
#import "TexLegeEmailComposer.h"
#import "TexLegeReachability.h"
#import "LinkObj+RestKit.h"

@implementation LinksMasterViewController

- (Class)dataSourceClass {
	return [LinksDataSource class];
}

- (void)configure {
	[super configure];				
//	if (self.selectObjectOnAppear && [self.selectObjectOnAppear isKindOfClass:[LinkObj class]]) {
		self.selectObjectOnAppear = nil; // let's not go hitting up websites on startup (Resources) 
//	}
	
}

- (void)dealloc {
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	
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
	[super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
	
	//// ALL OF THE FOLLOWING MUST *NOT* RUN ON IPHONE (I.E. WHEN THERE'S NO SPLITVIEWCONTROLLER
	
	/*if ([UtilityMethods isIPadDevice] && self.selectObjectOnAppear == nil) {
		id detailObject = nil; //self.detailViewController ? [self.detailViewController valueForKey:@"link"] : nil;
		//if (!detailObject) {
			NSIndexPath *currentIndexPath = [self.tableView indexPathForSelectedRow];
			if (!currentIndexPath) {			
				NSUInteger ints[2] = {0,0};	// just pick the first one then
				currentIndexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
			}
			detailObject = [self.dataSource dataObjectForIndexPath:currentIndexPath];				
		//}
		self.selectObjectOnAppear = detailObject;
	}	*/
	
	if ([UtilityMethods isIPadDevice])
		[self.tableView reloadData]; 
	
	// END: IPAD ONLY
}

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
	
	LinkObj *link = [self.dataSource dataObjectForIndexPath:newIndexPath];
	if (link) {
		if ([link.url hasPrefix:@"mailto:support@texlege.com"]) {
			NSString *appVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

			NSMutableString *body = [NSMutableString string];
			[body appendFormat:NSLocalizedStringFromTable(@"TexLege Version: %@\n", @"StandardUI", @"Text to be included in TexLege support emails."), appVer];
			[body appendFormat:NSLocalizedStringFromTable(@"iOS Version: %@\n", @"StandardUI", @"Text to be included in TexLege support emails."), [[UIDevice currentDevice] systemVersion]];
			[body appendFormat:NSLocalizedStringFromTable(@"iOS Device: %@\n", @"StandardUI", @"Text to be included in TexLege support emails."), [[UIDevice currentDevice] model]];
			[body appendString:NSLocalizedStringFromTable(@"\nDescription of Problem, Concern, or Question:\n", @"StandardUI", @"Text to be included in TexLege support emails.")];
			[[TexLegeEmailComposer sharedTexLegeEmailComposer] presentMailComposerTo:@"support@texlege.com" 
																			 subject:NSLocalizedStringFromTable(@"TexLege Support Question / Concern", @"StandardUI", @"Subject to be included in TexLege support emails.") 
																				body:body commander:self];
			return;
		}

		if ([link.url hasPrefix:@"http://realvideo"]) {
			NSURL *interAppURL = [NSURL URLWithString:link.url];
			if ([[UIApplication sharedApplication] canOpenURL:interAppURL]) {
				if ([TexLegeReachability canReachHostWithURL:interAppURL alert:YES])
					[[UIApplication sharedApplication] openURL:interAppURL];
				return;
			}
		}
		
		/*  TODO: do something smart with the Twitter API to drop results in a tableview or something.  (TTKit or whatever?)
		 if ([link.label isEqualToString:@"Legislator Twitter Feeds"]) {
		 
		 NSString *interAppTwitter = @"twitter://list?screen_name=grgcombs&slug=texas-politicians";
		 NSURL *interAppTwitterURL = [NSURL URLWithString:interAppTwitter];
		 if (![UtilityMethods isIPadDevice] && [[UIApplication sharedApplication] canOpenURL:interAppTwitterURL]) {
		 if ([TexLegeReachability canReachHostWithURL:interAppTwitterURL alert:YES])
		 [[UIApplication sharedApplication] openURL:interAppTwitterURL];
		 return;
		 }
		 }
		 */				
		
		// save off this item's selection to our AppDelegate
		[appDelegate setSavedTableSelection:newIndexPath forKey:NSStringFromClass([self class])];
		//self.selectObjectOnAppear= link;

		NSString *urlString = [[link actualURL] absoluteString];
		
		if (isSplitViewDetail == NO) {
			SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:urlString];
			webViewController.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:webViewController animated:YES];	
			[webViewController release];			
		}
		else if (self.detailViewController) {
			SVWebViewController *webViewController = self.detailViewController;
			webViewController.address = urlString;
		}
	}
}

@end
