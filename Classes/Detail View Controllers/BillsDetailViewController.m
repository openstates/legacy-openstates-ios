//
//  BillsDetailViewController.m
//  TexLege
//
//  Created by Gregory Combs on 2/20/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "BillsDetailViewController.h"
//#import "BillsMasterViewController.h"
#import "TableDataSourceProtocol.h"
#import "TexLegeCoreDataUtils.h"
#import "UtilityMethods.h"
#import "TableCellDataObject.h"
#import "TexLegeAppDelegate.h"
#import "MiniBrowserController.h"
#import "LocalyticsSession.h"

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

@interface BillsDetailViewController (Private)
- (void) setupHeader;
@end

@implementation BillsDetailViewController

@synthesize bill;
@synthesize masterPopover, headerView, descriptionView, statusView;

@synthesize lab_status, lab_title, lab_sponsors, lab_subject, lab_description;
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
	self.descriptionView.backgroundColor = sealColor;
	self.statusView.backgroundColor = sealColor;
	self.headerView.backgroundColor = sealColor;
	
	self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.clearsSelectionOnViewWillAppear = NO;
	
	//self.chartView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	//self.chartView.backgroundColor = sealColor;
	
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	UINavigationController *nav = [self navigationController];
	if (nav && [nav.viewControllers count]>2)
		[nav popToRootViewControllerAnimated:YES];
	
	//self.leg_photoView.image = nil;
	
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.	
	self.headerView = self.descriptionView = self.statusView = nil;
	self.lab_status = self.lab_title = self.lab_sponsors = self.lab_subject = self.lab_description = nil;
	self.stat_filed = self.stat_thisPassComm = self.stat_thisPassVote = self.stat_thatPassComm = self.stat_thatPassVote = self.stat_governor = self.stat_isLaw = nil;
	self.masterPopover = nil;
	
	[super viewDidUnload];
}


- (void)dealloc {
	self.bill = nil;
	self.headerView = self.descriptionView = self.statusView = nil;
	self.lab_status = self.lab_title = self.lab_sponsors = self.lab_subject = self.lab_description = nil;
	self.stat_filed = self.stat_thisPassComm = self.stat_thisPassVote = self.stat_thatPassComm = self.stat_thatPassVote = self.stat_governor = self.stat_isLaw = nil;
	self.masterPopover = nil;
	
	[super dealloc];
}

- (id)dataObject {
	return self.bill;
}

- (void)setDataObject:(id)newObj {
	[self setBill:newObj];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    return cell;
}


- (void)setupHeader {	
	if (!self.bill)
		return;
	
	self.lab_title.text = [NSString stringWithFormat:@"(%@) %@", [self.bill objectForKey:@"session"], [self.bill objectForKey:@"bill_id"]];
	self.navigationItem.title = self.lab_title.text;	
	self.lab_description.text = [self.bill objectForKey:@"title"];
	
	NSMutableString *subjects = [NSMutableString stringWithFormat:@"Subjects(s): "];
	NSInteger loop = 0;
	for (NSString *subject in [self.bill objectForKey:@"scraped_subjects"]) {
		if (loop > 0 && loop+1 < [[self.bill objectForKey:@"scraped_subjects"] count])
			[subjects appendString:@", "];
		[subjects appendString:subject];
		loop++;
	}
	self.lab_subject.text = subjects;
	
	NSMutableString *sponsors = [NSMutableString stringWithFormat:@"Sponsors(s): "];
	loop = 0;
	for (NSDictionary *sponsor in [self.bill objectForKey:@"sponsors"]) {
		if (loop > 0 && loop+1 < [[self.bill objectForKey:@"sponsors"] count])
			[subjects appendString:@", "];
		[sponsors appendString:[sponsor objectForKey:@"name"]];
		// [sponsor objectForKey:@"leg_id"] is the same as legislatorObj.openstatesID
		loop++;
	}
	self.lab_sponsors.text = sponsors;
	
	NSMutableArray *actions = [NSMutableArray arrayWithArray:[self.bill objectForKey:@"actions"]];
	[actions sortUsingSelector:@selector(compareActionsByDate:)];
	NSDictionary *currentAction = [actions objectAtIndex:0];
	self.lab_status.text = [NSString stringWithFormat:@"Status: %@ (%@)", [currentAction objectForKey:@"action"], [currentAction objectForKey:@"date"]];
	
}


- (void)setBill:(NSDictionary *)newBill {
	if (newBill && self.bill && [[newBill objectForKey:@"bill_id"] isEqualToString:[self.bill objectForKey:@"bill_id"]])
		return;
	
	if (bill) [bill release], bill = nil;
	if (newBill) {
		bill = [newBill retain];
		
		self.tableView.dataSource = self;
		
		[self setupHeader];
		
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
	
	if (self.bill)
		[self setupHeader];
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

