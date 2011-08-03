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
#import "SLFDataModels.h"
#import "SLFLegislator.h"

#import "LegislatorContributionsViewController.h"
#import "LegislatorMasterViewController.h"

#import "UtilityMethods.h"
#import "TableDataSourceProtocol.h"
#import "TableCellDataObject.h"
#import "NotesViewController.h"
#import "AppDelegate.h"

#import "BillSearchDataSource.h"
#import "BillsListViewController.h"
#import "CommitteeDetailViewController.h"

#import "MapMiniDetailViewController.h"
#import "SVWebViewController.h"

#import "UIImage+ResolutionIndependent.h"

#import "SLFEmailComposer.h"

#import "LocalyticsSession.h"

#import "OpenLegislativeAPIs.h"
#import "TexLegeTheme.h"

@interface LegislatorDetailViewController (Private)
- (void) setupHeader;
@end


@implementation LegislatorDetailViewController
@synthesize dataObjectID;
@synthesize dataSource;
@synthesize headerView;
@synthesize legislator;
@synthesize leg_reelection;
@synthesize leg_photoView, leg_partyLab, leg_districtLab, leg_nameLab;
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
											 selector:@selector(stateChanged:) name:kStateMetaNotifyStateLoaded object:nil];
    
    self.headerView.backgroundColor = [self.headerView.backgroundColor colorWithAlphaComponent:0.5f];

	self.clearsSelectionOnViewWillAppear = NO;				
}

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    self.headerView = nil;
    self.leg_photoView = nil;
    self.leg_partyLab = self.leg_districtLab = self.leg_nameLab = self.leg_reelection = nil;
    
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
	self.leg_partyLab = nil;
	self.leg_districtLab = nil;
	self.leg_nameLab = nil;
	self.notesPopover = nil;
	self.masterPopover = nil;
	self.dataObjectID = nil;
    self.legislator = nil;

	[super dealloc];
}

- (id)dataObject {
	return self.legislator;
}

- (void)setDataObject:(id)newObj {
	[self setLegislator:newObj];
}

- (void)setupHeader {
	SLFLegislator *member = self.legislator;
	
	NSString *legName = [NSString stringWithFormat:@"%@ %@",  abbreviateString([member title]), [member fullName]];
	self.leg_nameLab.text = legName;
	self.navigationItem.title = legName;

	//self.leg_photoView.image = [UIImage imageNamed:[UIImage highResImagePathWithPath:member.photo_name]];
	self.leg_partyLab.text = member.party;
	self.leg_districtLab.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"District %@", @"DataTableUI", @"District number"), 
								 member.district];
	self.leg_reelection.text = member.term;

}


- (LegislatorDetailDataSource *)dataSource {
	SLFLegislator *member = self.legislator;
    if (!member && self.dataObjectID) {
        member = [SLFLegislator findFirstByAttribute:@"legID" withValue:self.dataObjectID];
    }
	if (!dataSource && member) {
		dataSource = [[LegislatorDetailDataSource alloc] initWithLegislatorID:member.legID];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableDataChanged:) name:kNotifyTableDataUpdated object:dataSource];

	}
	return dataSource;
}

- (void)tableDataChanged:(id)sender {
    [self setupHeader];
	[self.tableView reloadData];	
}

- (void)stateChanged:(NSNotification *)notification {
    [self tableDataChanged:notification];
}


- (void)setLegislator:(SLFLegislator *)anObject {

	if (dataSource && anObject && legislator && [legislator isEqual:anObject] && [dataSource.legislator isEqual:anObject])
		return;
    
    [legislator release];
    legislator = [anObject retain];
    self.dataObjectID = anObject.legID;

	if (anObject) {
		self.dataObjectID = anObject.legID;
        
        self.dataSource.legislator = anObject;
		self.tableView.dataSource = dataSource;

		if (masterPopover != nil) {
			[masterPopover dismissPopoverAnimated:YES];
		}		
        
        [self tableDataChanged:nil];
	}
}
#pragma mark -
#pragma mark Managing the popover

// Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[self.tableView reloadData];
	if (self.notesPopover && [self.notesPopover isEqual:popoverController]) {
		self.notesPopover = nil;
	}
}
	
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
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
	SLFLegislator *member = self.legislator;

	if (!cellInfo.isClickable)
		return;
	
    switch (cellInfo.entryType) {
        case DirectoryTypeNotes:
        { // We need to edit the notes thing...
			
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
            break;
            
            
        case DirectoryTypeCommittee:
        { 
			CommitteeDetailViewController *subDetailController = [[CommitteeDetailViewController alloc] initWithCommitteeID:cellInfo.entryValue];
			[self.navigationController pushViewController:subDetailController animated:YES];
			[subDetailController release];
        }
            break;
            
            
        case DirectoryTypeContributions:
        {
			if ([TexLegeReachability canReachHostWithURL:[NSURL URLWithString:transApiBaseURL]]) { 
				LegislatorContributionsViewController *subDetailController = [[LegislatorContributionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
				[subDetailController setQueryEntityID:cellInfo.entryValue type:[NSNumber numberWithInteger:kContributionQueryRecipient] cycle:@"-1"];
				[self.navigationController pushViewController:subDetailController animated:YES];
				[subDetailController release];
			}
        }
            break; 
            
            
        case DirectoryTypeBills:
        {
			if ([TexLegeReachability openstatesReachable]) { 
				BillsListViewController *subDetailController = [[BillsListViewController alloc] initWithStyle:UITableViewStylePlain];
				subDetailController.title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Bills Authored by %@", @"DataTableUI", @"Title for cell, the legislative bills authored by someone."), 
											 [member shortNameForButtons]];
				[subDetailController.dataSource startSearchForBillsAuthoredBy:cellInfo.entryValue];
				[self.navigationController pushViewController:subDetailController animated:YES];
				[subDetailController release];
			}
        }
            break;
            
            
        case DirectoryTypeMail:
        {
			[[SLFEmailComposer sharedSLFEmailComposer] presentMailComposerTo:cellInfo.entryValue 
                                                                     subject:@"" body:@"" commander:self];			
        }
            break;
            
            
        case DirectoryTypeMap:
        {
            MapMiniDetailViewController *mapViewController = [[MapMiniDetailViewController alloc] initWithMapID:cellInfo.entryValue];            
            [self.navigationController pushViewController:mapViewController animated:YES];
            [mapViewController release];
        }
            break;
            
            
        case DirectoryTypeWeb:
        case DirectoryTypeTwitter:
        {
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
            break;
            
            
        case DirectoryTypePhone:
        case DirectoryTypeSMS:
        {
            NSURL *url = [cellInfo generateURL];			
			BOOL isPhone = ([UtilityMethods canMakePhoneCalls]);
			
            if (cellInfo.entryType == DirectoryTypeSMS || isPhone) {
                [UtilityMethods openURLWithoutTrepidation:url];
            }
        }
            break;
            
        default:
            break;
    }
}


@end

