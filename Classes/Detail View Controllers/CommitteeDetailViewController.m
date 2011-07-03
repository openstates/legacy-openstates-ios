//
//  CommitteeDetailViewController.m
//  TexLege
//
//  Created by Gregory Combs on 6/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TableDataSourceProtocol.h"
#import "CommitteeDetailViewController.h"
#import "CommitteeMasterViewController.h"
#import "TexLegeCoreDataUtils.h"

#import "UtilityMethods.h"
#import "CapitolMapsDetailViewController.h"
#import "LegislatorDetailViewController.h"
#import "SVWebViewController.h"
#import "TexLegeAppDelegate.h"
#import "TexLegeTheme.h"
#import "LegislatorMasterCell.h"
#import "CommitteeMemberCell.h"
#import "CommitteeMemberCellView.h"
#import "TexLegeStandardGroupCell.h"
#import "PartisanScaleView.h"
#import "PartisanIndexStats.h"
#import "TexLegeEmailComposer.h"
#import "LocalyticsSession.h"
#import "LegislatorObj+RestKit.h"
#import "CommitteePositionObj+RestKit.h"
#import "CommitteeObj+RestKit.h"

@interface CommitteeDetailViewController (Private)
- (void) buildInfoSectionArray;
- (void) calcCommitteePartisanship;
@end

@implementation CommitteeDetailViewController

@synthesize dataObjectID, masterPopover;
@synthesize partisanSlider, membershipLab, infoSectionArray;

enum Sections {
    //kHeaderSection = 0,
	kInfoSection = 0,
    kChairSection,
    kViceChairSection,
	kMembersSection,
    NUM_SECTIONS
};
enum InfoSectionRows {
	kInfoSectionName = 0,
    kInfoSectionClerk,
    kInfoSectionPhone,
	kInfoSectionOffice,
	kInfoSectionWeb,
    NUM_INFO_SECTION_ROWS
};

CGFloat quartzRowHeight = 73.f;

- (NSString *)nibName {
	if ([UtilityMethods isIPadDevice])
		return @"CommitteeDetailViewController~ipad";
	else
		return @"CommitteeDetailViewController~iphone";	
}

#pragma mark -
#pragma mark View lifecycle

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	self.dataObjectID = nil;
	self.membershipLab = nil;
	self.partisanSlider = nil;
	self.masterPopover = nil;
	self.infoSectionArray = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resetTableData:) name:@"RESTKIT_LOADED_LEGISLATOROBJ" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resetTableData:) name:@"RESTKIT_LOADED_COMMITTEEOBJ" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resetTableData:) name:@"RESTKIT_LOADED_COMMITTEEPOSITIONOBJ" object:nil];
	
	self.clearsSelectionOnViewWillAppear = NO;
	
	UIImage *sealImage = [UIImage imageNamed:@"seal.png"];
	UIColor *sealColor = [[UIColor colorWithPatternImage:sealImage] colorWithAlphaComponent:0.5f];	
	self.tableView.tableHeaderView.backgroundColor = sealColor;	
}

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	if ([UtilityMethods isIPadDevice] == NO)
		return;
	
	// we don't have a legislator selected and yet we're appearing in portrait view ... got to have something here !!! 
	if (self.committee == nil && ![UtilityMethods isLandscapeOrientation])  {
		
		self.committee = [[[TexLegeAppDelegate appDelegate] committeeMasterVC] selectObjectOnAppear];		
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	UINavigationController *nav = [self navigationController];
	if (nav && [nav.viewControllers count]>3)
		[nav popToRootViewControllerAnimated:YES];
	
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

/*
 - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
 [self showPopoverMenus:UIDeviceOrientationIsPortrait(toInterfaceOrientation)];
 }
 */

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	//[self showPopoverMenus:UIDeviceOrientationIsPortrait(toInterfaceOrientation)];
	//[[TexLegeAppDelegate appDelegate] resetPopoverMenus];
	
	NSArray *visibleCells = self.tableView.visibleCells;
	for (id cell in visibleCells) {
		if ([cell respondsToSelector:@selector(redisplay)])
			[cell performSelector:@selector(redisplay)];
	}
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Data Objects
- (id)dataObject {
	return self.committee;
}

- (void)setDataObject:(id)newObj {
	[self setCommittee:newObj];
}

- (void)resetTableData:(NSNotification *)notification {
	if (self.dataObject) {
		[self setDataObject:self.dataObject];
	}
}

- (CommitteeObj *)committee {
	CommitteeObj *anObject = nil;
	if (self.dataObjectID) {
		@try {
			anObject = [CommitteeObj objectWithPrimaryKeyValue:self.dataObjectID];
		}
		@catch (NSException * e) {
		}
	}
	return anObject;
}


- (void)setCommittee:(CommitteeObj *)newObj {
	self.dataObjectID = nil;
	if (newObj) {
		[self view];

		if (self.masterPopover)
			[self.masterPopover dismissPopoverAnimated:YES];

		self.dataObjectID = newObj.committeeId;
		
		[self buildInfoSectionArray];
		self.navigationItem.title = newObj.committeeName;
		
		[self calcCommitteePartisanship];
		
		[self.tableView reloadData];
		[self.view setNeedsDisplay];
	}

}

#pragma mark -
#pragma mark Popover Support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
	//debug_NSLog(@"Entering portrait, showing the button: %@", [aViewController class]);
    barButtonItem.title = @"Committees";
    [self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
    self.masterPopover = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
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
#pragma mark View Setup

- (void)buildInfoSectionArray {	
	BOOL clickable = NO;
	
	NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:12]; // arbitrary
	NSDictionary *infoDict = nil;
	TableCellDataObject *cellInfo = nil;
//case kInfoSectionName:
	infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
				NSLocalizedStringFromTable(@"Committee", @"DataTableUI", @"Cell title listing a legislative committee"), @"subtitle",
				self.committee.committeeName, @"title",
				[NSNumber numberWithBool:NO], @"isClickable",
				nil, @"entryValue",
				nil];
	cellInfo = [[TableCellDataObject alloc] initWithDictionary:infoDict];
	[tempArray addObject:cellInfo];
	[infoDict release];
	[cellInfo release];

//case kInfoSectionClerk:
	NSString *text = self.committee.clerk;
	id val = self.committee.clerk_email;
	clickable = (text && [text length] && val && [val length]);
	if (!text)
		text = @"";
	if (!val)
		val = @"";
	infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
				NSLocalizedStringFromTable(@"Clerk", @"DataTableUI", @"Cell title listing a committee's assigned clerk"), @"subtitle",
				text, @"title",
				[NSNumber numberWithBool:clickable], @"isClickable",
				val, @"entryValue",
				nil];
	cellInfo = [[TableCellDataObject alloc] initWithDictionary:infoDict];
	[tempArray addObject:cellInfo];
	[infoDict release];
	[cellInfo release];
	
//case kInfoSectionPhone:	// dial the number
	text = self.committee.phone;
	clickable = (text && [text length] && [UtilityMethods canMakePhoneCalls]);
	if (!text)
		text = @"";
	if (clickable)
		val = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",text]];
	else
		val = @"";
	infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
				NSLocalizedStringFromTable(@"Phone", @"DataTableUI", @"Cell title listing a phone number"), @"subtitle",
				text, @"title",
				[NSNumber numberWithBool:clickable], @"isClickable",
				val, @"entryValue",
				nil];
	cellInfo = [[TableCellDataObject alloc] initWithDictionary:infoDict];
	[tempArray addObject:cellInfo];
	[infoDict release];
	[cellInfo release];
	
	//case kInfoSectionOffice: // open the office map
	text = self.committee.office;
	clickable = (text && [text length]);
	if (!text)
		text = @"";
	if (clickable)
		val = [CapitolMap mapFromOfficeString:self.committee.office];
	else
		val = @"";
	
	infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
				NSLocalizedStringFromTable(@"Location", @"DataTableUI", @"Cell title listing an office location (office number or stree address)"), @"subtitle",
				text, @"title",
				[NSNumber numberWithBool:clickable], @"isClickable",
				val, @"entryValue",
				nil];
	cellInfo = [[TableCellDataObject alloc] initWithDictionary:infoDict];
	[tempArray addObject:cellInfo];
	[infoDict release];
	[cellInfo release];
	
//case kInfoSectionWeb:	 // open the web page
	clickable = (text && [text length]);
	if (clickable)
		val = [UtilityMethods safeWebUrlFromString:self.committee.url];
	else
		val = @"";
	infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
				NSLocalizedStringFromTable(@"Web", @"DataTableUI", @"Cell title listing a web address"), @"subtitle",
				NSLocalizedStringFromTable(@"Website & Meetings", @"DataTableUI", @"Cell title for a website link detailing committee meetings"), @"title",
				[NSNumber numberWithBool:clickable], @"isClickable",
				val, @"entryValue",
				nil];
	cellInfo = [[TableCellDataObject alloc] initWithDictionary:infoDict];
	[tempArray addObject:cellInfo];
	[infoDict release];
	[cellInfo release];
	
	if (self.infoSectionArray)
		self.infoSectionArray = nil;
	self.infoSectionArray = tempArray;
	[tempArray release];
}

- (void) calcCommitteePartisanship {
	NSArray *positions = [self.committee.committeePositions allObjects];
	if (!positions && [positions count])
		return;
	
	CGFloat avg = 0.0f;
	CGFloat totalNum = 0.0f;
	NSInteger totalLege = 0;
	for (CommitteePositionObj *position in positions) {
		CGFloat legePart = position.legislator.latestWnomFloat;
		if (legePart != 0.0f) {
			totalNum += legePart;
			totalLege++;
		}
	}
	if (totalLege) {
		avg = totalNum / totalLege;
	}
	
	NSInteger democCount = 0, repubCount = 0;
	NSArray *repubs = [positions findAllWhereKeyPath:@"legislator.party_id" equals:[NSNumber numberWithInteger:REPUBLICAN]];	
	if (repubs)
		repubCount = [repubs count];
	democCount = [positions count] - repubCount;
	
	NSString *repubString = stringForParty(REPUBLICAN, TLReturnAbbrevPlural);
	NSString *democString = stringForParty(DEMOCRAT, TLReturnAbbrevPlural);
	if (repubCount == 1)
		repubString = stringForParty(REPUBLICAN, TLReturnAbbrev);
	if (democCount == 1)
		democString = stringForParty(DEMOCRAT, TLReturnAbbrev);
	
	
	self.membershipLab.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d %@ and %d %@", @"DataTableUI", @"As in, 43 Republicans and 1 Democrat"), 
							   repubCount, repubString, democCount, democString];
	
	if (!IsEmpty(positions)) {
		// This will give inacurate results in joint committees, at least until we're in a common dimensional space
		LegislatorObj *anyMember = [[positions objectAtIndex:0] legislator];
		
		if (anyMember) {
			PartisanIndexStats *indexStats = [PartisanIndexStats sharedPartisanIndexStats];
			
			CGFloat minSlider = [indexStats minPartisanIndexUsingChamber:[anyMember.legtype integerValue]];
			CGFloat maxSlider = [indexStats maxPartisanIndexUsingChamber:[anyMember.legtype integerValue]];
			
			self.partisanSlider.sliderMin = minSlider;
			self.partisanSlider.sliderMax = maxSlider;
		}
	}
	
	self.partisanSlider.sliderValue = avg;	
}

#pragma mark -
#pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {		
	
	NSInteger rows = 0;	
	switch (section) {
		case kChairSection:
			if ([self.committee chair] != nil)
				rows = 1;
			break;
		case kViceChairSection:
			if ([self.committee vicechair] != nil)
				rows = 1;
			break;
		case kMembersSection:
			rows = [[self.committee sortedMembers] count];
			break;
		case kInfoSection:
			rows = NUM_INFO_SECTION_ROWS;
			break;
		default:
			rows = 0;
			break;
	}
	
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];

	// We use the Leigislator Directory Cell identifier on purpose, since it's the same style as here..
	
	NSString *CellIdentifier;
	
	NSInteger InfoSectionEnd = ([UtilityMethods canMakePhoneCalls]) ? kInfoSectionClerk : kInfoSectionPhone;
	
	if (section > kInfoSection)
		CellIdentifier = @"CommitteeMember";
	else if (row > InfoSectionEnd)
		CellIdentifier = @"CommitteeInfo";
	else // the non-clickable / no disclosure items
		CellIdentifier = @"Committee-NoDisclosure";
	
	UITableViewCellStyle style = section > kInfoSection ? UITableViewCellStyleSubtitle : UITableViewCellStyleValue2;
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		
		if (CellIdentifier == @"CommitteeMember") {
			if (![UtilityMethods isIPadDevice]) {
				LegislatorMasterCell *newcell = [[[LegislatorMasterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
				newcell.frame = CGRectMake(0.0, 0.0, 234.0, quartzRowHeight);		
				newcell.cellView.useDarkBackground = NO;
				newcell.accessoryView.hidden = NO;
				cell = newcell;
			}
			else {
				CommitteeMemberCell *newcell = [[[CommitteeMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
				newcell.frame = CGRectMake(0.0, 0.0, kCommitteeMemberCellViewWidth, quartzRowHeight);		
				newcell.accessoryView.hidden = NO;
				cell = newcell;
			}
		}
		else {
			cell = (UITableViewCell *)[[[TexLegeStandardGroupCell alloc] initWithStyle:style reuseIdentifier:CellIdentifier] autorelease];			
		}

		cell.backgroundColor = [TexLegeTheme backgroundLight];
		
	}    
	
	LegislatorObj *legislator = nil;
	
	switch (section) {
		case kChairSection:
			legislator = [self.committee chair];
			break;
		case kViceChairSection:
			legislator = [self.committee vicechair];
			break;
		case kMembersSection: {
			NSArray * memberList = [self.committee sortedMembers];
			if ([memberList count] >= row)
				legislator = [memberList objectAtIndex:row];
		}
			break;
		case kInfoSection: {
			if (row < [self.infoSectionArray count]) {
				NSDictionary *cellInfo = [self.infoSectionArray objectAtIndex:row];
				if (cellInfo && [cell respondsToSelector:@selector(setCellInfo:)])
					[cell performSelector:@selector(setCellInfo:) withObject:cellInfo];
			}
		}
			break;
			
		default:
			cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			cell.hidden = YES;
			cell.frame  = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 0.01f, 0.01f);
			cell.tag = 999; //EMPTY
			[cell sizeToFit];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
			break;
	}
	
	if (legislator) {
		if ([cell respondsToSelector:@selector(setLegislator:)])
			[cell performSelector:@selector(setLegislator:) withObject:legislator];
		
	}	
	
	return cell;
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}



#pragma mark -
#pragma mark Table view delegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString * sectionName;
	
	switch (section) {
		case kChairSection: {
			if ([self.committee.committeeType integerValue] == JOINT)
				sectionName = NSLocalizedStringFromTable(@"Co-Chair", @"DataTableUI", @"For joint committees, House and Senate leaders are co-chair persons");
			else
				sectionName = NSLocalizedStringFromTable(@"Chair", @"DataTableUI", @"Cell title for a person who leads a given committee, an abbreviation for Chairperson");
		}
			break;
		case kViceChairSection: {
			if ([self.committee.committeeType integerValue] == JOINT)
				sectionName = NSLocalizedStringFromTable(@"Co-Chair", @"DataTableUI", @"For joint committees, House and Senate leaders are co-chair persons");
			else
				sectionName = NSLocalizedStringFromTable(@"Vice Chair", @"DataTableUI", @"Cell title for a person who is second in command of a given committee, behind the Chairperson");
		}
			break;
		case kMembersSection:
			sectionName = @"Members";
			break;
		case kInfoSection:
		default:
			if (self.committee.parentId.integerValue == -1) 
				sectionName = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ Committee Info",@"DataTableUI", @"Information for a given legislative committee"),
							   [self.committee typeString]];
			else
				sectionName = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ Subcommittee Info",@"DataTableUI", @"Information for a given legislative subcommittee"),
							   [self.committee typeString]];			
			break;
	}
	return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section > kInfoSection)
		return quartzRowHeight;
	
	return 44.0f;
}

- (void) pushMapViewWithMap:(CapitolMap *)capMap {
	CapitolMapsDetailViewController *detailController = [[CapitolMapsDetailViewController alloc] initWithNibName:@"CapitolMapsDetailViewController" bundle:nil];
	detailController.map = capMap;
	[[self navigationController] pushViewController:detailController animated:YES];
	[detailController release];
}

- (void) pushInternalBrowserWithURL:(NSURL *)url {
	if ([TexLegeReachability canReachHostWithURL:url]) { // do we have a good URL/connection?
		NSString *urlString = [url absoluteString];
		
		SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:urlString];
		webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
		[self presentModalViewController:webViewController animated:YES];	
		[webViewController release];
	}
}

// the user selected a row in the table.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	NSInteger row = [newIndexPath row];
	NSInteger section = [newIndexPath section];
		
	[tableView deselectRowAtIndexPath:newIndexPath animated:YES];	
	
	if (section == kInfoSection) {
		TableCellDataObject *cellInfo = [self.infoSectionArray objectAtIndex:row];
		if (!cellInfo || !cellInfo.isClickable)
			return;
		
		switch (row) {
			case kInfoSectionClerk:	
				[[TexLegeEmailComposer sharedTexLegeEmailComposer] presentMailComposerTo:cellInfo.entryValue 
																				 subject:@"" body:@"" commander:self];
				break;
			case kInfoSectionPhone:	{// dial the number
				if ([UtilityMethods canMakePhoneCalls]) {
					NSURL *myURL = cellInfo.entryValue;
					[UtilityMethods openURLWithoutTrepidation:myURL];
				}
			}
				break;
			case kInfoSectionOffice: {// open the office map
				CapitolMap *capMap = cellInfo.entryValue;
				[self pushMapViewWithMap:capMap];
			}
				break;
			case kInfoSectionWeb: {	 // open the web page
				NSURL *myURL = cellInfo.entryValue;
				[self pushInternalBrowserWithURL:myURL];
			}
				break;
			default:
				break;
		}
		
	}
	else {
		LegislatorDetailViewController *subDetailController = [[LegislatorDetailViewController alloc] initWithNibName:@"LegislatorDetailViewController" bundle:nil];
		
		switch (section) {
			case kChairSection:
				subDetailController.legislator = [self.committee chair];
				break;
			case kViceChairSection:
				subDetailController.legislator = [self.committee vicechair];
				break;
			case kMembersSection: { // Committee Members
				subDetailController.legislator = [[self.committee sortedMembers] objectAtIndex:row];
			}			
				break;
		}
		
		// push the detail view controller onto the navigation stack to display it
		[[self navigationController] pushViewController:subDetailController animated:YES];
		
		//	[self.navigationController setNavigationBarHidden:NO];
		[subDetailController release];
	}	
}


@end

