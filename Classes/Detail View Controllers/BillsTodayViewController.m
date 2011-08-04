//
//  BillsTodayViewController.m
//  Created by Gregory Combs on 3/14/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "BillsTodayViewController.h"
#import "AppDelegate.h"
#import "BillsDetailViewController.h"
#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "BillSearchDataSource.h"
#import "OpenLegislativeAPIs.h"
#import "TexLegeStandardGroupCell.h"
#import "XMLReader.h"
#import "JSONKit.h"
#import "LoadingCell.h"
#import "SLFAlertView.h"

@interface BillsTodayViewController (Private)
- (void)configureCell:(TexLegeStandardGroupCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)startSearchForRecentBills;
@end

@implementation BillsTodayViewController
@synthesize recentBills = recentBills_;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
	if ((self = [super initWithStyle:style])) {
		loadingStatus = LOADING_IDLE;
		recentBills_ = [[NSMutableArray alloc] init];
	}
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didReceiveMemoryWarning {	
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (void)dealloc {	
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
	nice_release(recentBills_);
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
	
	self.tableView.clipsToBounds = NO;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorColor = [TexLegeTheme separator];
	self.tableView.backgroundColor = [TexLegeTheme tableBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];

	[self startSearchForRecentBills];
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
	if (IsEmpty(recentBills_))
		return;
	
	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	NSDictionary *bill = [recentBills_ objectAtIndex:indexPath.row];
	if (bill) {
		NSString *bill_title = [bill objectForKey:@"title"];
		bill_title = [bill_title chopPrefix:@"Relating to " capitalizingFirst:YES];

		cell.detailTextLabel.text = bill_title;	// (description/summary)
		
		cell.textLabel.text = [NSString stringWithFormat:@"(%@) %@", 
							   [bill objectForKey:@"session"],
							   [bill objectForKey:@"bill_id"]];
		//cell.textLabel.text = [bill objectForKey:@"bill_id"];
	}	
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (loadingStatus > LOADING_IDLE) {
		if (indexPath.row == 0) {
			return [LoadingCell loadingCellWithStatus:loadingStatus tableView:aTableView];
		}
		else {	// to make things work with our upcoming configureCell:, we need to trick this a little
			indexPath = [NSIndexPath indexPathForRow:(indexPath.row-1) inSection:indexPath.section];
		}
	}

	NSString *CellIdentifier = [TexLegeStandardGroupCell cellIdentifier];
	
	TexLegeStandardGroupCell *cell = (TexLegeStandardGroupCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
	if (!IsEmpty(recentBills_))
		return [recentBills_ count];
	else if (loadingStatus > LOADING_IDLE)
		return 1;
	else
		return 0;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (NO == [UtilityMethods isIPadDevice]) {
		[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	
	if (IsEmpty(recentBills_) || [recentBills_ count] <= indexPath.row)
		return;
	
	NSDictionary *bill = [recentBills_ objectAtIndex:indexPath.row];
	if (bill && [bill objectForKey:@"bill_id"]) {
			
		BOOL changingViews = NO;
		
		BillsDetailViewController *detailView = nil;
		if ([UtilityMethods isIPadDevice]) {
			id aDetail = [[[AppDelegate appDelegate] detailNavigationController] visibleViewController];
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
																		   session:[bill objectForKey:@"session"] // nil defaults to current session
																		  delegate:detailView];
		
		if (![UtilityMethods isIPadDevice])
			[self.navigationController pushViewController:detailView animated:YES];
		else if (changingViews)
			//[[[AppDelegate appDelegate] detailNavigationController] pushViewController:detailView animated:YES];
			[[[AppDelegate appDelegate] detailNavigationController] setViewControllers:[NSArray arrayWithObject:detailView] animated:NO];
	}			
}

#warning state specific (Todays Bills)
- (void)startSearchForRecentBills {
	NSDictionary *queryParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 @"todaysbillspassed", @"Type",
								 nil];
	if ([TexLegeReachability canReachHostWithURL:[NSURL URLWithString:tloApiBaseURL] alert:YES]) {
		loadingStatus = LOADING_ACTIVE;
		[[[OpenLegislativeAPIs sharedOpenLegislativeAPIs] tloApiClient] get:@"/MyTLO/RSS/RSS.aspx" 
																queryParams:queryParams 
																   delegate:self];
	}
	else {
		loadingStatus = LOADING_NO_NET;
	}
}

#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
	if (error && request) {
		RKLogError(@"Error loading search results from %@: %@", [request description], [error localizedDescription]);
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:kBillSearchNotifyDataError object:self];
	
	[SLFAlertView showWithTitle:NSLocalizedStringFromTable(@"Network Error", @"AppAlerts", @"Title for alert stating there's been an error when connecting to a server")
						message:NSLocalizedStringFromTable(@"There was an error while contacting the server for bill information.  Please check your network connectivity or try again.", @"AppAlerts", @"") 
					buttonTitle:NSLocalizedStringFromTable(@"Cancel", @"StandardUI", @"Button title cancelling some action")];
	
	loadingStatus = LOADING_NO_NET;
}


- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
	// Success! Let's take a look at the data  
	
	loadingStatus = LOADING_NO_NET;

	[recentBills_ removeAllObjects];	
	NSError *error = nil;
	NSMutableDictionary *results = [XMLReader dictionaryForXMLData:response.body error:&error];
	if (!error) {
		@try {
			loadingStatus = LOADING_IDLE;
			for (NSMutableDictionary *bill in [results valueForKeyPath:@"rss.channel.item"]) {
				NSString *billNumber = [bill valueForKeyPath:@"title.text"];
				NSString *billDesc = [bill valueForKeyPath:@"description.text"];
				NSString *billSession = [bill valueForKeyPath:@"link.text"];
				if (IsEmpty(billNumber))
					continue;
				
				NSMutableDictionary *newBill = [[NSMutableDictionary alloc] init];
				
				if (!IsEmpty(billDesc))
					[newBill setObject:billDesc forKey:@"title"];
				
				NSRegularExpression *regex = nil;
				
				if (!IsEmpty(billSession)) {
					regex = [NSRegularExpression regularExpressionWithPattern:@"LegSess=[0-9]+" 
																	  options:NSRegularExpressionCaseInsensitive 
																		error:&error];

					NSTextCheckingResult *match = [regex firstMatchInString:billSession options:0 range:NSMakeRange(0, [billSession length])];
					if (match && !NSEqualRanges(match.range, NSMakeRange(NSNotFound, 0))) {
						// Since we know that we found a match, get the substring from the parent string by using our NSRange object
						NSRange newRange;
						newRange.location = match.range.location+8; // length of LegSess=
						newRange.length = match.range.length-8;
						NSString *session = [billSession substringWithRange:newRange];
						if (!IsEmpty(session))
							[newBill setObject:session forKey:@"session"];
					}
				}
				
				regex = [NSRegularExpression regularExpressionWithPattern:@"[HSBJCR]+ [0-9]+" 
																					   options:NSRegularExpressionCaseInsensitive 
																						 error:&error];

				NSTextCheckingResult *match = [regex firstMatchInString:billNumber options:0 range:NSMakeRange(0, [billNumber length])];
				if (match && !NSEqualRanges(match.range, NSMakeRange(NSNotFound, 0))) {
					// Since we know that we found a match, get the substring from the parent string by using our NSRange object
					NSString *billID = [billNumber substringWithRange:match.range];
					if (!IsEmpty(billID))
						[newBill setObject:billID forKey:@"bill_id"];
				}
				[recentBills_ addObject:newBill];
				
				[newBill release];
			}
			[recentBills_ sortUsingComparator:^(NSMutableDictionary *item1, NSMutableDictionary *item2) {
				NSString *bill_id1 = [item1 objectForKey:@"bill_id"];
				NSString *bill_id2 = [item2 objectForKey:@"bill_id"];
				return [bill_id1 compare:bill_id2 options:NSNumericSearch];
			}];		
		}
		@catch (NSException * e) {
			@try {
				id issue = [results valueForKeyPath:@"rss.channel.item.title.text"];
				if ([issue isKindOfClass:[NSString class]] && !IsEmpty(issue))
					if ([issue hasPrefix:@"No bills have been passed today"]) {
						loadingStatus = LOADING_IDLE;

						[SLFAlertView showWithTitle:NSLocalizedStringFromTable(@"No Bills Passed Today (Yet)", @"AppAlerts", @"Title for alert box")
											message:NSLocalizedStringFromTable(@"There are no bills passed today.  Either it is (very) early in the day, or the legislature is in recess.", @"AppAlerts", @"") 
										buttonTitle:NSLocalizedStringFromTable(@"Cancel", @"StandardUI", @"Button title cancelling some action")];
						
					}
			}
			@catch (NSException * eOther) {
				error = [NSError errorWithDomain:@"com.texlege.texlege" code:-9999 userInfo:[NSDictionary dictionaryWithObject:e forKey:@"Exception"]];
			}
			//NSString *json = [results JSONString];
			//RKLogDebug(@"%@", json);
			//RKLogDebug(@"%@", [results valueForKeyPath:@"rss.channel.item.title.text"]);
		}
		
	}
	if (error) {
		[self request:request didFailLoadWithError:error];
	}
	
	[self.tableView reloadData];		
}

@end

