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
#import "BillMetadataLoader.h"
#import "DDActionHeaderView.h"
#import "TexLegeTheme.h"
#import "TexLegeStandardGroupCell.h"
#import "BillVotesDataSource.h"
#import "OpenLegislativeAPIs.h"
#import "LocalyticsSession.h"
//#import "BillStageStackPanel.h"

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
@synthesize stat_filed, stat_thisPassComm, stat_thisPassVote, stat_thatPassComm, stat_thatPassVote, stat_governor, stat_isLaw;

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
	if (nav && [nav.viewControllers count]>2)
		[nav popToRootViewControllerAnimated:YES];
	
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
	self.bill = nil;
	self.headerView = self.descriptionView = nil;
	self.statusView = nil;
	self.lab_description = nil;
	self.stat_filed = self.stat_thisPassComm = self.stat_thisPassVote = self.stat_thatPassComm = self.stat_thatPassVote = self.stat_governor = self.stat_isLaw = nil;
	self.masterPopover = nil;
	self.starButton = nil;
	self.actionHeader = nil;
	if (voteDS)
		[voteDS release];
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

/*	Whenever we figure out the stacking view thing.
	if (self.statusView) {
		self.statusView.resizeFrame = NO;
		self.statusView.spacing = NO;
		self.statusView.orientation = HORIZONTAL;
	}	
*/
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
	if (voteDS)
		[voteDS release], voteDS = nil;	
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.	
	self.starButton = nil;
	
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

- (NSDictionary *)calcStages {
	NSInteger status = BillStageUnknown;
	NSMutableDictionary *stages = [NSMutableDictionary dictionary];
	for (NSMutableDictionary *action in [[bill objectForKey:@"actions"] reverseObjectEnumerator]) {
		NSDate *actionDate = [NSDate dateFromString:[action objectForKey:@"date"]];
				
		if ([[action objectForKey:@"action"] isEqualToString:@"Filed"])
			status = BillStageFiled;
		
		if ([[action objectForKey:@"action"] hasSubstring:@"reported favorably" caseInsensitive:YES]) {
			if (NO == [[action objectForKey:@"actor"] isEqualToString:[self.bill objectForKey:@"chamber"]])
				status = BillStageOutOfOpposingCommittee;
			else
				status = BillStageOutOfCommittee;
		}
		else if ([[action objectForKey:@"action"] hasSubstring:@"recommitted to committee" caseInsensitive:YES]){
			// demote the stage, they sent it back to committee
			
			if (NO == [[action objectForKey:@"actor"] isEqualToString:[self.bill objectForKey:@"chamber"]])
				status = BillStageChamberVoted;
			else
				status = BillStageFiled;		
		}
		
		for (id type in [action objectForKey:@"type"]) {
			if ([type isKindOfClass:[NSString class]]) {
				if ([type isEqualToString:@"bill:filed"]) {
					status = BillStageFiled;
					break;
				}
				else if ([type isEqualToString:@"bill:passed"]) {
					if (NO == [[action objectForKey:@"actor"] isEqualToString:[self.bill objectForKey:@"chamber"]])
						status = BillStageOpposingChamberVoted;
					else
						status = BillStageChamberVoted;
					break;
				}
			}
		}
		if ([[action objectForKey:@"action"] caseInsensitiveCompare:@"Passed"] == NSOrderedSame) {
			if (NO == [[action objectForKey:@"actor"] isEqualToString:[self.bill objectForKey:@"chamber"]])
				status = BillStageOpposingChamberVoted;
			else
				status = BillStageChamberVoted;		
		}
		
		if ([[action objectForKey:@"action"] caseInsensitiveCompare:@"Sent to the Governor"] == NSOrderedSame) {
			status = BillStageSentToGovernor;
		}
		else if (([[action objectForKey:@"action"] caseInsensitiveCompare:@"Signed by the Governor"] == NSOrderedSame) ||
				 ([[action objectForKey:@"action"] hasPrefix:@"Effective"]) ||
				 ([[action objectForKey:@"action"] caseInsensitiveCompare:@"Reported Enrolled"] == NSOrderedSame))
		{
			status = BillStageBecomesLaw;
		}
		else if ([[action objectForKey:@"action"] hasSubstring:@"vetoed" caseInsensitive:YES]) {
			status = BillStageVetoed;
		}
		[stages setObject:actionDate forKey:[NSNumber numberWithInteger:status]];
	}	
	[self.bill setObject:stages forKey:@"stages"];
	
	return stages;
}

- (void)handleBillStages {	
	NSDictionary *stages = [self calcStages];
	NSInteger lastStage = [[[[stages allKeys] sortedArrayUsingSelector:@selector(compare:)] lastObject] integerValue];
	
	NSArray *tiles = [NSArray arrayWithObjects:self.stat_filed, self.stat_thisPassComm, self.stat_thisPassVote, 
					  self.stat_thatPassComm, self.stat_thatPassVote, self.stat_governor, self.stat_isLaw, nil];
	
	NSInteger tileIndex = 1;
	for (UILabel *tile in tiles) {
		if (lastStage >= tileIndex) {
			tile.backgroundColor = [TexLegeTheme accentGreener];
			tile.alpha = 1.0f;
		}
		else {
			tile.backgroundColor = [TexLegeTheme texasBlue];
			tile.alpha = 0.4f;
		}
		tileIndex++;
	}
	NSInteger this = chamberForString([bill objectForKey:@"chamber"]);
	NSInteger that = this == HOUSE ? SENATE : HOUSE;

	NSString *chamberString = stringForChamber(this, TLReturnFull);
	self.stat_thisPassComm.text = [chamberString stringByAppendingString:@" Committee"];
	self.stat_thisPassVote.text = [chamberString stringByAppendingString:@" Voted"];
	
	chamberString = stringForChamber(that, TLReturnFull);
	self.stat_thatPassComm.text = [chamberString stringByAppendingString:@" Committee"];
	self.stat_thatPassVote.text = [chamberString stringByAppendingString:@" Voted"];
	
	NSString *billType = billTypeStringFromBillID([self.bill objectForKey:@"bill_id"]);
	BOOL requiresGovernor = billTypeRequiresGovernor(billType);
	BOOL requiresOpposing = billTypeRequiresOpposingChamber(billType);
	
	self.stat_thatPassComm.hidden = NO == requiresOpposing;
	self.stat_thatPassVote.hidden = NO == requiresOpposing;
	self.stat_governor.hidden = NO == requiresGovernor;
	NSString *conclusion = nil;
	if (requiresGovernor)
		conclusion = @"Becomes Law";
	else if (requiresOpposing)
		conclusion = @"Enrolled";
	else
		conclusion = @"Adopted";
	self.stat_isLaw.text = conclusion;

	
	for (UIView* strip in self.statusView.subviews) {
		if ((strip.tag == 9990 + BillStageOpposingChamberVoted) ||
			(strip.tag == 9990 + BillStageOutOfOpposingCommittee)) {
			strip.hidden = NO == requiresOpposing;
			continue;
		}
		if (strip.tag == 9990 + BillStageSentToGovernor) {
			strip.hidden = NO == requiresGovernor;
			continue;
		}
	}

	if (![stages objectForKey:[NSNumber numberWithInteger:BillStageOutOfCommittee]] && lastStage > BillStageOutOfCommittee)
	{
		self.stat_thisPassComm.backgroundColor = [UIColor darkGrayColor];
		self.stat_thisPassComm.alpha = 0.3f;
	}

	if (![stages objectForKey:[NSNumber numberWithInteger:BillStageOutOfOpposingCommittee]] && lastStage > BillStageOutOfOpposingCommittee)
	{
		self.stat_thatPassComm.backgroundColor = [UIColor darkGrayColor];
		self.stat_thatPassComm.alpha = 0.3f;
	}
	
	if ([stages objectForKey:[NSNumber numberWithInteger:BillStageVetoed]] && lastStage <= BillStageVetoed) {
		self.stat_isLaw.backgroundColor = [TexLegeTheme texasRed];
		self.stat_isLaw.alpha = 1.0f;
	}

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
		NSArray *idComponents = [[bill objectForKey:@"bill_id"] componentsSeparatedByString:@" "];
		
		NSString *longTitle = [[[[[BillMetadataLoader sharedBillMetadataLoader] metadata] objectForKey:@"types"] 
							   findWhereKeyPath:@"title" 
							   equals:[idComponents objectAtIndex:0]] objectForKey:@"titleLong"];
		billTitle = [NSString stringWithFormat:@"%@ %@", 
					 longTitle, [idComponents lastObject]];
		
	}
	@catch (NSException * e) {
	}
	self.actionHeader.titleLabel.text = billTitle;
	[self.actionHeader setNeedsDisplay];
	
	NSDictionary *currentAction = [[bill objectForKey:@"actions"] objectAtIndex:0];	// actions is already in descending order from our setBill
	NSDate *currentActionDate = [NSDate dateFromString:[currentAction objectForKey:@"date"]];
	NSString *actionDateString = [NSDate stringForDisplayFromDate:currentActionDate];
	
	NSMutableString *descText = [NSMutableString stringWithString:@"Activity: "];
	[descText appendFormat:@"%@ (%@)", [currentAction objectForKey:@"action"], actionDateString];
	[descText appendString:@"\r\r"];
	[descText appendString:[bill objectForKey:@"title"]];	// the summary of the bill
	self.lab_description.text = descText;
	
	[self handleBillStages];
	
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
				NSString *name = [version objectForKey:@"name"];
				if ([name hasSuffix:@"I"])
					textName = @"Introduced";
				else if ([name hasSuffix:@"E"])
					textName = @"Engrossed";
				else if ([name hasSuffix:@"S"])
					textName = @"Senate Committee Report";
				else if ([name hasSuffix:@"H"])
					textName = @"House Committee Report";
				else if ([name hasSuffix:@"A"])
					textName = @"Amendments Printing";
				else if ([name hasSuffix:@"F"])
					textName = @"Enrolled";
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
				NSString *passedString = passed ? @"Passed" : @"Failed";
				NSInteger chamber = chamberForString([vote objectForKey:@"chamber"]);
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
						NSInteger chamberCode = chamberForString([currentAction objectForKey:@"actor"]);
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
			BillsListDetailViewController *catResultsView = nil;
			BOOL preexisting = NO;
			if ([UtilityMethods isIPadDevice] && [UtilityMethods isLandscapeOrientation]) {
				id tempView = [[[TexLegeAppDelegate appDelegate] masterNavigationController] visibleViewController];
				if ([tempView isKindOfClass:[BillsListDetailViewController class]]) {
					catResultsView = (BillsListDetailViewController *)[tempView retain];
					preexisting = YES;
				}
			}
			if (!catResultsView) {
				catResultsView = [[BillsListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
			}
			[catResultsView setTitle:subject];
			BillSearchDataSource *dataSource = [catResultsView valueForKey:@"dataSource"];
			[dataSource startSearchForSubject:subject chamber:[[bill objectForKey:@"chamber"] integerValue]];
			if (!preexisting) {
				if ([UtilityMethods isIPadDevice] && [UtilityMethods isLandscapeOrientation])
					[[[TexLegeAppDelegate appDelegate] masterNavigationController] pushViewController:catResultsView animated:YES];
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
				NSURL *url = [NSURL URLWithString:[version objectForKey:@"url"]];
				MiniBrowserController *mbc = [MiniBrowserController sharedBrowserWithURL:url];
				[mbc display:self.tabBarController];
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
				NSString *titleString = [NSString stringWithFormat:@"%@ %@ Vote", 
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
	
	UIAlertView *alert = [[[ UIAlertView alloc ] 
			  initWithTitle:[UtilityMethods texLegeStringWithKeyPath:@"Bills.NetworkErrorTitle"] 
			  message:[UtilityMethods texLegeStringWithKeyPath:@"Bills.NetworkErrorText"] 
			  delegate:nil // we're static, so don't do "self"
			  cancelButtonTitle: @"Cancel" 
			  otherButtonTitles:nil, nil] autorelease];
	[ alert show ];	
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

