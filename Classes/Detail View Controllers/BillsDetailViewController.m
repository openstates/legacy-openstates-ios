//
//  BillsDetailViewController.m
//  TexLege
//
//  Created by Gregory Combs on 2/20/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "BillsDetailViewController.h"
#import "BillsFavoritesViewController.h"
#import "TableDataSourceProtocol.h"
#import "TexLegeCoreDataUtils.h"
#import "UtilityMethods.h"
#import "TableCellDataObject.h"
#import "TexLegeAppDelegate.h"
#import "MiniBrowserController.h"
#import "LocalyticsSession.h"
#import "NSDate+Helper.h"

/*
@interface NSDictionary (ActionComparison)
- (NSComparisonResult)compareActionsByDate:(NSDictionary *)p;
@end
@implementation NSDictionary (ActionComparison)
- (NSComparisonResult)compareActionsByDate:(NSDictionary *)p
{	
	NSComparisonResult result = [[self objectForKey:@"date"] compare: [p objectForKey:@"date"] options:NSNumericSearch]; 
	if (result == NSOrderedAscending)
		result = NSOrderedDescending;
	else if (result == NSOrderedDescending)
		result = NSOrderedAscending;
	return result;	
}
@end
*/

@interface BillsDetailViewController (Private)
- (void) setupHeader;
@end

@implementation BillsDetailViewController

enum _billSections {
	kBillSubjects = 0,
	kBillSponsors,
	kBillVersions,
	kBillActions,
//	kBillVotes,
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
	if (self.bill)
	{
		NSString *thePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kBillFavoritesStorageFile];
		NSArray *watchList = [[NSArray alloc] initWithContentsOfFile:thePath];
		
		NSString *watchID = [NSString stringWithFormat:@"%@:%@", [self.bill objectForKey:@"session"],[self.bill objectForKey:@"bill_id"]]; 
		NSDictionary *foundItem = [watchList findWhereKeyPath:@"watchID" equals:watchID];
		[watchList release];
		
		if (foundItem)
			return YES;
	}
	return NO;
}

- (void)setFavorite:(BOOL)newValue {
	if (self.bill)
	{
		NSString *thePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kBillFavoritesStorageFile];
		NSMutableArray *watchList = [[NSMutableArray alloc] initWithContentsOfFile:thePath];
		
		NSString *watchID = [NSString stringWithFormat:@"%@:%@", [self.bill objectForKey:@"session"],[self.bill objectForKey:@"bill_id"]]; 
		NSMutableDictionary *foundItem = [[watchList findWhereKeyPath:@"watchID" equals:watchID] retain];
		if (!foundItem && newValue == YES) {
			foundItem = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
						 watchID, @"watchID",
						 [self.bill objectForKey:@"bill_id"], @"name",
						 [self.bill objectForKey:@"session"], @"session",
						 [self.bill objectForKey:@"title"], @"description",
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
/*		case kBillVotes:
			secTitle = @"Votes";
			break;
*/		default:
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
	if (self.bill) {
		switch (section) {
			case kBillSubjects:
				rows = [[self.bill objectForKey:@"subjects"] count];
				break;
			case kBillSponsors:
				rows = [[self.bill objectForKey:@"sponsors"] count];
				break;
			case kBillVersions:
				rows = [[self.bill objectForKey:@"versions"] count];
				break;
			case kBillActions:
				rows = [[self.bill objectForKey:@"actions"] count];
				break;
/*			case kBillVotes:
				rows = [[self.bill objectForKey:@"votes"] count];
				break;
*/			default:
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
    
	if (self.bill) {
		switch ([indexPath section]) {
			case kBillSubjects:
			{
				NSString *subject = [[self.bill objectForKey:@"subjects"] objectAtIndex:indexPath.row];// capitalizedString];
				cell.textLabel.text = subject;
			}
				break;
			case kBillSponsors: 
			{
				NSDictionary *sponsor = [[self.bill objectForKey:@"sponsors"] objectAtIndex:indexPath.row];
				cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",[sponsor objectForKey:@"name"], [[sponsor objectForKey:@"type"] capitalizedString]];
				// [sponsor objectForKey:@"leg_id"] is the same as legislatorObj.openstatesID
			}
				break;
			case kBillVersions: 
			{				
				NSDictionary *version = [[self.bill objectForKey:@"versions"] objectAtIndex:indexPath.row];
				cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [version objectForKey:@"name"], [version objectForKey:@"url"]];
			}
				break;
/*			case kBillVotes: 
			{				
				NSDictionary *version = [[self.bill objectForKey:@"votes"] objectAtIndex:indexPath.row];
				cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [version objectForKey:@"name"],what's going here? [version objectForKey:@"url"]];
			}
				break;
*/			case kBillActions: 
			{
				NSArray* actions = [[[self.bill objectForKey:@"actions"] reverseObjectEnumerator] allObjects];
				
				NSDictionary *currentAction = [actions objectAtIndex:indexPath.row];
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
	if (!self.bill)
		return;
	
	NSString *session = nil;
	@try {
		session = [UtilityMethods ordinalNumberFormat:[[self.bill objectForKey:@"session"] integerValue]];
	}
	@catch (NSException * e) {
		session = [self.bill objectForKey:@"session"];
	}
	
	NSString *billTitle = [NSString stringWithFormat:@"(%@) %@", session, [self.bill objectForKey:@"bill_id"]];
	self.navigationItem.title = billTitle;

	@try {
		if ([self.bill objectForKey:@"chamber"] && [self.bill objectForKey:@"type"]) {
			NSString *chamber = @"House";
			if ([[self.bill objectForKey:@"chamber"] isEqualToString:@"upper"])
				chamber = @"Senate";
			id billType = [self.bill objectForKey:@"type"];
			if ([billType isKindOfClass:[NSArray class]])
				billType = [billType objectAtIndex:0];
			if ([billType isKindOfClass:[NSString class]]) {
				NSArray *idComponents = [[self.bill objectForKey:@"bill_id"] componentsSeparatedByString:@" "];				
				billTitle = [NSString stringWithFormat:@"%@ %@ %@", 
							 chamber, [billType capitalizedString], [idComponents lastObject]];
			}
		}			
	}
	@catch (NSException * e) {
	}
	self.lab_title.text = billTitle;	
	
	NSDictionary *currentAction = [[self.bill objectForKey:@"actions"] lastObject];
	NSDate *currentActionDate = [NSDate dateFromString:[currentAction objectForKey:@"date"]];
	NSString *actionDateString = [NSDate stringForDisplayFromDate:currentActionDate];
	
	NSMutableString *descText = [NSMutableString stringWithString:@"Activity: "];
	[descText appendFormat:@"%@ (%@)", [currentAction objectForKey:@"action"], actionDateString];
	[descText appendString:@"\r\r"];
	[descText appendString:[self.bill objectForKey:@"title"]];
	self.lab_description.text = descText;
	
}


- (void)setBill:(NSDictionary *)newBill {
	if (self.starButton)
		self.starButton.enabled = (newBill != nil);		

	if (newBill && self.bill && [[newBill objectForKey:@"bill_id"] isEqualToString:[self.bill objectForKey:@"bill_id"]])
		return;
	
	if (bill) [bill release], bill = nil;
	if (newBill) {
		bill = [[newBill copy]retain];
		
		self.tableView.dataSource = self;
		
		[self setupHeader];
		
		if (self.starButton)
			self.starButton.selected = [self isFavorite];
		
		if (masterPopover != nil) {
			[masterPopover dismissPopoverAnimated:YES];
		}		
		
		[self.tableView reloadData];
		[self.view setNeedsDisplay];
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
	
	//[[PartisanIndexStats sharedPartisanIndexStats] resetChartCacheIfNecessary];
	
	////////BOOL ipad = [UtilityMethods isIPadDevice];
	////////BOOL portrait = (![UtilityMethods isLandscapeOrientation]);
	
	///////if (portrait && ipad && !self.bill)
	//////	self.bill = [[[TexLegeAppDelegate appDelegate] billsMasterVC] selectObjectOnAppear];		
	
	
	//if (self.bill)
	//	[self setupHeader];

	if (self.starButton)
		self.starButton.enabled = (self.bill != nil);		
}

- (IBAction)starButtonToggle:(id)sender { 	
	if ([sender isKindOfClass:[UIButton class]]) {
		UIButton *buttonView = sender;
		
		buttonView.adjustsImageWhenHighlighted = NO;
		[buttonView setImage:nil forState:UIControlStateHighlighted]; 
		buttonView.selected = !buttonView.selected;
		
		[self setFavorite:buttonView.selected];
		
		/*			if (buttonView.selected)
		 {
		 UIImage *imageUnwatch = [UIImage imageNamed:@"starButtonOff.png"];
		 [buttonView setImage:imageUnwatch forState:UIControlStateHighlighted]; 
		 }
		 else {
		 UIImage *imageWatch = [UIImage imageNamed:@"starButtonOn.png"];
		 [buttonView setImage:imageWatch forState:UIControlStateHighlighted]; 
		 }
		 */
	}
	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	/*
	UIButton *buttonView = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *imageWatch = [UIImage imageNamed:@"watchButton.png"];
	UIImage *imageUnwatch = [UIImage imageNamed:@"unwatchButton.png"];
	[buttonView setImage:imageWatch forState:UIControlStateNormal];
	[buttonView setImage:imageWatch forState:UIControlStateHighlighted]; 
	[buttonView setImage:imageUnwatch forState:UIControlStateSelected];
	[buttonView setBackgroundColor:[UIColor clearColor]]; 
	buttonView.frame = CGRectMake(0, 0, imageWatch.size.width, imageWatch.size.height);

	//adjustsImageWhenDisabled;       // default is YES. if YES, image is drawn lighter when disabled
	buttonView.adjustsImageWhenHighlighted = YES;
	[buttonView addTarget:self action:@selector(watchButtonToggle:) forControlEvents:UIControlEventTouchUpInside];
	 */
	
	if (self.starButton) {
		if (![UtilityMethods isIPadDevice]) {
			UIBarButtonItem *watchItem = [[[UIBarButtonItem alloc] initWithCustomView:starButton] autorelease];
			[self.navigationItem setRightBarButtonItem:watchItem animated:YES];
		}
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
	/*
	// deselect the new row using animation
	[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];	
	
	TableCellDataObject *cellInfo = [self.dataSource dataObjectForIndexPath:newIndexPath];
	
	if (!cellInfo.isClickable)
		return;
	
	if (cellInfo.entryType == DirectoryTypeCommittee) {
		CommitteeDetailViewController *subDetailController = [[CommitteeDetailViewController alloc] initWithNibName:@"CommitteeDetailViewController" bundle:nil];
		subDetailController.committee = cellInfo.entryValue;
		[self.navigationController pushViewController:subDetailController animated:YES];
		[subDetailController release];
	}
	else if (cellInfo.entryType == DirectoryTypeContributions) {
		if ([TexLegeReachability canReachHostWithURL:[NSURL URLWithString:@"http://transparencydata.org"]]) { 
			LegislatorContributionsViewController *subDetailController = [[LegislatorContributionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
			[subDetailController setQueryEntityID:cellInfo.entryValue type:[NSNumber numberWithInteger:kContributionQueryRecipient] cycle:@"-1"];
			[self.navigationController pushViewController:subDetailController animated:YES];
			[subDetailController release];
		}
	}
	else if (cellInfo.entryType == DirectoryTypeOfficeMap) {
		CapitolMap *capMap = cellInfo.entryValue;			
		[self pushMapViewWithMap:capMap];
	}
	else if (cellInfo.entryType == DirectoryTypeMail) {
		[[TexLegeEmailComposer sharedTexLegeEmailComposer] presentMailComposerTo:cellInfo.entryValue 
																		 subject:@"" body:@"" commander:self];			
	}
	else if (cellInfo.entryType > kDirectoryTypeIsURLHandler &&
			 cellInfo.entryType < kDirectoryTypeIsExternalHandler) {	// handle the URL ourselves in a webView
		NSURL *myURL = [cellInfo generateURL];
		
		if ([TexLegeReachability canReachHostWithURL:myURL]) { // do we have a good URL/connection?
			
			if ([[myURL scheme] isEqualToString:@"twitter"])
				[[UIApplication sharedApplication] openURL:myURL];
			else {
				MiniBrowserController *mbc = [MiniBrowserController sharedBrowserWithURL:myURL];
				[mbc display:self.tabBarController];
			}
		}
	}
	else if (cellInfo.entryType > kDirectoryTypeIsExternalHandler)		// tell the device to open the url externally
	{
		NSURL *myURL = [cellInfo generateURL];
		// do the URL
		
		BOOL isPhone = ([UtilityMethods canMakePhoneCalls]);
		if ((cellInfo.entryType == DirectoryTypePhone) && (!isPhone)) {
			debug_NSLog(@"Tried to make a phonecall, but this isn't a phone: %@", myURL.description);
			[UtilityMethods alertNotAPhone];
			return;
		}
		
		[UtilityMethods openURLWithoutTrepidation:myURL];
	}
	 */
}

@end

