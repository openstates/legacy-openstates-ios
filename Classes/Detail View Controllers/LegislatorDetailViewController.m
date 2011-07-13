//
//  LegislatorDetailViewController.m
//  Created by Gregory Combs on 6/28/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "TableDataSourceProtocol.h"
#import "LegislatorDetailViewController.h"
#import "LegislatorDetailDataSource.h"
#import "LegislatorContributionsViewController.h"

#import "LegislatorMasterViewController.h"
#import "DistrictOfficeObj+MapKit.h"
#import "DistrictMapObj+RestKit.h"
#import "DistrictMapObj+MapKit.h"
#import "CommitteeObj.h"
#import "CommitteePositionObj.h"
#import "LegislatorObj+RestKit.h"

#import "TexLegeCoreDataUtils.h"
#import "UtilityMethods.h"
#import "TableDataSourceProtocol.h"
#import "TableCellDataObject.h"
#import "NotesViewController.h"
#import "StatesLegeAppDelegate.h"

#import "BillSearchDataSource.h"
#import "BillsListViewController.h"
#import "CommitteeDetailViewController.h"
#import "DistrictOfficeMasterViewController.h"

#import "MapMiniDetailViewController.h"
#import "SVWebViewController.h"

#import "UIImage+ResolutionIndependent.h"

#import "TexLegeEmailComposer.h"

#import "LocalyticsSession.h"

#import "OpenLegislativeAPIs.h"
#import "TexLegeTheme.h"

@interface LegislatorDetailViewController (Private)
- (void) setupHeader;
@end


@implementation LegislatorDetailViewController
@synthesize dataObjectID;
@synthesize dataSource;
@synthesize headerView, miniBackgroundView;

@synthesize leg_reelection;
@synthesize leg_photoView, leg_partyLab, leg_districtLab, leg_tenureLab, leg_nameLab;
@synthesize notesPopover, masterPopover;

#pragma mark -
#pragma mark View lifecycle

- (NSString *)nibName {
	if ([UtilityMethods isIPadDevice])
		return @"LegislatorDetailViewController~ipad";
	else
		return @"LegislatorDetailViewController~iphone";
}

- (void)viewDidLoad {
    [super viewDidLoad];
		
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resetTableData:) name:@"RESTKIT_LOADED_LEGISLATOROBJ" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resetTableData:) name:@"RESTKIT_LOADED_STAFFEROBJ" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resetTableData:) name:@"RESTKIT_LOADED_DISTRICTOFFICEOBJ" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resetTableData:) name:@"RESTKIT_LOADED_DISTRICTMAPOBJ" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resetTableData:) name:@"RESTKIT_LOADED_COMMITTEEOBJ" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resetTableData:) name:@"RESTKIT_LOADED_COMMITTEEPOSITIONOBJ" object:nil];
	
	UIImage *sealImage = [UIImage imageNamed:@"seal.png"];
	UIColor *sealColor = [[UIColor colorWithPatternImage:sealImage] colorWithAlphaComponent:0.5f];	
	self.miniBackgroundView.backgroundColor = sealColor;
	//self.headerView.backgroundColor = sealColor;
	
	self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.clearsSelectionOnViewWillAppear = NO;				
}

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super viewDidUnload];
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.dataSource = nil;
	self.headerView = nil;
	self.leg_photoView = nil;
	self.leg_reelection = nil;
	self.miniBackgroundView = nil;
	self.leg_partyLab = nil;
	self.leg_districtLab = nil;
	self.leg_tenureLab = nil;
	self.leg_nameLab = nil;
	self.notesPopover = nil;
	self.masterPopover = nil;
	self.dataObjectID = nil;

	[super dealloc];
}

- (id)dataObject {
	return self.legislator;
}

- (void)setDataObject:(id)newObj {
	[self setLegislator:newObj];
}

- (void)setupHeader {
	LegislatorObj *member = self.legislator;
	
	NSString *legName = [NSString stringWithFormat:@"%@ %@",  [member legTypeShortName], [member legProperName]];
	self.leg_nameLab.text = legName;
	self.navigationItem.title = legName;

	self.leg_photoView.image = [UIImage imageNamed:[UIImage highResImagePathWithPath:member.photo_name]];
	self.leg_partyLab.text = [member party_name];
	self.leg_districtLab.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"District %@", @"DataTableUI", @"District number"), 
								 member.district];
	self.leg_tenureLab.text = [member tenureString];
	if (member.nextElection) {
		
		self.leg_reelection.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Reelection: %@", @"DataTableUI", @"Year of person's next reelection"), 
									member.nextElection];
	}

}


- (LegislatorDetailDataSource *)dataSource {
	LegislatorObj *member = self.legislator;
	if (!dataSource && member) {
		dataSource = [[LegislatorDetailDataSource alloc] initWithLegislator:member];
	}
	return dataSource;
}

- (void)setDataSource:(LegislatorDetailDataSource *)newObj {	
	if (newObj == dataSource)
		return;
	if (dataSource)
		[dataSource release], dataSource = nil;
	if (newObj)
		dataSource = [newObj retain];
}


- (LegislatorObj *)legislator {
	LegislatorObj *anObject = nil;
	if (self.dataObjectID) {
		@try {
			anObject = [LegislatorObj objectWithPrimaryKeyValue:self.dataObjectID];
		}
		@catch (NSException * e) {
		}
	}
	return anObject;
}

- (void)setLegislator:(LegislatorObj *)anObject {
	if (self.dataSource && anObject && self.dataObjectID && [[anObject legislatorID] isEqual:self.dataObjectID])
		return;
	
	self.dataSource = nil;
	self.dataObjectID = nil;
	
	if (anObject) {
		self.dataObjectID = [anObject legislatorID];

		self.tableView.dataSource = self.dataSource;

		[self setupHeader];

		if (masterPopover != nil) {
			[masterPopover dismissPopoverAnimated:YES];
		}		
		[self.tableView reloadData];

		[self.view setNeedsDisplay];
	}
}
#pragma mark -
#pragma mark Managing the popover

- (IBAction)resetTableData:(id)sender {
	// this will force our datasource to renew everything
	self.dataSource.legislator = self.legislator;
	[self.tableView reloadData];	
}

// Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[self.tableView reloadData];
	if (self.notesPopover && [self.notesPopover isEqual:popoverController]) {
		self.notesPopover = nil;
	}
}
	
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	BOOL ipad = [UtilityMethods isIPadDevice];
	BOOL portrait = (![UtilityMethods isLandscapeOrientation]);

	if (portrait && ipad && !self.legislator)
		self.legislator = [[[StatesLegeAppDelegate appDelegate] legislatorMasterVC] selectObjectOnAppear];		
	
	if (self.legislator)
		[self setupHeader];
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc 
	 willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem 
	   forPopoverController: (UIPopoverController*)pc {
	//debug_NSLog(@"Entering portrait, showing the button: %@", [aViewController class]);
	barButtonItem.title = NSLocalizedStringFromTable(@"Legislators", @"StandardUI", @"The short title for buttons and tabs related to legislators");
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
	if (self.notesPopover) {
		[self.notesPopover dismissPopoverAnimated:YES];
		self.notesPopover = nil;
	}
}

#pragma mark -
#pragma mark orientations

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

#pragma mark -
#pragma mark Table View Delegate
// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
	// deselect the new row using animation
	[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];	
	
	TableCellDataObject *cellInfo = [self.dataSource dataObjectForIndexPath:newIndexPath];
	LegislatorObj *member = self.legislator;

	if (!cellInfo.isClickable)
		return;
	
		if (cellInfo.entryType == DirectoryTypeNotes) { // We need to edit the notes thing...
			
			NotesViewController *nextViewController = nil;
			if ([UtilityMethods isIPadDevice])
				nextViewController = [[NotesViewController alloc] initWithNibName:@"NotesView~ipad" bundle:nil];
			else
				nextViewController = [[NotesViewController alloc] initWithNibName:@"NotesView" bundle:nil];
			
			// If we got a new view controller, push it .
			if (nextViewController) {
				nextViewController.legislator = member;
				nextViewController.backViewController = self;
				
				if ([UtilityMethods isIPadDevice]) {
					self.notesPopover = [[[UIPopoverController alloc] initWithContentViewController:nextViewController] autorelease];
					self.notesPopover.delegate = self;
					CGRect cellRect = [aTableView rectForRowAtIndexPath:newIndexPath];
					[self.notesPopover presentPopoverFromRect:cellRect inView:aTableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
				}
				else {
					[self.navigationController pushViewController:nextViewController animated:YES];
				}
				
				[nextViewController release];
			}
		}
		else if (cellInfo.entryType == DirectoryTypeCommittee) {
			CommitteeDetailViewController *subDetailController = [[CommitteeDetailViewController alloc] initWithNibName:@"CommitteeDetailViewController" bundle:nil];
			subDetailController.committee = cellInfo.entryValue;
			[self.navigationController pushViewController:subDetailController animated:YES];
			[subDetailController release];
		}
		else if (cellInfo.entryType == DirectoryTypeContributions) {
			if ([TexLegeReachability canReachHostWithURL:[NSURL URLWithString:transApiBaseURL]]) { 
				LegislatorContributionsViewController *subDetailController = [[LegislatorContributionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
				[subDetailController setQueryEntityID:cellInfo.entryValue type:[NSNumber numberWithInteger:kContributionQueryRecipient] cycle:@"-1"];
				[self.navigationController pushViewController:subDetailController animated:YES];
				[subDetailController release];
			}
		}
		else if (cellInfo.entryType == DirectoryTypeBills) {
			if ([TexLegeReachability openstatesReachable]) { 
				BillsListViewController *subDetailController = [[BillsListViewController alloc] initWithStyle:UITableViewStylePlain];
				subDetailController.title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Bills Authored by %@", @"DataTableUI", @"Title for cell, the legislative bills authored by someone."), 
											 [member shortNameForButtons]];
				[subDetailController.dataSource startSearchForBillsAuthoredBy:cellInfo.entryValue];
				[self.navigationController pushViewController:subDetailController animated:YES];
				[subDetailController release];
			}
		}
		else if (cellInfo.entryType == DirectoryTypeMail) {
			[[TexLegeEmailComposer sharedTexLegeEmailComposer] presentMailComposerTo:cellInfo.entryValue 
																			 subject:@"" body:@"" commander:self];			
		}
		// Switch to the appropriate application for this url...
		else if (cellInfo.entryType == DirectoryTypeMap) {
			if ([cellInfo.entryValue isKindOfClass:[DistrictOfficeObj class]] || [cellInfo.entryValue isKindOfClass:[DistrictMapObj class]])
			{		
				MapMiniDetailViewController *mapViewController = [[MapMiniDetailViewController alloc] init];
				[mapViewController view];
				
				DistrictOfficeObj *districtOffice = nil;
				if ([cellInfo.entryValue isKindOfClass:[DistrictOfficeObj class]])
					districtOffice = cellInfo.entryValue;
				
				[mapViewController resetMapViewWithAnimation:NO];
				BOOL isDistMap = NO;
				id<MKAnnotation> theAnnotation = nil;
				if (districtOffice) {
					theAnnotation = districtOffice;
					[mapViewController.mapView addAnnotation:theAnnotation];
					[mapViewController moveMapToAnnotation:theAnnotation];
				}
				else {
					theAnnotation = member.districtMap;
					[mapViewController.mapView addAnnotation:theAnnotation];
					[mapViewController moveMapToAnnotation:theAnnotation];
					[mapViewController.mapView performSelector:@selector(addOverlay:) 
													withObject:[member.districtMap polygon] afterDelay:0.5f];
					isDistMap = YES;
				}
				if (theAnnotation) {
					mapViewController.navigationItem.title = [theAnnotation title];
				}

				[self.navigationController pushViewController:mapViewController animated:YES];
				[mapViewController release];
				
				if (isDistMap) {
					[[DistrictMapObj managedObjectContext] refreshObject:member.districtMap mergeChanges:NO];
				}
			}
		}
		else if (cellInfo.entryType > kDirectoryTypeIsURLHandler &&
				 cellInfo.entryType < kDirectoryTypeIsExternalHandler) {	// handle the URL ourselves in a webView
			NSURL *url = [cellInfo generateURL];
			
			if ([TexLegeReachability canReachHostWithURL:url]) { // do we have a good URL/connection?

				if ([[url scheme] isEqualToString:@"twitter"])
					[[UIApplication sharedApplication] openURL:url];
				else {
					NSString *urlString = [url absoluteString];
					
					SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:urlString];
					webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
					[self presentModalViewController:webViewController animated:YES];	
					[webViewController release];
				}
			}
		}
		else if (cellInfo.entryType > kDirectoryTypeIsExternalHandler)		// tell the device to open the url externally
		{
			NSURL *myURL = [cellInfo generateURL];			
			BOOL isPhone = ([UtilityMethods canMakePhoneCalls]);
			
			if ((cellInfo.entryType == DirectoryTypePhone) && (!isPhone)) {
				debug_NSLog(@"Tried to make a phone call, but this isn't a phone: %@", myURL.description);
				[UtilityMethods alertNotAPhone];
				return;
			}
			
			[UtilityMethods openURLWithoutTrepidation:myURL];
		}
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 44.0f;
	TableCellDataObject *cellInfo = [self.dataSource dataObjectForIndexPath:indexPath];
	
	if (cellInfo == nil) {
		debug_NSLog(@"LegislatorDetailViewController:heightForRow: error finding table entry for section:%d row:%d", indexPath.section, indexPath.row);
		return height;
	}
	if (cellInfo.subtitle && [cellInfo.subtitle hasSubstring:NSLocalizedStringFromTable(@"Address", @"DataTableUI", @"Cell title listing a street address")
											 caseInsensitive:YES]) {
		height = 98.0f;
	}
	else if ([cellInfo.entryValue isKindOfClass:[NSString string]]) {
		NSString *tempStr = cellInfo.entryValue;
		if (!tempStr || [tempStr length] <= 0) {
			height = 0.0f;
		}
	}
	return height;
}

@end

