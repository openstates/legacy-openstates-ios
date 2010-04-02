//
//  DirectoryDetailView.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "UtilityMethods.h"

#import "DirectoryDetailView.h"
#import "TexLegeAppDelegate.h"
#import "DetailTableViewController.h"
#import "CommitteeObj.h"
#import "CommitteePositionObj.h"
#import "NotesViewController.h"

@implementation DirectoryDetailView

@synthesize legislator;
@synthesize sectionArray;
@synthesize detailController;



- (id)initWithFrameAndLegislator:(CGRect)frame Legislator:(LegislatorObj *)aLegislator {
	// allow superclass to initialize its state first
    if (self = [super initWithFrame:frame style:UITableViewStyleGrouped]) {
		
		// Initialization code here.
		if (aLegislator == nil) { // This should never happen....
			debug_NSLog(@"DirectoryDetailView: Failed to find an instantiated legislator.");
		}
		else {
			self.legislator = aLegislator;
		}
				
		self.backgroundColor = [UIColor groupTableViewBackgroundColor];
		self.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
		self.autoresizesSubviews = YES;
		
		self.dataSource = self;
		
		[self loadView];

    }
    return self;
}

- (void)dealloc {
	
	
	[sectionArray release];
	//legislator = nil;
	//[self.legislator release]; // we didn't allocate it...
	
	if (customSlider != nil)
		[customSlider release];

	
    [super dealloc];
}


- (NSString *)name {
	return [NSString stringWithFormat:@"%@ %@",
			[self.legislator legProperName], [self.legislator districtPartyString]];
}

- (void)setupHeader:(UIView*)aHeader {
	
	// One day, might get this frame from an initialized/loaded UIImage
	//		CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);	
	UIImageView *photoView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 18.0f, 64.0f, 85.0f)];
	photoView.autoresizingMask = UIViewAutoresizingNone;
	
	if (self.legislator.photo_name != nil)
		photoView.image = [UIImage imageNamed:self.legislator.photo_name];
	else 
		photoView.image = [UIImage imageNamed:@"unknown.png"];	
	[aHeader addSubview:photoView];	
	
	CGFloat marginY = 3.0f;
	CGFloat currentY = photoView.frame.origin.y - marginY;
	CGFloat length = aHeader.bounds.size.width - photoView.frame.size.width - (2*photoView.frame.origin.x) ;
	CGFloat height = 21.0f;
	CGFloat insetX = 10.0f;  // inset everything after the name?
	
	[photoView release];
	
	UILabel *theLabel = [[UILabel alloc] initWithFrame:CGRectMake(96.0f, currentY, length, height)];
	
	theLabel.text = [NSString stringWithFormat:@"%@ %@",  [self.legislator legTypeShortName], 
					 [self.legislator legProperName]];
	theLabel.textColor = [UIColor blackColor];
	//theLabel.textAlignment = UITextAlignmentRight;
	theLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	theLabel.backgroundColor = [UIColor clearColor];
	[aHeader addSubview:theLabel];
	[theLabel release];
	
	currentY = currentY + height + marginY;
	
	theLabel = [[UILabel alloc] initWithFrame:CGRectMake(96.0f+insetX, currentY, length-insetX, height)];
	theLabel.text = [NSString stringWithFormat:@"District %d",  self.legislator.district.intValue];
	theLabel.font = [UIFont boldSystemFontOfSize:14];
	theLabel.textColor = [UIColor darkGrayColor];
	//theLabel.textAlignment = UITextAlignmentRight;
	theLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	theLabel.backgroundColor = [UIColor clearColor];
	[aHeader addSubview:theLabel];
	[theLabel release];
	
	currentY = currentY + height + marginY;
	
	theLabel = [[UILabel alloc] initWithFrame:CGRectMake(96.0f+insetX, currentY, length-insetX, height)];
	theLabel.text = [NSString stringWithString:self.legislator.party_name];
	theLabel.font = [UIFont boldSystemFontOfSize:14];
	theLabel.textColor = [UIColor darkGrayColor];
	//theLabel.textAlignment = UITextAlignmentRight;
	theLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	theLabel.backgroundColor = [UIColor clearColor];
	[aHeader addSubview:theLabel];
	[theLabel release];
	
	if (self.legislator.tenure.intValue > -1) {
		currentY = currentY + height + marginY;

		theLabel = [[UILabel alloc] initWithFrame:CGRectMake(96.0f+insetX, currentY, length-insetX, height)];
		if (self.legislator.tenure.intValue == 1) {
			theLabel.text = [NSString stringWithFormat:@"%d Year",  self.legislator.tenure.intValue];
		}
		else if (self.legislator.tenure.intValue == 0) {
			theLabel.text = [NSString stringWithString:@"Freshman Legislator"];
		}
		else {
			theLabel.text = [NSString stringWithFormat:@"%d Years",  self.legislator.tenure.intValue];
		}
		theLabel.font = [UIFont boldSystemFontOfSize:14];
		theLabel.textColor = [UIColor darkGrayColor];
		//theLabel.textAlignment = UITextAlignmentRight;
		theLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		theLabel.backgroundColor = [UIColor clearColor];
		[aHeader addSubview:theLabel];
		[theLabel release];
		
	}
}


#pragma mark -
#pragma mark Orientation

// Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { 
	return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	/*	
	 // adjust individual subviews as necessary
	 BOOL wasSideways = (UIInterfaceOrientationLandscapeLeft == fromInterfaceOrientation || 
	 UIInterfaceOrientationLandscapeRight == fromInterfaceOrientation);
	 CGRect searchBarRect = self.searchBar.bounds;
	 searchBarRect.size.height = wasSideways ? 44 : 32;
	 self.searchBar.bounds = searchBarRect;
	 
	 */
}

/* Some stuff that we might have to repeat... */
- (void)loadView {	
	UIView *tempHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 
														   self.frame.size.width, 105.0f)];
	tempHeader.backgroundColor=[UIColor clearColor];
	tempHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	[self setupHeader:tempHeader];
	self.tableHeaderView = tempHeader;	
	
	[tempHeader release];
	
	[self createSectionList];
}

- (void) createSectionList {
	NSInteger numberOfSections = 3 + [self.legislator numberOfDistrictOffices];
	
	NSArray *keys = nil;
	NSArray *objects = nil;
	NSString *tempString = nil;
	NSNumber *boolYES = [NSNumber numberWithBool:YES];
	NSNumber *boolNO = [NSNumber numberWithBool:NO];
	NSNumber *boolIsPhone = [NSNumber numberWithBool:[UtilityMethods canMakePhoneCalls]];

	
	sectionArray = [[[NSMutableArray alloc] initWithCapacity:numberOfSections] retain];
	//for (int i = 0; i < numberOfSections; i++) [sectionArray addObject:[[[NSMutableArray alloc] init] retain]];

	// this holds each section, in another MutableArray
	// then that array holds each entry in the section, wich is made up of ...
	// an NSObject, created from the contents of a temporary dictionary....

	keys = [NSArray arrayWithObjects:		@"entryName", @"entryValue", @"isClickable", @"entryType", nil];

	/*	Section 0: Personal Information */		
	NSInteger sectionIndex = 0;
	[sectionArray addObject:[[[NSMutableArray alloc] init] retain]];

	objects = [NSArray arrayWithObjects:	@"Name", [self.legislator fullName], 
			boolNO, [NSNumber numberWithInt:DirectoryTypeNone], nil];
	[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
	
	objects = [NSArray arrayWithObjects:	@"Website", self.legislator.website, 
			boolYES, [NSNumber numberWithInt:DirectoryTypeWeb], nil];
	[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
	
	objects = [NSArray arrayWithObjects:	@"Bio", self.legislator.bio_url, 
			   boolYES, [NSNumber numberWithInt:DirectoryTypeWeb], nil];
	[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];

	objects = [NSArray arrayWithObjects:	@"Email", self.legislator.email, 
			   boolYES, [NSNumber numberWithInt:DirectoryTypeMail], nil];
	[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
	
	if (self.legislator.twitter.length > 0) {
		objects = [NSArray arrayWithObjects:	@"Twitter", [NSString stringWithFormat:@"@%@", self.legislator.twitter], 
				   boolYES, [NSNumber numberWithInt:DirectoryTypeTwitter], nil];
		[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
	}
	if (self.legislator.partisan_index.floatValue != 0.0f) {
		objects = [NSArray arrayWithObjects:	@"Index",  self.legislator.partisan_index.stringValue,
				   boolNO, [NSNumber numberWithInt:DirectoryTypeIndex], nil];
		[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
		
		objects = [NSArray arrayWithObjects:	@"",  @"About the Roll Call Index", 
				  boolYES, [NSNumber numberWithInt:DirectoryTypeIndexAbout], nil];
		[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
	}
	if (self.legislator.notes.length > 0) {
		tempString = self.legislator.notes;
	}
	else
		tempString = kStaticNotes;

	objects = [NSArray arrayWithObjects:	@"Notes",  tempString, 
			   boolYES, [NSNumber numberWithInt:DirectoryTypeNotes], nil];
	[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
	
	
	
	/* after that section's done... DO COMMITTEES */
	sectionIndex++;
	[sectionArray addObject:[[[NSMutableArray alloc] init] retain]];
		
	for (CommitteePositionObj *position in [self.legislator committees]) {
		objects = [NSArray arrayWithObjects:[position positionString],  [position.committee committeeName], 
				   boolYES, [NSNumber numberWithInt:DirectoryTypeCommittee], nil];
		[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
	}
	
	/* after that section's done... */
	sectionIndex++;
	[sectionArray addObject:[[[NSMutableArray alloc] init] retain]];

	/*	Section 1: Capitol Office */		

	if (legislator.staff.length > 0) {
		objects = [NSArray arrayWithObjects:	@"Staff", self.legislator.staff, 
				   boolNO, [NSNumber numberWithInt:DirectoryTypeNone], nil];
		[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
	}
	if (self.legislator.cap_office.length > 0) {
		objects = [NSArray arrayWithObjects:	@"Office",  self.legislator.cap_office, 
				   boolYES, [NSNumber numberWithInt:DirectoryTypeOfficeMap], nil];
		[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
	} 
	if (legislator.chamber_desk.length > 0) {
		objects = [NSArray arrayWithObjects:	@"Desk #",  self.legislator.chamber_desk, 
				   boolYES, [NSNumber numberWithInt:DirectoryTypeChamberMap], nil];
		[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
	}
	if (legislator.cap_phone.length > 0) {
		objects = [NSArray arrayWithObjects:	@"Phone",  self.legislator.cap_phone, 
				   boolIsPhone, [NSNumber numberWithInt:DirectoryTypePhone], nil];
		[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
	} 
	if (legislator.cap_fax.length > 0) {
		objects = [NSArray arrayWithObjects:	@"Fax",  self.legislator.cap_fax, 
				   boolNO, [NSNumber numberWithInt:DirectoryTypeNone], nil];
		[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
	}
	if (legislator.cap_phone2.length > 0) {
		tempString = (self.legislator.cap_phone2_name.length > 0) ? self.legislator.cap_phone2_name : @"Phone #2";
		
		objects = [NSArray arrayWithObjects:	tempString,  self.legislator.cap_phone2, 
				   boolIsPhone, [NSNumber numberWithInt:DirectoryTypePhone], nil];
		[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
	} 
	
	/* after that section's done... */

	if ([legislator numberOfDistrictOffices] >= 1) {
		sectionIndex++;
		[sectionArray addObject:[[[NSMutableArray alloc] init] retain]];

		/*	Section 2: District 1 */		
		
		if (legislator.dist1_phone.length > 0) {
			objects = [NSArray arrayWithObjects:	@"Phone",  self.legislator.dist1_phone, 
					   boolIsPhone, [NSNumber numberWithInt:DirectoryTypePhone], nil];
			[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
		} 
		if (legislator.dist1_fax.length > 0) {
			objects = [NSArray arrayWithObjects:	@"Fax",  self.legislator.dist1_fax, 
					   boolNO, [NSNumber numberWithInt:DirectoryTypeNone], nil];
			[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
		}
		if (legislator.dist1_street.length > 0) {
			tempString = [self.legislator.dist1_street stringByReplacingOccurrencesOfString:@", " withString:@"\n"];
			tempString = [NSString stringWithFormat:@"%@\n%@, TX\n%@", 
								   tempString, self.legislator.dist1_city, self.legislator.dist1_zip];

			objects = [NSArray arrayWithObjects:	@"Address", tempString, 
					   boolYES, [NSNumber numberWithInt:DirectoryTypeMap], nil];
			[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
		} 
	}

	/* after that section's done... */

	if ([legislator numberOfDistrictOffices] >= 2) {
		sectionIndex++;
		[sectionArray addObject:[[[NSMutableArray alloc] init] retain]];
		/*	Section 3: District 2 */		

		if (legislator.dist2_phone.length > 0) {
			objects = [NSArray arrayWithObjects:	@"Phone",  self.legislator.dist2_phone, 
					   boolIsPhone, [NSNumber numberWithInt:DirectoryTypePhone], nil];
			[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
		} 
		if (legislator.dist2_fax.length > 0) {
			objects = [NSArray arrayWithObjects:	@"Fax",  self.legislator.dist2_fax, 
					   boolNO, [NSNumber numberWithInt:DirectoryTypeNone], nil];
			[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
		}
		if (legislator.dist2_street.length > 0) {
			tempString = [self.legislator.dist2_street stringByReplacingOccurrencesOfString:@", " withString:@"\n"];
			tempString = [NSString stringWithFormat:@"%@\n%@, TX\n%@", 
						  tempString, self.legislator.dist2_city, self.legislator.dist2_zip];
			
			objects = [NSArray arrayWithObjects:	@"Address", tempString, 
					   boolYES, [NSNumber numberWithInt:DirectoryTypeMap], nil];
			[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
		} 
	}
	
	/* after that section's done... */
	
	if ([legislator numberOfDistrictOffices] >= 3) {
		sectionIndex++;
		[sectionArray addObject:[[[NSMutableArray alloc] init] retain]];
		/*	Section 4: District 3 */		
		
		if (legislator.dist3_phone1.length > 0) {
			objects = [NSArray arrayWithObjects:	@"Phone",  self.legislator.dist3_phone1, 
					   boolIsPhone, [NSNumber numberWithInt:DirectoryTypePhone], nil];
			[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
		} 
		if (legislator.dist3_fax.length > 0) {
			objects = [NSArray arrayWithObjects:	@"Fax",  self.legislator.dist3_fax, 
					   boolNO, [NSNumber numberWithInt:DirectoryTypeNone], nil];
			[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
		}
		if (legislator.dist3_street.length > 0) {
			tempString = [self.legislator.dist3_street stringByReplacingOccurrencesOfString:@", " withString:@"\n"];
			tempString = [NSString stringWithFormat:@"%@\n%@, TX\n%@", 
						  tempString, self.legislator.dist3_city, self.legislator.dist3_zip];
			
			objects = [NSArray arrayWithObjects:	@"Address", tempString, 
					   boolYES, [NSNumber numberWithInt:DirectoryTypeMap], nil];
			[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
		} 
	}

	/* after that section's done... */
	
	if ([legislator numberOfDistrictOffices] >= 4) {
		sectionIndex++;
		[sectionArray addObject:[[[NSMutableArray alloc] init] retain]];
		/*	Section 5: District 4 */		
		
		if (legislator.dist4_phone1.length > 0) {
			objects = [NSArray arrayWithObjects:	@"Phone",  self.legislator.dist4_phone1, 
					   boolIsPhone, [NSNumber numberWithInt:DirectoryTypePhone], nil];
			[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
		} 
		if (legislator.dist4_fax.length > 0) {
			objects = [NSArray arrayWithObjects:	@"Fax",  self.legislator.dist4_fax, 
					   boolNO, [NSNumber numberWithInt:DirectoryTypeNone], nil];
			[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
		}
		if (legislator.dist4_street.length > 0) {
			tempString = [self.legislator.dist4_street stringByReplacingOccurrencesOfString:@", " withString:@"\n"];
			tempString = [NSString stringWithFormat:@"%@\n%@, TX\n%@", 
						  tempString, self.legislator.dist4_city, self.legislator.dist4_zip];
			
			objects = [NSArray arrayWithObjects:	@"Address", tempString, 
					   boolYES, [NSNumber numberWithInt:DirectoryTypeMap], nil];
			[self createEntryInSection:sectionIndex WithKeys:keys andObjects:objects];
		} 
	}
	
}	
		
- (void) createEntryInSection:(NSInteger)sectionIndex WithKeys:(NSArray *)keys andObjects:(NSArray *)objects {
	NSMutableDictionary *aDictionary = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
	
	DirectoryDetailInfo *cellInfo = [[DirectoryDetailInfo alloc] initWithDictionary:aDictionary];
	[[sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
	// guess we don't need to release the dictionary...
	[cellInfo release];
}

- (void) standardTextCell:(UITableViewCell *)cell withInfo:(DirectoryDetailInfo *)cellInfo {
	if (cellInfo.entryValue.length > 0)	cell.detailTextLabel.text = cellInfo.entryValue;
	if (cellInfo.entryName.length > 0)	cell.textLabel.text = cellInfo.entryName;
}

#pragma mark -
#pragma mark UITableViewDataSource methods


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{		
	//DirectoryDetailInfo * cellInfo = [[DirectoryDetailInfo alloc] init];
	//[self infoForRow:cellInfo atIndexPath:indexPath];
	
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	
	DirectoryDetailInfo *cellInfo = [[sectionArray objectAtIndex:section] objectAtIndex:row];
	
	BOOL clickable = clickable = cellInfo.isClickable;
	//NSString *CellIdentifier = [NSString stringWithFormat:@"Section: %d Row: %d",indexPath.section,indexPath.row];
	NSString *CellIdentifier = [NSString stringWithFormat:@"Type: %d",cellInfo.entryType];
	//NSString *CellIdentifier = @"DirectoryDetailCell";

	/* Look up cell in the table queue */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	UITableViewCellStyle currentStyle = UITableViewCellStyleValue2;
	UITableViewCellSelectionStyle selectionStyle = clickable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		
	/* Not found in queue, create a new cell object */
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:currentStyle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	cell.selectionStyle = selectionStyle;
	if (clickable)
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	

	NSString * tempString;
	switch(cellInfo.entryType) {
		case DirectoryTypeNotes:		// Since our notes data can change, we must tend to the cached info ...
			if (self.legislator.notes.length > 0) {
				tempString = self.legislator.notes;
				cell.detailTextLabel.textColor = [UIColor blackColor];
			}
			else {
				tempString = kStaticNotes;
				cell.detailTextLabel.textColor = [UIColor grayColor];
			}
			cellInfo.entryValue = tempString;
			[self standardTextCell:cell withInfo:cellInfo];
			break;
			
		case DirectoryTypeIndexAbout:  // About the Partisanship Index...
			cell.detailTextLabel.textColor = [UIColor colorWithRed:56.0/256.0 green:84/256.0 blue:135/256.0 alpha:1.0];
			cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
			cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
			[self standardTextCell:cell withInfo:cellInfo];
			break;
			
		case DirectoryTypeIndex:		// partisan index custom slider
			cell.textLabel.opaque = NO;
			cell.textLabel.numberOfLines = 2;
			cell.textLabel.highlightedTextColor = [UIColor blackColor];
			//cell.textLabel.text = cellInfo.entryName;
			UISlider *control = [self customSlider];
			[control setValue:cellInfo.entryValue.floatValue animated:YES];
			cell.userInteractionEnabled = NO;
			
			CGRect gradientRect = control.frame;
			gradientRect.size.height = 14;
			gradientRect.origin.y = gradientRect.origin.y + 6;
			UIImageView * gradientView = [[UIImageView alloc] initWithFrame:gradientRect];
			gradientView.image = [UIImage imageNamed:@"TexasGradient.png"];
			gradientView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
			[cell.contentView addSubview:gradientView];
			[cell.contentView addSubview:control];
			break;

		case DirectoryTypeMap:
			cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
			cell.detailTextLabel.numberOfLines = 4;
			[self standardTextCell:cell withInfo:cellInfo];
			break;
			
		case DirectoryTypeWeb:
			if (cellInfo.entryValue.length > 0) {
				if ([cellInfo.entryName isEqualToString:@"Website"])
					cell.detailTextLabel.text = @"Official Website";
				else if ([cellInfo.entryName isEqualToString:@"Bio"])
					cell.detailTextLabel.text = @"VoteSmart Bio";
				cell.textLabel.text = @"Web";
			}
			break;
			
		case DirectoryTypeCommittee:
		case DirectoryTypeOfficeMap:
		case DirectoryTypeChamberMap:
		case DirectoryTypeTwitter:
		case DirectoryTypeMail:
		case DirectoryTypePhone:
		case DirectoryTypeSMS:
		case DirectoryTypeNone:
			[self standardTextCell:cell withInfo:cellInfo];
			break;
				
		default:
			cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			cell.hidden = YES;
			cell.frame  = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 0.01f, 0.01f);
			cell.tag = 999; //EMPTY
			[cell sizeToFit];
			break;
	}
	
	[cell sizeToFit];
	[cell setNeedsDisplay];

	return cell;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [sectionArray count];

}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {		
	return [[sectionArray objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {	
	if (section == 0)
		return @"Legislator Information";
	else if (section == 1)
		return @"Committee Assignments";
	else if (section == 2)
		return @"Capitol Office";
	else if (section == 3)
		return @"District Office #1";
	else if (section == 4)
		return @"District Office #2";
	else if (section == 5)
		return @"District Office #3";
	else //if (section == 6)
		return @"District Office #4";
}


// the user selected a row in the table.
- (void)didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	int row = [newIndexPath row];
	int section = [newIndexPath section];
	
		// deselect the new row using animation
		[self deselectRowAtIndexPath:newIndexPath animated:YES];	
				
		DirectoryDetailInfo *cellInfo = [[sectionArray objectAtIndex:section] objectAtIndex:row];
	
		if (cellInfo.isClickable) {
			if (cellInfo.entryType == DirectoryTypeIndexAbout) {
				TexLegeAppDelegate *appDelegate = (TexLegeAppDelegate *)[[UIApplication sharedApplication] delegate];
				if (appDelegate != nil) [appDelegate showVoteInfoDialog:self.detailController];
			}
			else if (cellInfo.entryType == DirectoryTypeNotes) { // We need to edit the notes thing...
				UIViewController *nextViewController = [[NotesViewController alloc] initWithNibName:@"NotesView" bundle:nil];
				((NotesViewController *)nextViewController).legislator = self.legislator;
				((NotesViewController *)nextViewController).backView = self;

				// If we got a new view controller, push it .
				if (nextViewController) {
					[[self.detailController navigationController] pushViewController:nextViewController animated:YES];
					[nextViewController release];
				}
				
			}
			else if (cellInfo.entryType == DirectoryTypeCommittee) {								
				DetailTableViewController *subDetailController = [[DetailTableViewController alloc] init];
				
				CommitteePositionObj *tempComm = [[self.legislator committees] objectAtIndex:row];
				subDetailController.committee = tempComm.committee;
				
				// push the detail view controller onto the navigation stack to display it
				[[self.detailController navigationController] pushViewController:subDetailController animated:YES];
				
				//	[self.navigationController setNavigationBarHidden:NO];
				[subDetailController release];
				
			}
			else if (cellInfo.entryType == DirectoryTypeOfficeMap || cellInfo.entryType == DirectoryTypeChamberMap) {
				[self.detailController pushMapViewWithURL:[cellInfo generateURL:self.legislator]];
			}
			else if (cellInfo.entryType > kDirectoryTypeIsURLHandler &&
					 cellInfo.entryType < kDirectoryTypeIsExternalHandler) {	// handle the URL ourselves in a webView
				[self.detailController showWebViewWithURL:[cellInfo generateURL:self.legislator]];
				}
			else if (cellInfo.entryType > kDirectoryTypeIsExternalHandler)		// tell the device to open the url externally
			{
				NSURL *myURL = [cellInfo generateURL:self.legislator];
				// do the URL
				
				BOOL isPhone = ([UtilityMethods canMakePhoneCalls]);
				if ((cellInfo.entryType == DirectoryTypePhone) && (!isPhone)) {
					debug_NSLog(@"Tried to make a phonecall, but this isn't a phone: %@", myURL.description);
					[UtilityMethods alertNotAPhone];
					return;
				}
				
				// Switch to the appropriate application for this url...
				if (cellInfo.entryType == DirectoryTypeMap)
					[UtilityMethods openURLWithTrepidation:myURL];
				else
					[UtilityMethods openURLWithoutTrepidation:myURL];
			}
		}
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 44.0f;
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];

	//DirectoryDetailInfo *cellInfo = [[DirectoryDetailInfo alloc] init];
	//[self infoForRow:cellInfo atIndexPath:indexPath];
	
	DirectoryDetailInfo *cellInfo = [[sectionArray objectAtIndex:section] objectAtIndex:row];

	if (cellInfo.entryValue.length <= 0) {
		height = 0.0f;
	}
	else if ([cellInfo.entryName rangeOfString:@"Address"].length > 0) { // We found "Address" in the string.
		height = 98.0f;
	}
	return height;
}


#pragma mark -
#pragma mark Custom Controls

- (UISlider *)customSlider
{
	

    if (customSlider == nil) 
    {
        CGRect frame = CGRectMake(18, 9.0, 270.0, 11.0f);
        customSlider = [[UISlider alloc] initWithFrame:frame];
        //[customSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        // in case the parent view draws with a custom color or gradient, use a transparent color
        customSlider.backgroundColor = [UIColor clearColor];	
		UIImage *stetchLeftTrack = [[UIImage alloc] init];
		UIImage *stetchRightTrack = [[UIImage alloc] init];
       // UIImage *stetchLeftTrack = [[UIImage imageNamed:@"left_slider.png"]
		//							stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        //UIImage *stetchRightTrack = [[UIImage imageNamed:@"right_slider.png"]
		//							 stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        [customSlider setThumbImage: [UIImage imageNamed:@"slider_star.png"] forState:UIControlStateNormal];
//        [customSlider setThumbImage: [UIImage imageNamed:@"fancy_star.png"] forState:UIControlStateNormal];
        [customSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
        [customSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
        customSlider.minimumValue = -1.25;
        customSlider.maximumValue = 1.25;
        customSlider.continuous = YES;
        customSlider.value = 0.001f;
		
		customSlider.autoresizingMask = (UIViewAutoresizingFlexibleWidth);

		//customSlider.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
    }
    return customSlider;
}


@end
