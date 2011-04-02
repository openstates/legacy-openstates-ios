//
//  BillsKeyViewController.m
//  TexLege
//
//  Created by Gregory Combs on 3/14/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "BillsKeyViewController.h"
#import "TexLegeAppDelegate.h"
#import "BillsDetailViewController.h"
#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "DisclosureQuartzView.h"
#import "BillSearchDataSource.h"
#import "OpenLegislativeAPIs.h"
#import <RestKit/Support/JSON/JSONKit/JSONKit.h>
#import "TexLegeStandardGroupCell.h"
#import "NSDate+Helper.h"
#import "TexLegeCoreDataUtils.h"

@interface BillsKeyViewController (Private)
- (void)configureCell:(TexLegeStandardGroupCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)startSearchForKeyBills;
@end

@implementation BillsKeyViewController
@synthesize keyBills = keyBills_;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:style]) {
		keyBills_ = [[NSMutableArray alloc] init];
	}
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if ([UtilityMethods isIPadDevice] && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		if ([[[[TexLegeAppDelegate appDelegate] masterNavigationController] topViewController] isKindOfClass:[BillsKeyViewController class]])
			if ([self.navigationController isEqual:[[TexLegeAppDelegate appDelegate] detailNavigationController]])
				[self.navigationController popToRootViewControllerAnimated:YES];
		
	}	
}

- (void)didReceiveMemoryWarning {
	UINavigationController *nav = [self navigationController];
	if (nav && [nav.viewControllers count]>1)
		[nav popToRootViewControllerAnimated:YES];
	
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (void)dealloc {	
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
	
	[keyBills_ release];
	
	[super dealloc];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"TexLegeStrings" ofType:@"plist"];
	NSDictionary *textDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
	NSString *myClass = NSStringFromClass([self class]);
	NSDictionary *menuItem = [[textDict objectForKey:@"BillMenuItems"] findWhereKeyPath:@"class" equals:myClass];
	
	if (menuItem)
		self.title = [menuItem objectForKey:@"title"];
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorColor = [TexLegeTheme separator];
	self.tableView.backgroundColor = [TexLegeTheme tableBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self startSearchForKeyBills];
}

/*- (void)viewWillDisappear:(BOOL)animated {
 //	[self save:nil];
 [super viewWillDisappear:animated];
 }*/

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark -
#pragma mark Table view data source

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
}

- (void)configureCell:(TexLegeStandardGroupCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	if (IsEmpty(keyBills_))
		return;
	
	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	NSDictionary *bill = [keyBills_ objectAtIndex:indexPath.row];
	if (bill) {
		cell.detailTextLabel.text = [bill objectForKey:@"title"];
		NSMutableString *name = [NSMutableString stringWithString:[bill objectForKey:@"bill_id"]];
		if (!IsEmpty([bill objectForKey:@"passFail"]))
			[name appendFormat:@" - %@", [bill objectForKey:@"passFail"]];
		cell.textLabel.text = name;
	}
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *CellIdentifier = [TexLegeStandardGroupCell cellIdentifier];
	
	TexLegeStandardGroupCell *cell = (TexLegeStandardGroupCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[TexLegeStandardGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
												reuseIdentifier:CellIdentifier] autorelease];		
		
		cell.textLabel.textColor = [TexLegeTheme textDark];
		cell.detailTextLabel.textColor = [TexLegeTheme indexText];
		cell.textLabel.font = [TexLegeTheme boldFourteen];
	}
	[self configureCell:cell atIndexPath:indexPath];		
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (!IsEmpty(keyBills_))
		return [keyBills_ count];
	else
		return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (![UtilityMethods isIPadDevice])
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *bill = [keyBills_ objectAtIndex:indexPath.row];
	if (bill && [bill objectForKey:@"bill_id"]) {
		if (bill) {
			
			BOOL changingViews = NO;
			
			BillsDetailViewController *detailView = nil;
			if ([UtilityMethods isIPadDevice]) {
				id aDetail = [[[TexLegeAppDelegate appDelegate] detailNavigationController] visibleViewController];
				if ([aDetail isKindOfClass:[BillsDetailViewController class]])
					detailView = aDetail;
			}
			if (!detailView) {
				detailView = [[[BillsDetailViewController alloc] 
							   initWithNibName:@"BillsDetailViewController" bundle:nil] autorelease];
				changingViews = YES;
			}
			
			[detailView setDataObject:bill];
			[[OpenLegislativeAPIs sharedOpenLegislativeAPIs] queryOpenStatesBillWithID:[bill objectForKey:@"bill_id"] 
																			   session:nil			// defaults to current session
																			  delegate:detailView];
			
			if (![UtilityMethods isIPadDevice])
				[self.navigationController pushViewController:detailView animated:YES];
			else if (changingViews)
				//[[[self.splitViewController viewControllers] objectAtIndex:1] pushViewController:detailView animated:YES];
				[[[TexLegeAppDelegate appDelegate] detailNavigationController] pushViewController:detailView animated:YES];
			///[[[TexLegeAppDelegate appDelegate] detailNavigationController] setViewControllers:[NSArray arrayWithObject:detailView] animated:NO];
		}			
	}
}


// http://api.votesmart.org/Votes.getBillsByYearState?key=5fb3b476c47fcb8a21dc2ec22ca92cbb&year=2011&stateId=TX&o=JSON

- (void)startSearchForKeyBills {
	if ([TexLegeReachability canReachHostWithURL:[NSURL URLWithString:RESTKIT_BASE_URL] alert:NO]) {
		RKRequest *request = [[RKClient sharedClient] get:@"/rest.php/KeyBills" delegate:self];
		if (!request)
			NSLog(@"BillsKeyViewController: Error, unable to create RestKit request for KeyBills");
	}

}


#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
	if (error && request) {
		debug_NSLog(@"Error loading search results from %@: %@", [request description], [error localizedDescription]);
		[[NSNotificationCenter defaultCenter] postNotificationName:kBillSearchNotifyDataError object:self];
		
		UIAlertView *alert = [[[ UIAlertView alloc ] 
							   initWithTitle:[UtilityMethods texLegeStringWithKeyPath:@"Bills.NetworkErrorTitle"] 
							   message:[UtilityMethods texLegeStringWithKeyPath:@"Bills.NetworkErrorText"] 
							   delegate:nil // we're static, so don't do "self"
							   cancelButtonTitle: @"Cancel" 
							   otherButtonTitles:nil, nil] autorelease];
		[ alert show ];			
	}
}


- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
	if ([request isGET] && [response isOK]) {  
		// Success! Let's take a look at the data  
		
		[keyBills_ removeAllObjects];	
		
		[keyBills_  addObjectsFromArray:[response.body mutableObjectFromJSONData]];

		// if we wanted blocks, we'd do this instead:
		[keyBills_ sortUsingComparator:^(NSMutableDictionary *item1, NSMutableDictionary *item2) {
			NSString *bill_id1 = [item1 objectForKey:@"bill_id"];
			NSString *bill_id2 = [item2 objectForKey:@"bill_id"];
			return [bill_id1 compare:bill_id2 options:NSNumericSearch];
		}];
		
		[self.tableView reloadData];		
	}
}

@end

