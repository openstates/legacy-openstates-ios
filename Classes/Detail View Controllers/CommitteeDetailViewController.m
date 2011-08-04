//
//  CommitteeDetailViewController.m
//  Created by Gregory Combs on 6/29/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "CommitteeDetailViewController.h"
#import "SLFDataModels.h"
#import "SLFMappingsManager.h"

#import "TableDataSourceProtocol.h"
#import "LegislatorDetailViewController.h"

#import "UtilityMethods.h"
#import "SVWebViewController.h"
#import "AppDelegate.h"
#import "TexLegeTheme.h"
#import "LegislatorCell.h"
#import "LegislatorCellView.h"
#import "TexLegeStandardGroupCell.h"
#import "SLFEmailComposer.h"
#import "LocalyticsSession.h"

@interface CommitteeDetailViewController (Private)
- (void) buildInfoSectionArray;
- (void) calcCommitteePartisanship;
- (void)loadDataFromDataStoreWithID:(NSString *)objID;

@end

@implementation CommitteeDetailViewController

@synthesize dataObjectID, masterPopover;
@synthesize membershipLab, nameLab, infoSectionArray;

@synthesize resourcePath;
@synthesize resourceClass;
@synthesize committee;
@synthesize positions;

enum Sections {
    //kHeaderSection = 0,
	kInfoSection = 0,
	kMembersSection,
    NUM_SECTIONS
};
enum InfoSectionRows {
	kInfoSectionName = 0,
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

- (id)initWithCommitteeID:(NSString *)committeeID {
    if ((self = [super init])) {
        
        self.resourceClass = [SLFCommittee class];
        self.resourcePath = [NSString stringWithFormat:@"/committees/%@/", committeeID];
        
        [self loadDataFromDataStoreWithID:committeeID];
        [self loadData];
        
    }
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	self.dataObjectID = nil;
	self.membershipLab = nil;
	self.nameLab = nil;
	self.masterPopover = nil;
	self.infoSectionArray = nil;
    self.committee = nil;
    self.resourcePath = nil;
    self.positions = nil;
    [super dealloc];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.resourceClass = [SLFCommittee class];

    
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
	self.membershipLab = nil;
    self.nameLab = nil;
	[super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
}

- (void)reloadButtonWasPressed:(id)sender {
    // Load the object model via RestKit
	[self loadData];
}

- (void)loadDataFromDataStoreWithID:(NSString *)objID {
	self.committee = [SLFCommittee findFirstByAttribute:@"committeeID" withValue:objID];
}

- (void)loadData {
	if (!self.resourcePath)
		return;
	
    // Load the object model via RestKit	
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    RKObjectMapping* objMapping = [objectManager.mappingProvider objectMappingForClass:self.resourceClass];
    
	NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
								 SUNLIGHT_APIKEY, @"apikey",
								 nil];
    
	NSString *newPath = [self.resourcePath appendQueryParams:queryParams];
	
    [objectManager loadObjectsAtResourcePath:newPath objectMapping:objMapping delegate:self];
}

- (void)setCommittee:(SLFCommittee *)newObj {
	[committee release];
	committee = [newObj retain];
	
    self.positions = nil;
    self.dataObjectID = newObj.committeeID;

	if (newObj) {
		self.navigationItem.title = newObj.committeeName;
		self.nameLab.text = newObj.committeeName;

        self.resourcePath = RKMakePathWithObject(@"/committees/(committeeID)/", newObj);
		[self loadData];
        
        if (self.masterPopover)
			[self.masterPopover dismissPopoverAnimated:YES];

	}
}

#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdatedAt"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
	[committee release];
	committee = [object retain];
	
	self.positions = [committee sortedMembers];
	
    self.navigationItem.title = committee.committeeName;
    self.nameLab.text = committee.committeeName;

    [self buildInfoSectionArray];
    [self calcCommitteePartisanship];
    [self.tableView reloadData];    
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
#warning revise this
	UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Error" 
                                                     message:[error localizedDescription] 
                                                    delegate:nil 
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[alert show];
	RKLogError(@"Hit error: %@", [error localizedDescription]);
}


- (void)objectLoader:(RKObjectLoader*)loader willMapData:(inout id *)mappableData {
	
	if (loader.objectMapping.objectClass == self.resourceClass) {
		
        mappableData = [SLFMappingsManager premapCommittee:self.committee withMappableData:mappableData];
        
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

- (SLFCommittee *)committee {
	SLFCommittee *anObject = nil;
	if (self.dataObjectID) {
		@try {
			anObject = [SLFCommittee findFirstByAttribute:@"committeeID" withValue:self.dataObjectID];
		}
		@catch (NSException * e) {
		}
	}
	return anObject;
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
	if ([UtilityMethods isLandscapeOrientation]) {
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"ERR_POPOVER_IN_LANDSCAPE"];
	}		 
}	

#pragma mark -
#pragma mark View Setup

- (void)buildInfoSectionArray {	
	
	NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:12]; // arbitrary
	NSDictionary *infoDict = nil;
	TableCellDataObject *cellInfo = nil;
	
//case kInfoSectionName:
    cellInfo = [[TableCellDataObject alloc] init];
    cellInfo.subtitle = NSLocalizedStringFromTable(@"Committee", @"DataTableUI", @"");
    cellInfo.title = self.committee.committeeName;
    cellInfo.isClickable = NO;
    cellInfo.entryValue = nil;
    cellInfo.entryType = DirectoryTypeNone;
	[tempArray addObject:cellInfo];
	[cellInfo release], cellInfo = nil;

//case kInfoSectionWeb:	 // open the web page
    
    cellInfo = [[TableCellDataObject alloc] initWithDictionary:infoDict];
    cellInfo.title = NSLocalizedStringFromTable(@"Website & Meetings", @"DataTableUI", @"");
    cellInfo.subtitle = NSLocalizedStringFromTable(@"Web", @"DataTableUI", @"Cell title listing a web address");
    cellInfo.isClickable = NO;
    cellInfo.entryValue = @"";
    cellInfo.entryType = DirectoryTypeWeb;
    
    if (NO == IsEmpty(self.committee.sources)) {
        NSString *text = [self.committee.sources objectAtIndex:0];
        cellInfo.isClickable = (NO == IsEmpty(text));
        if (cellInfo.isClickable) {
            cellInfo.entryValue = [text urlSafeString];
        }
    }
    
    [tempArray addObject:cellInfo];
	[cellInfo release], cellInfo = nil;
	
	self.infoSectionArray = tempArray;
	[tempArray release];
}

- (void) calcCommitteePartisanship {
	NSArray *newPos = self.positions;
	if (!newPos && [newPos count])
		return;
	
    NSString *repubString = stringForParty(REPUBLICAN, TLReturnFull);
	NSString *democString = stringForParty(DEMOCRAT, TLReturnFull);

	NSInteger democCount = 0, repubCount = 0;
    
	NSArray *repubs = [newPos findAllWhereKeyPath:@"legislator.party" equals:repubString];	
	repubCount = [repubs count];
    
    NSArray *dems = [newPos findAllWhereKeyPath:@"legislator.party" equals:democString];	
	democCount = [dems count];
	
	if (repubCount != 1)
		repubString = [repubString stringByAppendingString:@"s"];
	if (democCount != 1)
		democString = [democString stringByAppendingString:@"s"];
	
	self.membershipLab.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d %@ and %d %@", @"DataTableUI", @"As in, 43 Republicans and 1 Democrat"), 
							   repubCount, repubString, democCount, democString];
		
}

#pragma mark -
#pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {		
	
	NSInteger rows = 0;	
	switch (section) {
		case kMembersSection:
			rows = [self.positions count];
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

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section > kInfoSection) {
		BOOL useDark = (indexPath.row % 2 != 0);
	
		cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	
	NSString *CellIdentifier;
		
	BOOL useDark = NO;
	BOOL isMember = (section > kInfoSection);
		
	if (isMember) {
		useDark = (indexPath.row % 2 != 0);
		
		if (useDark)
			CellIdentifier = @"CommitteeMemberDark";
		else
			CellIdentifier = @"CommitteeMemberLight";
	}
	else
		CellIdentifier = @"Committee-NoDisclosure";
	
	UITableViewCellStyle style = section > kInfoSection ? UITableViewCellStyleSubtitle : UITableViewCellStyleValue2;
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		if (isMember) {
			LegislatorCell *newcell = [[[LegislatorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			if ([UtilityMethods isIPadDevice]) {
				newcell.cellView.wideSize = YES;
			}
			newcell.frame = CGRectMake(0.0, 0.0, newcell.cellSize.width, quartzRowHeight);		

			newcell.accessoryView.hidden = NO;
			cell = newcell;
		}
		else {
			cell = (UITableViewCell *)[[[TexLegeStandardGroupCell alloc] initWithStyle:style reuseIdentifier:CellIdentifier] autorelease];			
		}
	}    

	SLFLegislator *legislator = nil;
	NSString *role = nil;
    

	switch (section) {
		case kMembersSection: {
            
            NSArray *memberList = [self.committee sortedMembers];

			if ([memberList count] >= row) {
                SLFCommitteePosition* pos = [memberList objectAtIndex:indexPath.row];
                legislator = pos.legislator;
                role = pos.positionType;
			}
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
		
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	
	if (isMember) {
		LegislatorCell *newcell = (LegislatorCell *)cell;
		[newcell setLegislator:legislator];
		newcell.role = role;
		newcell.cellView.useDarkBackground = useDark;
	}
	
	return cell;
}


#pragma mark -
#pragma mark Table view delegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString * sectionName;
	
	switch (section) {
		case kMembersSection:
			sectionName = NSLocalizedStringFromTable(@"Members", @"DataTableUI", @"Cell title for a list of committee members");
			break;
			
		case kInfoSection:
		default:
            sectionName = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ Committee Info",@"DataTableUI", @"Information for a given legislative committee"),
                            chamberStringFromOpenStates(self.committee.chamber)];
			break;
	}
	return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section > kInfoSection)
		return quartzRowHeight;
	
	return 44.0f;
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
			case kInfoSectionWeb: {	 // open the web page
                NSURL *url = [cellInfo generateURL];;
				[self pushInternalBrowserWithURL:url];
			}
				break;
			default:
				break;
		}
		
	}
	else {
		LegislatorDetailViewController *subDetailController = [[LegislatorDetailViewController alloc] initWithNibName:@"LegislatorDetailViewController" bundle:nil];
		
		switch (section) {
			case kMembersSection: { // Committee Members
                SLFCommitteePosition *pos = [[self.committee sortedMembers] objectAtIndex:row];
                subDetailController.detailObjectID = pos.legID;
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

