//
//  CommitteeDetailView.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "UtilityMethods.h"

#import "CommitteeDetailView.h"
#import "TexLegeAppDelegate.h"
#import "DetailTableViewController.h"

@implementation CommitteeDetailView

@synthesize committee;
@synthesize sectionArray;
@synthesize detailController;

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


- (id)initWithFrameAndCommittee:(CGRect)frame Committee:(CommitteeObj *)aCommittee {
	// allow superclass to initialize its state first
    if (self = [super initWithFrame:frame style:UITableViewStyleGrouped]) {
		
		// Initialization code here.
		if (aCommittee == nil) { // This should never happen....
			debug_NSLog(@"CommitteeDetailView: Failed to find an instantiated committee.");
		}
		else {
			self.committee = aCommittee;
		}
		
		self.backgroundColor = [UIColor groupTableViewBackgroundColor];
		self.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
		self.autoresizesSubviews = YES;
		
		self.dataSource = self;
				
    }
    return self;
}

- (void)dealloc {
	
	[sectionArray release];
	//committee = nil;
	
    [super dealloc];
}


- (NSString *)name {
	return self.committee.committeeName;
}


#pragma mark -
#pragma mark Orientation

// Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { 
	return YES;
}

- (void)configureCell:(UITableViewCell *)cell forLegislator:(LegislatorObj *)legislator {
	if (legislator != nil) {
		// configure cell contents
		cell.textLabel.text = [NSString stringWithFormat: @"%@ - (%@)", 
							   [legislator legProperName], [legislator partyShortName]];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
		cell.detailTextLabel.text = [legislator labelSubText];
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12];
		cell.detailTextLabel.textColor = [UIColor lightGrayColor];
		
		cell.imageView.image = [legislator smallLegislatorImage];

		// all the rows should show the disclosure indicator
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	}	
}



#pragma mark -
#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];

	// We use the Leigislator Directory Cell identifier on purpose, since it's the same style as here..
		
	NSString *CellIdentifier;
	
	NSInteger InfoSectionEnd = ([UtilityMethods canMakePhoneCalls]) ? kInfoSectionClerk : kInfoSectionPhone;
	
	if (section > kInfoSection)
		CellIdentifier = @"LegislatorDirectory";
	else if (row > InfoSectionEnd)
		CellIdentifier = @"CommitteeInfo";
	else // the non-clickable / no disclosure items
		CellIdentifier = @"Committee-NoDisclosure";
	
	UITableViewCellStyle style = section > kInfoSection ? UITableViewCellStyleSubtitle : UITableViewCellStyleValue2;

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:CellIdentifier] autorelease];
	}    
		
	LegislatorObj *legislator;
	
	switch (section) {
		case kChairSection:
			legislator = [self.committee chair];
			[self configureCell:cell forLegislator:legislator];
			break;
		case kViceChairSection:
			legislator = [self.committee vicechair];
			[self configureCell:cell forLegislator:legislator];
			break;
		case kMembersSection: {
			NSArray * memberList = [self.committee members];
			if ([memberList count] > 0)
				legislator = [memberList objectAtIndex:row];
			[self configureCell:cell forLegislator:legislator];
		}
			break;
		case kInfoSection: {
			switch (row) {
				case kInfoSectionName:
					cell.textLabel.text = @"Committee";
					cell.detailTextLabel.text = [self name];
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
	
	
	
	return cell;
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
			rows = [[self.committee members] count];
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
			if (self.committee.parentId.intValue == -1) 
				sectionName = [NSString stringWithFormat:@"%@ Committee Info",[self.committee typeString]];
			else
				sectionName = [NSString stringWithFormat:@"%@ Subcommittee Info",[self.committee typeString]];			
			break;
	}
	return sectionName;
}


// the user selected a row in the table.
- (void)didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	int row = [newIndexPath row];
	int section = [newIndexPath section];
	
	// deselect the new row using animation
	[self deselectRowAtIndexPath:newIndexPath animated:YES];	
	
	if (section == kInfoSection) {
		switch (row) {
			case kInfoSectionClerk:	// do email, someday
				break;
			case kInfoSectionPhone:	{// dial the number
				if ([UtilityMethods canMakePhoneCalls]) {
					NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.committee.phone]];
#if 0
					if (![UtilityMethods canMakePhoneCalls]) {
						debug_NSLog(@"Tried to make a phonecall, but this isn't a phone: %@", myURL.description);
						[UtilityMethods alertNotAPhone];
						return;
					}
#endif
					// Switch to the appropriate application for this url...
					[UtilityMethods openURLWithoutTrepidation:myURL];
				}

			}
				break;
			case kInfoSectionOffice: // open the office map
				[self.detailController pushMapViewWithURL:[UtilityMethods pdfMapUrlFromOfficeString:self.committee.office]];
				break;
			case kInfoSectionWeb:	 // open the web page
				[self.detailController showWebViewWithURL:[UtilityMethods safeWebUrlFromString:self.committee.url]];
				break;
			default:
				break;
		}
		
	}
	else {
		DetailTableViewController *subDetailController = [[DetailTableViewController alloc] init];

		switch (section) {
			case kChairSection:
				subDetailController.legislator = [self.committee chair];
				break;
			case kViceChairSection:
				subDetailController.legislator = [self.committee vicechair];
				break;
			case kMembersSection: { // Committee Members
				LegislatorObj *tempLeg = [[self.committee members] objectAtIndex:row];
				subDetailController.legislator = tempLeg;
			}			
				break;
		}
		
		// push the detail view controller onto the navigation stack to display it
		[[self.detailController navigationController] pushViewController:subDetailController animated:YES];
		
		//	[self.navigationController setNavigationBarHidden:NO];
		[subDetailController release];
	}
	
}


@end
