//
//  BillsDetailViewController.m
//  TexLege
//
//  Created by Gregory Combs on 2/20/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "BillsDetailViewController.h"
#import "BillsFavoritesViewController.h"
#import "BillSearchDataSource.h"
#import "BillsListDetailViewController.h"
#import "LegislatorDetailViewController.h"
#import "TableDataSourceProtocol.h"
#import "TexLegeCoreDataUtils.h"
#import "UtilityMethods.h"
#import "TableCellDataObject.h"
#import "TexLegeAppDelegate.h"
#import "MiniBrowserController.h"
#import "LocalyticsSession.h"
#import "NSDate+Helper.h"
#import <RestKit/Support/JSON/JSONKit/JSONKit.h>

@interface BillsDetailViewController (Private)
- (void) setupHeader;
- (void)showLegislatorDetailsWithOpenStatesID:(id)legeID;
@end

@implementation BillsDetailViewController

enum _billSections {
	kBillSubjects = 0,
	kBillSponsors,
	kBillVersions,
	kBillActions,
	kBillVotes,
	kBillLASTITEM
};

@synthesize bill, starButton;
@synthesize masterPopover, headerView, descriptionView, statusView;

@synthesize lab_title, lab_description;
@synthesize stat_filed, stat_thisPassComm, stat_thisPassVote, stat_thatPassComm, stat_thatPassVote, stat_governor, stat_isLaw;


#pragma mark -
#pragma mark View lifecycle

- (NSString *)nibName {
	if ([UtilityMethods isIPadDevice])
		return @"BillsDetailViewController~ipad";
	else
		return @"BillsDetailViewController~iphone";
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//UIImage *sealImage = [UIImage imageWithContentsOfResolutionIndependentFile:@"seal.png"];
	UIImage *sealImage = [UIImage imageNamed:@"seal.png"];
	UIColor *sealColor = [[UIColor colorWithPatternImage:sealImage] colorWithAlphaComponent:0.5f];	
	self.headerView.backgroundColor = sealColor;
	
	//self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.clearsSelectionOnViewWillAppear = NO;
	
	NSString *thePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kBillFavoritesStorageFile];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:thePath]) {
		NSArray *tempArray = [[NSArray alloc] init];
		[tempArray writeToFile:thePath atomically:YES];
		[tempArray release];
	}	
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	UINavigationController *nav = [self navigationController];
	if (nav && [nav.viewControllers count]>2)
		[nav popToRootViewControllerAnimated:YES];
		
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.	
	self.headerView = self.descriptionView = self.statusView = nil;
	self.lab_title = nil;
	self.lab_description = nil;
	self.starButton = nil;
	self.stat_filed = self.stat_thisPassComm = self.stat_thisPassVote = self.stat_thatPassComm = self.stat_thatPassVote = self.stat_governor = self.stat_isLaw = nil;
	self.masterPopover = nil;
	
	[super viewDidUnload];
}


- (void)dealloc {
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];

	self.bill = nil;
	self.headerView = self.descriptionView = self.statusView = nil;
	self.lab_title = nil;
	self.lab_description = nil;
	self.stat_filed = self.stat_thisPassComm = self.stat_thisPassVote = self.stat_thatPassComm = self.stat_thatPassVote = self.stat_governor = self.stat_isLaw = nil;
	self.masterPopover = nil;
	self.starButton = nil;
	[super dealloc];
}

- (id)dataObject {
	return self.bill;
}

- (void)setDataObject:(id)newObj {
	[self setBill:newObj];
}

- (BOOL)isFavorite {
	if (bill)
	{
		NSString *thePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kBillFavoritesStorageFile];
		NSArray *watchList = [[NSArray alloc] initWithContentsOfFile:thePath];
		
		NSString *watchID = [NSString stringWithFormat:@"%@:%@", [bill objectForKey:@"session"],[bill objectForKey:@"bill_id"]]; 
		NSDictionary *foundItem = [watchList findWhereKeyPath:@"watchID" equals:watchID];
		[watchList release];
		
		if (foundItem)
			return YES;
	}
	return NO;
}

- (void)setFavorite:(BOOL)newValue {
	if (bill)
	{
		NSString *thePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kBillFavoritesStorageFile];
		NSMutableArray *watchList = [[NSMutableArray alloc] initWithContentsOfFile:thePath];
		
		NSString *watchID = [NSString stringWithFormat:@"%@:%@", [bill objectForKey:@"session"],[bill objectForKey:@"bill_id"]]; 
		NSMutableDictionary *foundItem = [[watchList findWhereKeyPath:@"watchID" equals:watchID] retain];
		if (!foundItem && newValue == YES) {
			foundItem = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
						 watchID, @"watchID",
						 [bill objectForKey:@"bill_id"], @"name",
						 [bill objectForKey:@"session"], @"session",
						 [bill objectForKey:@"title"], @"description",
						 nil] retain];
			if (newValue == YES) {
				NSNumber *count = [NSNumber numberWithInteger:[watchList count]];
				[foundItem setObject:count forKey:@"displayOrder"];
				[watchList addObject:foundItem];
			}
		}
		else if (foundItem && newValue == NO)
			[watchList removeObject:foundItem];

		[watchList writeToFile:thePath atomically:YES];

		[foundItem release];
		[watchList release];
		
	}
}

- (void)showLegislatorDetailsWithOpenStatesID:(id)legeID
{
	if (!legeID)
		return;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.openstatesID == %@", legeID];
	LegislatorObj *legislator = [LegislatorObj objectWithPredicate:predicate];
	if (legislator) {
		LegislatorDetailViewController *legVC = [[LegislatorDetailViewController alloc] initWithNibName:@"LegislatorDetailViewController" bundle:nil];
		legVC.legislator = legislator;	
		[self.navigationController pushViewController:legVC animated:YES];
		[legVC release];
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *secTitle = nil;
	switch (section) {
		case kBillSubjects:
			secTitle = @"Subject(s)";
			break;
		case kBillSponsors:
			secTitle = @"Sponsor(s)";
			break;
		case kBillVersions:
			secTitle = @"Version(s)";
			break;
		case kBillActions:
			secTitle = @"Action History";
			break;
		case kBillVotes:
			secTitle = @"Votes";
			break;
		default:
			secTitle = @"";
			break;
	}
	return secTitle;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kBillLASTITEM;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	/* ////// Section 0: Basic Info
	 */
	NSInteger rows = 0;
	if (bill) {
		switch (section) {
			case kBillSubjects:
				rows = [[bill objectForKey:@"subjects"] count];
				break;
			case kBillSponsors:
				rows = [[bill objectForKey:@"sponsors"] count];
				break;
			case kBillVersions:
				rows = [[bill objectForKey:@"versions"] count];
				break;
			case kBillActions:
				rows = [[bill objectForKey:@"actions"] count];
				break;
			case kBillVotes:
				rows = [[bill objectForKey:@"votes"] count];
				break;
			default:
				break;
		}
	}
	return rows;

}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	if (bill) {
		switch ([indexPath section]) {
			case kBillSubjects:
			{
				NSString *subject = [[bill objectForKey:@"subjects"] objectAtIndex:indexPath.row];// capitalizedString];
				cell.textLabel.text = subject;
			}
				break;
			case kBillSponsors: 
			{
				NSDictionary *sponsor = [[bill objectForKey:@"sponsors"] objectAtIndex:indexPath.row];
				cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",[sponsor objectForKey:@"name"], [[sponsor objectForKey:@"type"] capitalizedString]];
				// [sponsor objectForKey:@"leg_id"] is the same as legislatorObj.openstatesID
			}
				break;
			case kBillVersions: 
			{				
				NSDictionary *version = [[bill objectForKey:@"versions"] objectAtIndex:indexPath.row];
				cell.textLabel.text = [NSString stringWithFormat:@"Bill Text (%@)", [version objectForKey:@"name"]];
			}
				break;
			case kBillVotes: 
			{				
				NSDictionary *vote = [[bill objectForKey:@"votes"] objectAtIndex:indexPath.row];
				cell.textLabel.text = [NSString stringWithFormat:@"%@", [vote objectForKey:@"name"]];
			}
				break;
			case kBillActions: 
			{
				NSDictionary *currentAction = [[bill objectForKey:@"actions"] objectAtIndex:indexPath.row];
				NSDate *currentActionDate = [NSDate dateFromString:[currentAction objectForKey:@"date"]];
				NSString *actionDateString = [NSDate stringForDisplayFromDate:currentActionDate];
				cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [currentAction objectForKey:@"action"], actionDateString];
			}
				break;
			default:
				break;
		}
	}
    
    return cell;
}


- (void)setupHeader {	
	if (!bill)
		return;
	
	NSString *session = nil;
	@try {
		session = [UtilityMethods ordinalNumberFormat:[[bill objectForKey:@"session"] integerValue]];
	}
	@catch (NSException * e) {
		session = [bill objectForKey:@"session"];
	}
	
	NSString *billTitle = [NSString stringWithFormat:@"(%@) %@", session, [bill objectForKey:@"bill_id"]];
	self.navigationItem.title = billTitle;

	@try {
		if ([bill objectForKey:@"chamber"] && [bill objectForKey:@"type"]) {
			NSString *chamber = @"House";
			if ([[bill objectForKey:@"chamber"] isEqualToString:@"upper"])
				chamber = @"Senate";
			id billType = [bill objectForKey:@"type"];
			if ([billType isKindOfClass:[NSArray class]])
				billType = [billType objectAtIndex:0];
			if ([billType isKindOfClass:[NSString class]]) {
				NSArray *idComponents = [[bill objectForKey:@"bill_id"] componentsSeparatedByString:@" "];				
				billTitle = [NSString stringWithFormat:@"%@ %@ %@", 
							 chamber, [billType capitalizedString], [idComponents lastObject]];
			}
		}			
	}
	@catch (NSException * e) {
	}
	self.lab_title.text = billTitle;	
	
	NSDictionary *currentAction = [[bill objectForKey:@"actions"] objectAtIndex:0];	// actions is already in descending order from our setBill
	NSDate *currentActionDate = [NSDate dateFromString:[currentAction objectForKey:@"date"]];
	NSString *actionDateString = [NSDate stringForDisplayFromDate:currentActionDate];
	
	NSMutableString *descText = [NSMutableString stringWithString:@"Activity: "];
	[descText appendFormat:@"%@ (%@)", [currentAction objectForKey:@"action"], actionDateString];
	[descText appendString:@"\r\r"];
	[descText appendString:[bill objectForKey:@"title"]];
	self.lab_description.text = descText;
	
}


- (void)setBill:(NSMutableDictionary *)newBill {
	if (self.starButton)
		self.starButton.enabled = (newBill != nil);		

	// this breaks our lazy loading
	//if (newBill && bill && [[newBill objectForKey:@"bill_id"] isEqualToString:[bill objectForKey:@"bill_id"]])
	//	return;
	
	if (bill) [bill release], bill = nil;
	if (newBill) {
		bill = [newBill retain];
		
		NSSortDescriptor *byDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
		NSSortDescriptor *byNum = [NSSortDescriptor sortDescriptorWithKey:@"+action_number" ascending:NO];
		[[bill objectForKey:@"actions"] sortUsingDescriptors:[NSArray arrayWithObjects:byDate, byNum, nil]];
		
		self.tableView.dataSource = self;
		
		[self setupHeader];
		
		if (self.starButton)
			self.starButton.selected = [self isFavorite];
		
		if (masterPopover != nil) {
			[masterPopover dismissPopoverAnimated:YES];
		}		
		
		[self.tableView reloadData];
//		[self.view setNeedsDisplay];
	}
}
#pragma mark -
#pragma mark Managing the popover

- (IBAction)resetTableData:(id)sender {
	// this will force our datasource to renew everything
	[self.tableView reloadData];	
}

// Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
		
	///////if (portrait && ipad && !bill)
	//////	self.bill = [[[TexLegeAppDelegate appDelegate] billsMasterVC] selectObjectOnAppear];		
	
	//if (bill)
	//	[self setupHeader];

	if (self.starButton)
		self.starButton.enabled = (bill != nil);		
}

- (IBAction)starButtonToggle:(id)sender { 	
	if ([sender isKindOfClass:[UIButton class]]) {
		UIButton *buttonView = sender;
		
		buttonView.adjustsImageWhenHighlighted = NO;
		[buttonView setImage:nil forState:UIControlStateHighlighted]; 
		buttonView.selected = !buttonView.selected;
		
		[self setFavorite:buttonView.selected];		
	}	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.starButton) {
		UIBarButtonItem *watchItem = [[[UIBarButtonItem alloc] initWithCustomView:starButton] autorelease];
		if ([UtilityMethods isIPadDevice])
			[self.navigationItem setLeftBarButtonItem:watchItem animated:YES];
		else
			[self.navigationItem setRightBarButtonItem:watchItem animated:YES];
	}
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc 
	 willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem 
	   forPopoverController: (UIPopoverController*)pc {
	//debug_NSLog(@"Entering portrait, showing the button: %@", [aViewController class]);
	barButtonItem.title = @"Bills";
	[self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
	self.masterPopover = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc 
	 willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	//debug_NSLog(@"Entering landscape, hiding the button: %@", [aViewController class]);
	[self.navigationItem setRightBarButtonItem:nil animated:YES];
	self.masterPopover = nil;
}

- (void) splitViewController:(UISplitViewController *)svc popoverController: (UIPopoverController *)pc
   willPresentViewController: (UIViewController *)aViewController
{
	if ([UtilityMethods isLandscapeOrientation]) {
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"ERR_POPOVER_IN_LANDSCAPE"];
	}	
}

#pragma mark -
#pragma mark orientations

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Web View Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {	
	//[self.chartLoadingAct startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	//[self.chartLoadingAct stopAnimating];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	//[self.chartLoadingAct stopAnimating];
}

#pragma mark -
#pragma mark Table View Delegate
// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
	// deselect the new row using animation
	[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];	
	
	switch (newIndexPath.section) {
		case kBillSubjects: {
			NSString *subject = [[bill objectForKey:@"subjects"] objectAtIndex:newIndexPath.row];
			
			BillsListDetailViewController *catResultsView = [[BillsListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
			BillSearchDataSource *dataSource = [catResultsView valueForKey:@"dataSource"];
			catResultsView.title = subject;
			[dataSource startSearchForSubject:subject chamber:[[bill objectForKey:@"chamber"] integerValue]];
			if ([UtilityMethods isIPadDevice])
				[[[TexLegeAppDelegate appDelegate] masterNavigationController] pushViewController:catResultsView animated:YES];
			else
				[self.navigationController pushViewController:catResultsView animated:YES];
			[catResultsView release];			
		}
			break;
		case kBillSponsors: {
			NSDictionary *sponsor = [[bill objectForKey:@"sponsors"] objectAtIndex:newIndexPath.row];
			[self showLegislatorDetailsWithOpenStatesID:[sponsor objectForKey:@"leg_id"]];
		}
			break;
		case kBillVersions: {
			NSDictionary *version = [[bill objectForKey:@"versions"] objectAtIndex:newIndexPath.row];
			if (version) {
				NSURL *url = [NSURL URLWithString:[version objectForKey:@"url"]];
				MiniBrowserController *mbc = [MiniBrowserController sharedBrowserWithURL:url];
				[mbc display:self.tabBarController];
			}
		}
			break;
	}
}


#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
	if (error && request) {
		debug_NSLog(@"BillDetail - Error loading bill results from %@: %@", [request description], [error localizedDescription]);
#warning present an error?
		//[[NSNotificationCenter defaultCenter] postNotificationName:kBillSearchNotifyDataError object:nil];
	}
}


- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
	if ([request isGET] && [response isOK]) {  
		// Success! Let's take a look at the data  
		
		self.bill = [response.body mutableObjectFromJSONData];
				
		//[[NSNotificationCenter defaultCenter] postNotificationName:kBillSearchNotifyDataLoaded object:nil];
	}
}


@end

