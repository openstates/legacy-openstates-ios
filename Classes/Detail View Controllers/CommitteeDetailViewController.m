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

#import "CommitteeObj.h"
#import "CommitteePositionObj.h"
#import "LegislatorObj.h"
#import "UtilityMethods.h"
#import "CapitolMapsDetailViewController.h"
#import "LegislatorDetailViewController.h"
#import "MiniBrowserController.h"
#import "TexLegeAppDelegate.h"
#import "TexLegeTheme.h"
#import "LegislatorMasterCell.h"
#import "CommitteeMemberCell.h"
#import "CommitteeMemberCellView.h"
#import "TexLegeStandardGroupCell.h"
#import "PartisanScaleView.h"
#import "PartisanIndexStats.h"

@interface CommitteeDetailViewController (Private)

- (void) buildInfoSectionArray;

@end

@implementation CommitteeDetailViewController

@synthesize committee, masterPopover;
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

- (void) calcCommitteePartisanship {
	NSArray *positions = [self.committee.committeePositions allObjects];
	if (!positions && [positions count])
		return;
	
	CGFloat avg = 0.0f;
	NSNumber *avgNum = [positions valueForKeyPath:@"@avg.legislator.partisan_index"];
	if (avgNum)
		avg = [avgNum floatValue];
	
	NSInteger democCount = 0, repubCount = 0;
	NSArray *repubs = [positions findAllWhereKeyPath:@"legislator.party_id" equals:[NSNumber numberWithInteger:REPUBLICAN]];	
	if (repubs)
		repubCount = [repubs count];
	democCount = [positions count] - repubCount;
	
	NSString *repubString = @"Republicans";
	if (repubCount == 1)
		repubString = @"Republican";
	
	NSString *democString = @"Democrats";
	if (democCount == 1)
		democString = @"Democrat";
	
	self.membershipLab.text = [NSString stringWithFormat:@"%d %@ and %d %@", repubCount, repubString, democCount, democString];
		


	LegislatorObj *anyMember = [[positions objectAtIndex:0] legislator];

	if (anyMember) {
		PartisanIndexStats *indexStats = [PartisanIndexStats sharedPartisanIndexStats];
		
		CGFloat minSlider = [[indexStats minPartisanIndexUsingLegislator:anyMember] floatValue];
		CGFloat maxSlider = [[indexStats maxPartisanIndexUsingLegislator:anyMember] floatValue];
		
		self.partisanSlider.sliderMin = minSlider;
		self.partisanSlider.sliderMax = maxSlider;
	}

	self.partisanSlider.sliderValue = avg;	
}

- (void)setCommittee:(CommitteeObj *)newObj {
	[self view];
	
	if (committee) [committee release], committee = nil;
	if (newObj) {
		if (self.masterPopover)
			[self.masterPopover dismissPopoverAnimated:YES];

		committee = [newObj retain];
		
		[self buildInfoSectionArray];
		self.navigationItem.title = self.committee.committeeName;
		
		[self calcCommitteePartisanship];
		
		[self.tableView reloadData];
		[self.view setNeedsDisplay];
	}

}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	self.clearsSelectionOnViewWillAppear = NO;

	UIImage *sealImage = [UIImage imageNamed:@"seal.png"];
	UIColor *sealColor = [[UIColor colorWithPatternImage:sealImage] colorWithAlphaComponent:0.5f];	
	self.tableView.tableHeaderView.backgroundColor = sealColor;	
	
	//if ([UtilityMethods isIPadDevice])
	//	quartzRowHeight = 73.f*1.5f;
}


- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];

	if ([UtilityMethods isIPadDevice] == NO)
		return;
	
		// we don't have a legislator selected and yet we're appearing in portrait view ... got to have something here !!! 
	if (self.committee == nil && ![UtilityMethods isLandscapeOrientation])  {
		
		self.committee = [[appDelegate committeeMasterVC] selectObjectOnAppear];		

	}
}

/*
 - (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	[[self navigationController] popToRootViewControllerAnimated:YES];
	
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	self.partisanSlider = nil;
	self.membershipLab = nil;
	self.committee = nil;
	self.masterPopover = nil;
	self.tableView = nil;
	self.infoSectionArray = nil;
	[super viewDidUnload];
}


- (void)dealloc {
	self.committee = nil;
	self.tableView = nil;
	self.masterPopover = nil;
	self.infoSectionArray = nil;
    [super dealloc];
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
#pragma mark Popover Support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = @"Committees";
    [self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
    self.masterPopover = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    self.masterPopover = nil;
}

- (void) splitViewController:(UISplitViewController *)svc popoverController: (UIPopoverController *)pc
   willPresentViewController: (UIViewController *)aViewController
{
}	

#pragma mark -
#pragma mark Table view data source

- (void)buildInfoSectionArray {	
	NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:12]; // arbitrary
	NSDictionary *infoDict = nil;
	DirectoryDetailInfo *cellInfo = nil;
//case kInfoSectionName:
	infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
				@"Committee", @"subtitle",
				self.committee.committeeName, @"title",
				[NSNumber numberWithBool:NO], @"isClickable",
				nil, @"entryValue",
				nil];
	cellInfo = [[DirectoryDetailInfo alloc] initWithDictionary:infoDict];
	[tempArray addObject:cellInfo];
	[infoDict release];
	[cellInfo release];

//case kInfoSectionClerk:	// do email, someday
	infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
				@"Clerk", @"subtitle",
				self.committee.clerk, @"title",
				[NSNumber numberWithBool:NO], @"isClickable",
				nil, @"entryValue",
				nil];
	cellInfo = [[DirectoryDetailInfo alloc] initWithDictionary:infoDict];
	[tempArray addObject:cellInfo];
	[infoDict release];
	[cellInfo release];
	
//case kInfoSectionPhone:	// dial the number
	infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
				@"Phone", @"subtitle",
				self.committee.phone, @"title",
				[NSNumber numberWithBool:[UtilityMethods canMakePhoneCalls]], @"isClickable",
				[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.committee.phone]], @"entryValue",
				nil];
	cellInfo = [[DirectoryDetailInfo alloc] initWithDictionary:infoDict];
	[tempArray addObject:cellInfo];
	[infoDict release];
	[cellInfo release];
	
	//case kInfoSectionOffice: // open the office map
	infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
				@"Location", @"subtitle",
				self.committee.office, @"title",
				[NSNumber numberWithBool:YES], @"isClickable",
				[UtilityMethods capitolMapFromOfficeString:self.committee.office], @"entryValue",
				nil];
	cellInfo = [[DirectoryDetailInfo alloc] initWithDictionary:infoDict];
	[tempArray addObject:cellInfo];
	[infoDict release];
	[cellInfo release];
	
//case kInfoSectionWeb:	 // open the web page
	infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
				@"Web", @"subtitle",
				@"Website & Meetings", @"title",
				[NSNumber numberWithBool:YES], @"isClickable",
				[UtilityMethods safeWebUrlFromString:self.committee.url], @"entryValue",
				nil];
	cellInfo = [[DirectoryDetailInfo alloc] initWithDictionary:infoDict];
	[tempArray addObject:cellInfo];
	[infoDict release];
	[cellInfo release];
	
	if (self.infoSectionArray)
		self.infoSectionArray = nil;
	self.infoSectionArray = tempArray;
	[tempArray release];

}

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
				//cell.frame = CGRectMake(0.0, 0.0, 320.0, 73.0);
				newcell.frame = CGRectMake(0.0, 0.0, 234.0, quartzRowHeight);		
				newcell.cellView.useDarkBackground = NO;
				newcell.accessoryView.hidden = NO;
				cell = newcell;
			}
			else {
				CommitteeMemberCell *newcell = [[[CommitteeMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
				//cell.frame = CGRectMake(0.0, 0.0, 320.0, 73.0);
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
			NSDictionary *cellInfo = [self.infoSectionArray objectAtIndex:row];
			if (cellInfo && [cell respondsToSelector:@selector(setCellInfo:)])
				[cell performSelector:@selector(setCellInfo:) withObject:cellInfo];
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
		case kChairSection:
			sectionName = @"Chair";
			break;
		case kViceChairSection:
			sectionName = @"Vice Chair";
			break;
		case kMembersSection:
			sectionName = @"Members";
			break;
		case kInfoSection:
		default:
			if (self.committee.parentId.integerValue == -1) 
				sectionName = [NSString stringWithFormat:@"%@ Committee Info",[self.committee typeString]];
			else
				sectionName = [NSString stringWithFormat:@"%@ Subcommittee Info",[self.committee typeString]];			
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
	if ([UtilityMethods canReachHostWithURL:url]) { // do we have a good URL/connection?
		MiniBrowserController *mbc = [MiniBrowserController sharedBrowserWithURL:url];
		[mbc display:self.tabBarController];
	}
}

// the user selected a row in the table.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	NSInteger row = [newIndexPath row];
	NSInteger section = [newIndexPath section];
		
	[tableView deselectRowAtIndexPath:newIndexPath animated:YES];	
	
	if (section == kInfoSection) {
		DirectoryDetailInfo *cellInfo = [self.infoSectionArray objectAtIndex:row];
		if (!cellInfo)
			return;
		
		switch (row) {
			case kInfoSectionClerk:	// do email, someday
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

