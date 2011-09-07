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
#import "CommitteeDetailDataSource.h"
#import "SLFDataModels.h"

#import "TableDataSourceProtocol.h"
#import "LegislatorDetailViewController.h"

#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "TableCellDataObject.h"
#import "SVWebViewController.h"
#import "LocalyticsSession.h"

@interface CommitteeDetailViewController (Private)
- (void) setupHeader;
- (CommitteeDetailDataSource *)createOrReturnDataSourceForID:(NSString *)objID;
- (void)tableDataChanged:(id)sender;
- (IBAction)redisplayVisibleCells:(id)sender;
@end


@implementation CommitteeDetailViewController
@synthesize detailObjectID;
@synthesize dataSource;
@synthesize headerView;
@synthesize membershipLab, nameLab;
@synthesize masterPopover;

- (NSString *)nibName {
	if ([UtilityMethods isIPadDevice])
		return @"CommitteeDetailViewController~ipad";
	else
		return @"CommitteeDetailViewController~iphone";	
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


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.masterPopover = nil;
    self.headerView = nil;
	self.membershipLab = nil;
	self.nameLab = nil;
    self.dataSource = nil;    
	[super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChanged:) name:kStateMetaNotifyStateLoaded object:nil];
        
    self.headerView.backgroundColor = [self.headerView.backgroundColor colorWithAlphaComponent:0.5f];
    
	self.clearsSelectionOnViewWillAppear = NO;			
	
    self.tableView.dataSource = [self createOrReturnDataSourceForID:nil];
}

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    self.dataSource = nil;
    self.headerView = nil;
	self.membershipLab = nil;
	self.nameLab = nil;
    
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    [self setupHeader];
    [self redisplayVisibleCells:nil];	

}

- (IBAction)redisplayVisibleCells:(id)sender {
	NSArray *visibleCells = self.tableView.visibleCells;
	for (id cell in visibleCells) {
		if ([cell respondsToSelector:@selector(redisplay)])
			[cell performSelector:@selector(redisplay)];
	}
}


#pragma -
#pragma Data Object Accessors


- (SLFCommittee *)detailObject {
    return self.dataSource.detailObject;
}

- (NSString *)detailObjectID {
    return self.dataSource.detailObjectID;
}

- (void)setDetailObjectID:(NSString *)newID {  
    CommitteeDetailDataSource *dsource = [self createOrReturnDataSourceForID:newID];
    dsource.detailObjectID = newID;
    
    if (masterPopover != nil) {
        [masterPopover dismissPopoverAnimated:YES];
    }
    [self tableDataChanged:nil];
}


- (void)setupHeader {
    
	SLFCommittee *object = self.detailObject;
    if (!object)
        return;
    
	NSString *objName = object.committeeName;
    self.nameLab.text = objName;
	self.navigationItem.title = objName;
    
    
    NSArray *newPos = [object.positions allObjects];
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
	
	self.membershipLab.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d %@ and %d %@", @"DataTableUI", @"As in, 43 Republicans and 1 Democrat"), repubCount, repubString, democCount, democString];
    
}


- (CommitteeDetailDataSource *)createOrReturnDataSourceForID:(NSString *)objID {
    if (!dataSource) {
		dataSource = [[CommitteeDetailDataSource alloc] initWithDetailObjectID:objID];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(tableDataChanged:) 
                                                     name:kNotifyTableDataUpdated 
                                                   object:dataSource];     
    }        
    self.tableView.dataSource = dataSource;
    return dataSource;
}


- (void)tableDataChanged:(id)sender {
	[self.tableView reloadData];	
    [self setupHeader];
    [self redisplayVisibleCells:nil];	
}

- (void)stateChanged:(NSNotification *)notification {
    [self tableDataChanged:notification];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {	
	[self redisplayVisibleCells:nil];	
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Popover Support

    // Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[self.tableView reloadData];
}


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
#pragma mark Table View


- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section > 0) {
		BOOL useDark = (indexPath.row % 2 != 0);
	
		cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	}
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section > 0)
		return kCommitteeMemberCellHeight;
	
	return 44.0f;
}


// the user selected a row in the table.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
		
        // deselect the new row using animation
	[tableView deselectRowAtIndexPath:newIndexPath animated:YES];	
	
    SLFCommittee *object = self.detailObject;
    if (!object)
        return;
    
	TableCellDataObject *cellInfo = [self.dataSource dataObjectForIndexPath:newIndexPath];
    
	if (!cellInfo.isClickable)
		return;
	
    switch (cellInfo.entryType) {
        case DirectoryTypeLegislator:
        { 
            LegislatorDetailViewController *subDetailController = [[LegislatorDetailViewController alloc] initWithNibName:@"LegislatorDetailViewController" bundle:nil];
            subDetailController.detailObjectID = cellInfo.entryValue;
			[self.navigationController pushViewController:subDetailController animated:YES];
			[subDetailController release];
        }
            break;
            
            
        case DirectoryTypeWeb:
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
            
            
        default:
            break;
    }

}


@end

