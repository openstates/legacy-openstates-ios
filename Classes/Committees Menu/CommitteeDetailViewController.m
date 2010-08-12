//
//  CommitteeDetailViewController.m
//  TexLege
//
//  Created by Gregory Combs on 6/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TableDataSourceProtocol.h"
#import "CommitteeDetailViewController.h"
#import "CommitteeObj.h"
#import "LegislatorObj.h"
#import "UtilityMethods.h"
#import "MapsDetailViewController.h"
#import "LegislatorDetailViewController.h"
#import "MiniBrowserController.h"
#import "LegislatorMasterTableViewCell.h"
#import "TexLegeAppDelegate.h"
#import "CommonPopoversController.h"

@implementation CommitteeDetailViewController

@synthesize committee;

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

- (void)setCommittee:(CommitteeObj *)newObj {
	//if (self.startupSplashView) {
	//	[self.startupSplashView removeFromSuperview];
	//}
	
	if (committee) [committee release], committee = nil;
	if (newObj) {
		committee = [newObj retain];
		self.navigationItem.title = self.committee.committeeName;

		if ([UtilityMethods isIPadDevice]) {
			[[CommonPopoversController sharedCommonPopoversController] dismissMasterListPopover:self.navigationItem.rightBarButtonItem];
		}
				
		[self.tableView reloadData];
		[self.view setNeedsDisplay];
	}

}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];

	if ([UtilityMethods isIPadDevice] == NO)
		return;
	
		// we don't have a legislator selected and yet we're appearing in portrait view ... got to have something here !!! 
	if (self.committee == nil && ![UtilityMethods isLandscapeOrientation])  {
		
		id masterVC = [appDelegate currentMasterViewController];
		
		if ([masterVC respondsToSelector:@selector(selectObjectOnAppear)])
			self.committee = [masterVC performSelector:@selector(selectObjectOnAppear)];
		
		if (!self.committee) {
			NSString *vcKey = [appDelegate currentMasterViewControllerKey];
			NSManagedObjectID *objectID = [appDelegate savedTableSelectionForKey:vcKey];
			if (objectID)
				self.committee = (CommitteeObj *)[[[masterVC valueForKey:@"dataSource"] managedObjectContext] objectWithID:objectID];
			
//			if (!self.committee && [masterVC respondsToSelector:@selector(selectDefaultObject:)])
//				[masterVC performSelector:@selector(selectDefaultObject:)];				
		}
	}
	
	[[CommonPopoversController sharedCommonPopoversController] resetPopoverMenus:self];
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
/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self showPopoverMenus:UIDeviceOrientationIsPortrait(toInterfaceOrientation)];
}
*/

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	//[self showPopoverMenus:UIDeviceOrientationIsPortrait(toInterfaceOrientation)];
	//[[TexLegeAppDelegate appDelegate] resetPopoverMenus];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Popover Support

- (NSString *)popoverButtonTitle {
	return @"Committees";	
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc 
	 willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem 
	   forPopoverController: (UIPopoverController*)pc {
	
//	[self showMasterListPopoverButtonItem:barButtonItem];
 //   self.popoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc 
	 willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	
//	[self invalidateMasterListPopoverButtonItem:barButtonItem];
//	self.popoverController = nil;
}

- (void) splitViewController:(UISplitViewController *)svc popoverController: (UIPopoverController *)pc
   willPresentViewController: (UIViewController *)aViewController
{
/*    if (pc != nil) {
        [[TexLegeAppDelegate appDelegate] dismissMasterListPopover:self.navigationItem.rightBarButtonItem];
		// do I need to set pc to nil?  I need to confirm, but I think it breaks things.
    }
*/
}

#pragma mark -
#pragma mark Table view data source

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
		CellIdentifier = @"CommitteeLegislators";
	else if (row > InfoSectionEnd)
		CellIdentifier = @"CommitteeInfo";
	else // the non-clickable / no disclosure items
		CellIdentifier = @"Committee-NoDisclosure";
	
	UITableViewCellStyle style = section > kInfoSection ? UITableViewCellStyleSubtitle : UITableViewCellStyleValue2;
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		if (CellIdentifier == @"CommitteeLegislators") {
			NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"LegislatorMasterTableViewCell" owner:self options:nil];
			for (id suspect in objects) {
				if ([suspect isKindOfClass:[LegislatorMasterTableViewCell class]]) {
					cell = (UITableViewCell *)suspect;
					break;
				}
			}
		}
		else {
			cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:CellIdentifier] autorelease];			
		}
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
			switch (row) {
				case kInfoSectionName:
					cell.textLabel.text = @"Committee";
					cell.detailTextLabel.text = self.committee.committeeName;
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					break;
				case kInfoSectionClerk:	// do email, someday
					cell.textLabel.text = @"Clerk";
					cell.detailTextLabel.text = self.committee.clerk;
					cell.selectionStyle = UITableViewCellSelectionStyleNone; // for now, later do email...
					break;
				case kInfoSectionPhone:	// dial the number
					cell.textLabel.text = @"Phone";
					cell.detailTextLabel.text = self.committee.phone;
					if ([UtilityMethods canMakePhoneCalls])
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					else
						cell.selectionStyle = UITableViewCellSelectionStyleNone;
					break;
				case kInfoSectionOffice: // open the office map
					cell.textLabel.text = @"Location";
					cell.detailTextLabel.text = self.committee.office;
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				case kInfoSectionWeb:	 // open the web page
					cell.textLabel.text = @"Web";
					cell.detailTextLabel.text = @"Website & Meetings";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				default:
					break;
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
		[(LegislatorMasterTableViewCell *)cell setupWithLegislator:legislator];
		/*
		// configure cell contents for a legislator
		cell.textLabel.text = [NSString stringWithFormat: @"%@ - (%@)", 
							   [legislator legProperName], [legislator partyShortName]];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
		cell.detailTextLabel.text = [legislator labelSubText];
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12];
		cell.detailTextLabel.textColor = [UIColor lightGrayColor];
		
		cell.imageView.image = [UtilityMethods poorMansImageNamed:legislator.photo_name];
		
		// all the rows should show the disclosure indicator
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		 */
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
		return 73.0f;

	return 44.0f;

}

- (void) pushMapViewWithMap:(CapitolMap *)capMap {
	MapsDetailViewController *detailController = [[MapsDetailViewController alloc] initWithNibName:@"MapsDetailViewController" bundle:nil];
	detailController.map = capMap;
	//detailController.navigationItem.title = @"Maps";
	// push the detail view controller onto the navigation stack to display it
	[[self navigationController] pushViewController:detailController animated:YES];
	[detailController release];
}

- (void) pushInternalBrowserWithURL:(NSURL *)url {
	if ([UtilityMethods canReachHostWithURL:url]) { // do we have a good URL/connection?
		MiniBrowserController *mbc = [MiniBrowserController sharedBrowserWithURL:url];
		[mbc display:self];
	}
}

// the user selected a row in the table.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	NSInteger row = [newIndexPath row];
	NSInteger section = [newIndexPath section];
		
	[tableView deselectRowAtIndexPath:newIndexPath animated:YES];	
	
	if (section == kInfoSection) {
		switch (row) {
			case kInfoSectionClerk:	// do email, someday
				break;
			case kInfoSectionPhone:	{// dial the number
				if ([UtilityMethods canMakePhoneCalls]) {
					NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.committee.phone]];
					// Switch to the appropriate application for this url...
					[UtilityMethods openURLWithoutTrepidation:myURL];
				}
				
			}
				break;
			case kInfoSectionOffice: // open the office map
				[self pushMapViewWithMap:[UtilityMethods capitolMapFromOfficeString:self.committee.office]];
				break;
			case kInfoSectionWeb:	 // open the web page
				[self pushInternalBrowserWithURL:[UtilityMethods safeWebUrlFromString:self.committee.url]];
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


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	[[self navigationController] popToRootViewControllerAnimated:YES];

	self.committee = nil;
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	self.committee = nil;

}


- (void)dealloc {
    [super dealloc];
}


@end

