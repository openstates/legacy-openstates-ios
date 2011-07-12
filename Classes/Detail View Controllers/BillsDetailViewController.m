//
//  BillsDetailViewController.m
//  Created by Gregory Combs on 2/20/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "BillsDetailViewController.h"
#import "BillsFavoritesViewController.h"
#import "BillSearchDataSource.h"
#import "BillsListViewController.h"
#import "LegislatorDetailViewController.h"
#import "TableDataSourceProtocol.h"
#import "TexLegeCoreDataUtils.h"
#import "UtilityMethods.h"
#import "TableCellDataObject.h"
#import "StatesLegeAppDelegate.h"
#import "SVWebViewController.h"
#import "LocalyticsSession.h"
#import "NSDate+Helper.h"
#import "JSONKit.h"
#import "BillMetadataLoader.h"
#import "DDActionHeaderView.h"
#import "TexLegeTheme.h"
#import "TexLegeStandardGroupCell.h"
#import "BillVotesDataSource.h"
#import "OpenLegislativeAPIs.h"
#import "LocalyticsSession.h"
#import "AppendingFlowView.h"
#import "BillActionParser.h"

@interface BillsDetailViewController (Private)
- (void)setupHeader;
- (void)showLegislatorDetailsWithOpenStatesID:(id)legeID;
- (void)starButtonSetState:(BOOL)isOn;
@end

@implementation BillsDetailViewController

enum _billSections {
	kBillSubjects = 0,
	kBillVersions,
	kBillVotes,
	kBillSponsors,
	kBillActions,
	kBillLASTITEM
};

@synthesize bill, starButton, actionHeader;
@synthesize masterPopover, headerView, descriptionView, statusView;

@synthesize lab_description;

- (NSString *)nibName {
	if ([UtilityMethods isIPadDevice])
		return @"BillsDetailViewController~ipad";
	else
		return @"BillsDetailViewController~iphone";
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	UINavigationController *nav = [self navigationController];
	if (nav && [nav.viewControllers count]>3)
		[nav popToRootViewControllerAnimated:YES];
	
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
	nice_release(bill);
	self.statusView = nil;
	self.lab_description = nil;
	self.masterPopover = nil;
	self.starButton = nil;
	self.actionHeader = nil;
	nice_release(voteDS);
	self.headerView = self.descriptionView = nil;

	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	voteDS = nil;
	
	UIImage *sealImage = [UIImage imageNamed:@"seal.png"];
	UIColor *sealColor = [[UIColor colorWithPatternImage:sealImage] colorWithAlphaComponent:0.5f];	
	self.headerView.backgroundColor = sealColor;
	self.actionHeader.backgroundColor = sealColor;
	
	//self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.clearsSelectionOnViewWillAppear = NO;

	self.starButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	[starButton addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
    [starButton addTarget:self action:@selector(starButtonToggle:) forControlEvents:UIControlEventTouchDown];
	[self starButtonSetState:NO];
    starButton.frame = CGRectMake(0.0f, 0.0f, 66.0f, 66.0f);
    starButton.center = CGPointMake(25.0f, 25.0f);
	self.actionHeader.items = [NSArray arrayWithObjects:starButton, nil];
	self.actionHeader.borderGradientHidden = YES;

	NSString *thePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kBillFavoritesStorageFile];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:thePath]) {
		NSArray *tempArray = [[NSArray alloc] init];
		[tempArray writeToFile:thePath atomically:YES];
		[tempArray release];
	}	
}

- (void)viewDidUnload {
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.	
	self.starButton = nil;
	nice_release(voteDS);
	
	[super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];

	if (NO == [UtilityMethods isLandscapeOrientation] && [UtilityMethods isIPadDevice] && !bill) {
		[[OpenLegislativeAPIs sharedOpenLegislativeAPIs] queryOpenStatesBillWithID:@"HB 1" 
																		   session:nil			// defaults to current session
																		  delegate:self];
	}
	
	if (self.starButton)
		self.starButton.enabled = (bill != nil);		
}

#pragma mark -
#pragma mark Data Objects

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
		
		NSString *watchID = watchIDForBill(bill); 
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
		
		NSString *watchID = watchIDForBill(bill);
		NSMutableDictionary *foundItem = [[watchList findWhereKeyPath:@"watchID" equals:watchID] retain];
		if (!foundItem && newValue == YES) {
			foundItem = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
						 watchID, @"watchID",
						 [bill objectForKey:@"bill_id"], @"bill_id",
						 [bill objectForKey:@"session"], @"session",
						 [bill objectForKey:@"title"], @"title",
						 nil] retain];
			if (newValue == YES) {
				NSNumber *count = [NSNumber numberWithInteger:[watchList count]];
				[foundItem setObject:count forKey:@"displayOrder"];
				[watchList addObject:foundItem];
				
				NSDictionary *tagBill = [NSDictionary dictionaryWithObject:watchID forKey:@"bill"];
				[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"BILL_FAVORITE" attributes:tagBill];				
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

- (void)setupHeader {	
	if (!bill)
		return;
	
	NSString *session = [bill objectForKey:@"session"];
	NSString *billTitle = [NSString stringWithFormat:@"(%@) %@", session, [bill objectForKey:@"bill_id"]];
	self.navigationItem.title = billTitle;
	
	@try {
		NSArray *idComponents = [[bill objectForKey:@"bill_id"] componentsSeparatedByString:@" "];
		
		NSString *longTitle = [[[[[BillMetadataLoader sharedBillMetadataLoader] metadata] objectForKey:@"types"] 
							   findWhereKeyPath:@"title" 
							   equals:[idComponents objectAtIndex:0]] objectForKey:@"titleLong"];
		billTitle = [NSString stringWithFormat:@"(%@) %@ %@", 
					 session, longTitle, [idComponents lastObject]];
		
	}
	@catch (NSException * e) {
	}
	self.actionHeader.titleLabel.text = billTitle;
	[self.actionHeader setNeedsDisplay];
	
	NSDictionary *currentAction = [[bill objectForKey:@"actions"] lastObject];
	NSDate *currentActionDate = [NSDate dateFromString:[currentAction objectForKey:@"date"]];
	NSString *actionDateString = [NSDate stringForDisplayFromDate:currentActionDate];
	
	NSMutableString *descText = [NSMutableString stringWithString:NSLocalizedStringFromTable(@"Activity: ", @"DataTableUI", @"Section header to list latest bill activity")];
	[descText appendFormat:@"%@ (%@)\r", [currentAction objectForKey:@"action"], actionDateString];
	[descText appendString:[bill objectForKey:@"title"]];	// the summary of the bill
	self.lab_description.text = descText;
	
	AppendingFlowView *statV = self.statusView;
	statV.uniformWidth = NO;
	if ([UtilityMethods isIPadDevice]) {
		statV.preferredBoxSize = CGSizeMake(80.f, 43.f);	
		statV.connectorSize = CGSizeMake(25.f, 6.f);
	}
	else {
		statV.preferredBoxSize = CGSizeMake(75.f, 40.f);	
		statV.connectorSize = CGSizeMake(7.f, 6.f);	
		statV.font = [TexLegeTheme boldTwelve];
		statV.insetMargin = CGSizeMake(13.f, 10.f);
	}

	BillActionParser *parser = [[BillActionParser alloc] init];
	NSArray *tempList = [[parser parseStagesForBill:bill] allValues];
	[parser release];
	
	if (NO == IsEmpty(tempList)) {
		NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"stageNumber" ascending:YES];
		tempList = [tempList sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
		self.statusView.stages = tempList;
	}		
}

- (void)setBill:(NSMutableDictionary *)newBill {
	if (self.starButton)
		self.starButton.enabled = (newBill != nil);		

	nice_release(bill);
	
	if (newBill) {
		bill = [newBill retain];
		
		self.tableView.dataSource = self;
				
		[self setupHeader];
		
		if (self.starButton)
			[self starButtonSetState:[self isFavorite]];
		
		if (masterPopover != nil) {
			[masterPopover dismissPopoverAnimated:YES];
		}		
		
		[self.tableView reloadData];
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

- (void)starButtonSetState:(BOOL)isOn {
	starButton.tag = isOn;
	if (isOn) {
		[starButton setImage:[UIImage imageNamed:@"starButtonLargeOff"] forState:UIControlStateHighlighted];
		[starButton setImage:[UIImage imageNamed:@"starButtonLargeOn"] forState:UIControlStateNormal];
	}
	else {
		[starButton setImage:[UIImage imageNamed:@"starButtonLargeOff"] forState:UIControlStateNormal];
		[starButton setImage:[UIImage imageNamed:@"starButtonLargeOn"] forState:UIControlStateHighlighted];
	}
}

- (IBAction)starButtonToggle:(id)sender { 	
	if (sender && [sender isEqual:starButton]) {
		BOOL isFavorite = [self isFavorite];
		[self starButtonSetState:!isFavorite];
		[self setFavorite:!isFavorite];		
	}
	// We're turning this off for now, we don't need the extended action menu, yet.
	// Reset action picker
	//		[self.actionHeader shrinkActionPicker];
	
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
#pragma mark Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *secTitle = nil;
	switch (section) {
		case kBillSubjects:
			secTitle = NSLocalizedStringFromTable(@"Subject(s)", @"DataTableUI", @"Section title listing the subjects or categories of the bill");
			break;
		case kBillSponsors:
			secTitle = NSLocalizedStringFromTable(@"Sponsor(s)", @"DataTableUI", @"Section title listing the legislators who sponsored the bill");
			break;
		case kBillVersions:
			secTitle = NSLocalizedStringFromTable(@"Version(s)", @"DataTableUI", @"Section title listing the various versions of the bill text");
			break;
		case kBillActions:
			secTitle = NSLocalizedStringFromTable(@"Action History", @"DataTableUI", @"Section title listing the latest actions for the bill");
			break;
		case kBillVotes:
			secTitle = NSLocalizedStringFromTable(@"Votes", @"DataTableUI", @"Section title listing the available legislative votes on the bill");
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
    
	BOOL isClickable = 	NO == (([indexPath section] == kBillActions) || 
							   ([indexPath section] == kBillVotes));
	
    NSString *CellIdentifier =[NSString stringWithFormat:@"%@-%d", [TexLegeStandardGroupCell cellIdentifier], isClickable];
    
    TexLegeStandardGroupCell *cell = (TexLegeStandardGroupCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[TexLegeStandardGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		if (!isClickable) {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.accessoryView = nil;
		}
    }
    
	if (bill) {
		switch ([indexPath section]) {
			case kBillSubjects:
			{
				NSString *subject = [[bill objectForKey:@"subjects"] objectAtIndex:indexPath.row];
				//cell.textLabel.text = subject;
				cell.detailTextLabel.text = subject;
				cell.textLabel.text = @"";
			}
				break;
			case kBillSponsors: 
			{
				NSDictionary *sponsor = [[bill objectForKey:@"sponsors"] objectAtIndex:indexPath.row];
				cell.detailTextLabel.text = [sponsor objectForKey:@"name"];
				cell.textLabel.text = [[sponsor objectForKey:@"type"] capitalizedString];
			}
				break;
			case kBillVersions: 
			{				
				NSDictionary *version = [[bill objectForKey:@"versions"] objectAtIndex:indexPath.row];
				NSString *textName = nil;
				NSString *senateString = stringForChamber(SENATE, TLReturnFull);
				NSString *houseString = stringForChamber(HOUSE, TLReturnFull);
				NSString *comRep = NSLocalizedStringFromTable(@"%@ Committee Report", @"DataTableUI", @"Preceded by the legislative chamber");
				
				NSString *name = [version objectForKey:@"name"];
				if ([name hasSuffix:@"I"])
					textName = NSLocalizedStringFromTable(@"Introduced", @"DataTableUI", @"A bill activity stating the bill has been introduced");
				else if ([name hasSuffix:@"E"])
					textName = NSLocalizedStringFromTable(@"Engrossed", @"DataTableUI", @"A bill activity stating the bill has been engrossed (passed and sent to the other chamber)");
				else if ([name hasSuffix:@"S"])
					textName = [NSString stringWithFormat:comRep, senateString];
				else if ([name hasSuffix:@"H"])
					textName = [NSString stringWithFormat:comRep, houseString];
				else if ([name hasSuffix:@"A"])
					textName = NSLocalizedStringFromTable(@"Amendments Printing", @"DataTableUI", @"A bill activity saying that they legislature is printing amendments");
				else if ([name hasSuffix:@"F"])
					textName = NSLocalizedStringFromTable(@"Enrolled", @"DataTableUI", @"A bill activity stating that the bill has been enrolled (like a law)");
				else
					textName = name;
				cell.textLabel.text = @"";
				cell.detailTextLabel.text = textName;
			}
				break;
			case kBillVotes: 
			{				
				NSDictionary *vote = [[bill objectForKey:@"votes"] objectAtIndex:indexPath.row];
				NSDate *voteDate = [NSDate dateFromString:[vote objectForKey:@"date"]];
				NSString *voteDateString = [NSDate stringForDisplayFromDate:voteDate];
				
				BOOL passed = [[vote objectForKey:@"passed"] boolValue];
				NSString *passedString = passed ? NSLocalizedStringFromTable(@"Passed", @"DataTableUI", @"Whether a bill passed/failed") : NSLocalizedStringFromTable(@"Failed", @"DataTableUI", @"Whether a bill passed/failed");
				NSInteger chamber = chamberFromOpenStatesString([vote objectForKey:@"chamber"]);
				NSString *chamberString = stringForChamber(chamber, TLReturnFull);
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@ (%@)",
											 [[vote objectForKey:@"motion"] capitalizedString],
											 chamberString, voteDateString];
				cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@ - %@ - %@)", passedString,
									   [vote objectForKey:@"yes_count"], [vote objectForKey:@"no_count"],
									   [vote objectForKey:@"other_count"]];
			}
				break;
			case kBillActions: 
			{
				NSDictionary *currentAction = [[bill objectForKey:@"actions"] objectAtIndex:indexPath.row];
				if (!IsEmpty([currentAction objectForKey:@"date"])) {
					NSDate *currentActionDate = [NSDate dateFromString:[currentAction objectForKey:@"date"]];
					NSString *actionDateString = [NSDate stringForDisplayFromDate:currentActionDate];
					cell.textLabel.text = actionDateString;
				}
				if (!IsEmpty([currentAction objectForKey:@"action"])) {
					NSString *desc = nil;
					if (!IsEmpty([currentAction objectForKey:@"actor"])) {
						NSInteger chamberCode = chamberFromOpenStatesString([currentAction objectForKey:@"actor"]);
						if (chamberCode == HOUSE || chamberCode == SENATE) {
							desc = [NSString stringWithFormat:@"(%@) %@", 
									stringForChamber(chamberCode, TLReturnFull), 
									[currentAction objectForKey:@"action"]];
						}
					}
					if (!desc)
						desc = [currentAction objectForKey:@"action"];
					cell.detailTextLabel.text = desc;
				}
			}
				break;
			default:
				break;
		}
	}
    
    return cell;
}

// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
	// deselect the new row using animation
	[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];	
	
	switch (newIndexPath.section) {
		case kBillSubjects: {
			NSString *subject = [[bill objectForKey:@"subjects"] objectAtIndex:newIndexPath.row];
			BillsListViewController *catResultsView = nil;
			BOOL preexisting = NO;
			if ([UtilityMethods isIPadDevice] && [UtilityMethods isLandscapeOrientation]) {
				id tempView = [[[StatesLegeAppDelegate appDelegate] masterNavigationController] visibleViewController];
				if ([tempView isKindOfClass:[BillsListViewController class]]) {
					catResultsView = (BillsListViewController *)[tempView retain];
					preexisting = YES;
				}
			}
			if (!catResultsView) {
				catResultsView = [[BillsListViewController alloc] initWithStyle:UITableViewStylePlain];
			}
			[catResultsView setTitle:subject];
			BillSearchDataSource *dataSource = [catResultsView valueForKey:@"dataSource"];
			[dataSource startSearchForSubject:subject chamber:[[bill objectForKey:@"chamber"] integerValue]];
			if (!preexisting) {
				if ([UtilityMethods isIPadDevice] && [UtilityMethods isLandscapeOrientation])
					[[[StatesLegeAppDelegate appDelegate] masterNavigationController] pushViewController:catResultsView animated:YES];
				else
					[self.navigationController pushViewController:catResultsView animated:YES];
			}
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
				NSString *urlString = [version objectForKey:@"url"];
								
				SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:urlString];
				webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
				[self presentModalViewController:webViewController animated:YES];	
				[webViewController release];
			}
		}
			break;
		case kBillVotes: {
			NSMutableDictionary *vote = [[bill objectForKey:@"votes"] objectAtIndex:newIndexPath.row];
			if (vote) {
				if (!voteDS || NO == [voteDS.voteID isEqualToString:[vote objectForKey:@"vote_id"]]) {
					if (voteDS)
						[voteDS release];
					voteDS = [[BillVotesDataSource alloc] initWithBillVotes:vote];
				}
				NSString *titleString = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ %@ Vote", @"DataTableUI", @"As in HB 323 Final Passage Vote"), 
										 [bill objectForKey:@"bill_id"], [[vote objectForKey:@"motion"] capitalizedString]];
				BillVotesViewController *voteViewController = [[BillVotesViewController alloc] initWithStyle:UITableViewStyleGrouped];
				voteViewController.tableView.dataSource = voteDS;
				voteViewController.tableView.delegate = voteDS;
				voteDS.viewController = voteViewController;
				[self.navigationController pushViewController:voteViewController animated:YES];
				voteViewController.navigationItem.title = titleString;
				[voteViewController release];
	
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
	}
	
	UIAlertView *alert = [[ UIAlertView alloc ] 
						  initWithTitle:NSLocalizedStringFromTable(@"Network Error", @"AppAlerts", @"Title for alert stating there's been an error when connecting to a server")
						  message:NSLocalizedStringFromTable(@"There was an error while contacting the server for bill information.  Please check your network connectivity or try again.", @"AppAlerts", @"")
						  delegate:nil // we're static, so don't do "self"
						  cancelButtonTitle: NSLocalizedStringFromTable(@"Cancel", @"StandardUI", @"Button cancelling some activity")
						  otherButtonTitles:nil];
	[ alert show ];	
	[ alert release];
}


- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
	if ([request isGET] && [response isOK]) {  
		// Success! Let's take a look at the data  
		self.bill = [response.body mutableObjectFromJSONData];	
		
		NSDictionary *tagBill = [NSDictionary dictionaryWithObject:watchIDForBill(self.bill) forKey:@"bill"];
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"BILL_SELECT" attributes:tagBill];
	}
}


@end

