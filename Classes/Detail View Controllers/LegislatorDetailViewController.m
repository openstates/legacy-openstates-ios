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

#import "CommitteeDetailViewController.h"
#import "LegislatorContributionsViewController.h"
#import "MapMiniDetailViewController.h"
#import "BillSearchDataSource.h"
#import "BillsListViewController.h"

#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "TableCellDataObject.h"
#import "NotesViewController.h"
#import "SVWebViewController.h"
#import "SLFEmailComposer.h"
#import "UIImage+ResolutionIndependent.h"
#import "LocalyticsSession.h"
#import "OpenLegislativeAPIs.h"
    //#import "LegislatorMasterViewController.h"
    //#import "AppDelegate.h"

@interface LegislatorDetailViewController (Private)
- (void) setupHeader;
- (LegislatorDetailDataSource *)createOrReturnDataSourceForID:(NSString *)objID;
- (void)tableDataChanged:(id)sender;

@end


@implementation LegislatorDetailViewController
@synthesize detailObjectID;
@synthesize dataSource;
@synthesize headerView;
@synthesize leg_reelection;
@synthesize leg_photoView, leg_partyLab, leg_districtLab, leg_nameLab;
@synthesize notesPopover, masterPopover;

- (NSString *)nibName {
	if ([UtilityMethods isIPadDevice])
		return @"LegislatorDetailViewController~ipad";
	else
		return @"LegislatorDetailViewController~iphone";
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
	
	self.notesPopover = nil;
	self.masterPopover = nil;
    
    self.headerView = nil;
    self.leg_photoView = nil;
    self.leg_partyLab = self.leg_districtLab = self.leg_nameLab = self.leg_reelection = nil;
    
    self.dataSource = nil;
    
	[super dealloc];
}



#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(stateChanged:) name:kStateMetaNotifyStateLoaded object:nil];
    
    self.headerView.backgroundColor = [self.headerView.backgroundColor colorWithAlphaComponent:0.5f];
    
	self.clearsSelectionOnViewWillAppear = NO;			
	
    self.tableView.dataSource = [self createOrReturnDataSourceForID:nil];

}

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    self.dataSource = nil;
    self.headerView = nil;
    self.leg_photoView = nil;
    self.leg_partyLab = self.leg_districtLab = self.leg_nameLab = self.leg_reelection = nil;
    
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    [self setupHeader];
}


#pragma -
#pragma Data Object Accessors


- (SLFLegislator *)detailObject {
    return self.dataSource.detailObject;
}

- (NSString *)detailObjectID {
    return self.dataSource.detailObjectID;
}

- (void)setDetailObjectID:(NSString *)newID {  
    LegislatorDetailDataSource *dsource = [self createOrReturnDataSourceForID:newID];
    dsource.detailObjectID = newID;

    if (masterPopover != nil) {
        [masterPopover dismissPopoverAnimated:YES];
    }
    [self tableDataChanged:nil];
}

- (void)setupHeader {
    
	SLFLegislator *member = self.detailObject;
    if (!member)
        return;
    
	NSString *legName = [NSString stringWithFormat:@"%@ %@",  abbreviateString([member title]), [member fullName]];
	self.leg_nameLab.text = legName;
	self.navigationItem.title = legName;

	//self.leg_photoView.image = [UIImage imageNamed:[UIImage highResImagePathWithPath:member.photo_name]];
	self.leg_partyLab.text = member.party;
	self.leg_districtLab.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"District %@", @"DataTableUI", @"District number"), 
								 member.district];
	self.leg_reelection.text = member.term;

}

- (LegislatorDetailDataSource *)createOrReturnDataSourceForID:(NSString *)objID {
    if (!dataSource) {
		dataSource = [[LegislatorDetailDataSource alloc] initWithDetailObjectID:objID];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(tableDataChanged:) 
                                                     name:kNotifyTableDataUpdated 
                                                   object:dataSource];     
    }        
    self.tableView.dataSource = dataSource;
    return dataSource;
}


- (void)tableDataChanged:(id)sender {
    [self setupHeader];
	[self.tableView reloadData];	
}

- (void)stateChanged:(NSNotification *)notification {
    [self tableDataChanged:notification];
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
	
#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc 
	 willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem*)barButtonItem 
	   forPopoverController: (UIPopoverController*)pc
{
	barButtonItem.title = NSLocalizedStringFromTable(@"Legislators", @"StandardUI", @"The short title for buttons and tabs related to legislators");
	[self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
	self.masterPopover = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc 
	 willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	[self.navigationItem setRightBarButtonItem:nil animated:YES];
	self.masterPopover = nil;
}

- (void) splitViewController:(UISplitViewController *)svc 
           popoverController: (UIPopoverController *)pc
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
	
    SLFLegislator *member = self.detailObject;
    if (!member)
        return;

	TableCellDataObject *cellInfo = [self.dataSource dataObjectForIndexPath:newIndexPath];

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
			CommitteeDetailViewController *subDetailController = [[CommitteeDetailViewController alloc] initWithNibName:@"CommitteeDetailViewController" bundle:nil];
            subDetailController.detailObjectID = cellInfo.entryValue;
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
            MapMiniDetailViewController *mapVC = [[MapMiniDetailViewController alloc] init]; 
            mapVC.detailObjectID = cellInfo.entryValue;
            [self.navigationController pushViewController:mapVC animated:YES];
            [mapVC release];
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

