//
//  CalendarDetailViewController.m
//  Created by Gregory Combs on 7/29/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//
#import "CalendarDetailViewController.h"
#import "CalendarMasterViewController.h"
#import "UtilityMethods.h"
#import "SVWebViewController.h"
#import "StatesLegeAppDelegate.h"
#import "ChamberCalendarObj.h"
#import "TexLegeTheme.h"
#import "LocalyticsSession.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "CalendarEventsLoader.h"

@interface CalendarDetailViewController (Private) 
	
@end

@implementation CalendarDetailViewController
@synthesize chamberCalendar;
@synthesize webView;
@synthesize masterPopover;
@synthesize selectedRowRect;
@synthesize eventPopover;

+ (NSString *)nibName {
	if ([UtilityMethods isIPadDevice])
		return @"CalendarDetailViewController~ipad";
	else
		return @"CalendarDetailViewController~iphone";	
}

- (NSString *)nibName {
	return [CalendarDetailViewController nibName];	
}

- (void)finalizeUI {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reloadEvents:) name:kCalendarEventsNotifyLoaded object:nil];	

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reloadEvents:) name:kCalendarEventsNotifyError object:nil];	

	self.calendarView.tableView.rowHeight = 73;
	self.calendarView.tableView.backgroundColor = [TexLegeTheme backgroundLight];
	
	self.selectedRowRect = CGRectZero;
	
	if ([UtilityMethods isIPadDevice]) {
		UIImage *sealImage = [UIImage imageNamed:@"seal.png"];
		UIColor *sealColor = [UIColor colorWithPatternImage:sealImage];		
		self.calendarView.backgroundColor = sealColor;
	}
	
	//self.navigationItem.title = @"Upcoming Committee Meetings";

	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];
	self.searchDisplayController.searchBar.tintColor = [TexLegeTheme navbar];
	self.navigationItem.titleView = self.searchDisplayController.searchBar;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	if (!self.webView && [UtilityMethods isIPadDevice]) {
		[[NSBundle mainBundle] loadNibNamed:[self nibName] owner:self options:nil];
	}
	
	[self finalizeUI];
}	

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self finalizeUI];
}

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning {	
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	self.chamberCalendar = nil;
	self.webView = nil;
	self.masterPopover = nil;
	self.eventPopover = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];

	[[CalendarEventsLoader sharedCalendarEventsLoader] events];
	
	if ([UtilityMethods isIPadDevice] && !self.chamberCalendar && ![UtilityMethods isLandscapeOrientation])  {
		StatesLegeAppDelegate *appDelegate = [StatesLegeAppDelegate appDelegate];
		
		self.chamberCalendar = [[appDelegate calendarMasterVC] selectObjectOnAppear];		
	}
	
	if (self.chamberCalendar)
		self.searchDisplayController.searchBar.placeholder = self.chamberCalendar.title;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if ([UtilityMethods isIPadDevice])
		return YES;
	else
		return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark -
#pragma mark Data Objects

- (void)reloadEvents:(NSNotification*)notification {
	[self reloadData];
}

- (id)dataObject {
	return self.chamberCalendar;
}

- (void)setDataObject:(id)newObj {
	[self setChamberCalendar:newObj];
}

- (void)setChamberCalendar:(ChamberCalendarObj *)newObj {
	if (chamberCalendar && newObj && self.webView) {
		if (![[chamberCalendar valueForKey:@"title"] isEqualToString:[newObj valueForKey:@"title"]])
			[self.webView loadHTMLString:@"<html></html>" baseURL:nil];
	}
	
	nice_release(chamberCalendar);

	if (newObj) {
		if (masterPopover)
			[masterPopover dismissPopoverAnimated:YES];
		
		chamberCalendar = [newObj retain];
		
		[self view];
		
		[self setDelegate:self];
		[self setDataSource:chamberCalendar];
		[self.searchDisplayController setSearchResultsDataSource:chamberCalendar];
				
		[self showAndSelectDate:[NSDate date]];
	}
}

#pragma mark -
#pragma mark Popover Support


- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
	//debug_NSLog(@"Entering portrait, showing the button: %@", [aViewController class]);
    barButtonItem.title =  NSLocalizedStringFromTable(@"Meetings", @"StandardUI", @"The short title for buttons and tabs related to committee meetings (or calendar events)");
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

#pragma -
#pragma UITableViewDelegate


- (void)tableView:(UITableView *)tv accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *eventDict = [self.chamberCalendar eventForIndexPath:indexPath];
	if (eventDict) {
		
		self.selectedRowRect = [tv rectForRowAtIndexPath:indexPath];
		
		[[CalendarEventsLoader sharedCalendarEventsLoader] addEventToiCal:eventDict delegate:self];	
	}
}


- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tv deselectRowAtIndexPath:indexPath animated:YES];
	
	self.selectedRowRect = [tv rectForRowAtIndexPath:indexPath];

	NSDictionary *eventDict = [self.chamberCalendar eventForIndexPath:indexPath];
	
	// They've picked some results from the search table, load them up...
	if (tv == self.searchDisplayController.searchResultsTableView) {
		[self.searchDisplayController setActive:NO animated:YES];
		[self showAndSelectDate:[eventDict objectForKey:kCalendarEventsLocalizedDateKey]];
	}
		
	NSString *urlString = [eventDict objectForKey:kCalendarEventsAnnouncementURLKey];
	if (IsEmpty(urlString)) {
		// Can't go further if we don't have a usable URL string
		return;
	}
	
	NSURL *url = [NSURL URLWithString:urlString];
	
	if ([TexLegeReachability canReachHostWithURL:url]) { // do we have a good URL/connection?
		
		if ([UtilityMethods isIPadDevice]) {	
			NSURLRequest *urlReq = [NSURLRequest requestWithURL:url 
													cachePolicy:NSURLRequestUseProtocolCachePolicy 
												timeoutInterval:60.0];
			if (urlReq) {
				[self.webView loadRequest:urlReq];	
			}
			
		}
		else {			
			SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:urlString];
			webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
			[self presentModalViewController:webViewController animated:YES];	
			[webViewController release];
		}		
	}
}

#pragma mark -
#pragma mark Search Results Delegate

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	id gridView = self.calendarView.gridView;
	if (gridView && [gridView respondsToSelector:@selector(setAlpha:)]) {
		[gridView setAlpha:0.4f];
	}
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	id gridView = self.calendarView.gridView;
	if (gridView && [gridView respondsToSelector:@selector(setAlpha:)]) {
		[gridView setAlpha:1.0f];
	}
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	[self.chamberCalendar filterEventsByString:searchString];
	
	return YES; // or foundSomething?
}

- (void) presentEventEditorForEvent:(EKEvent *)event {
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"iCAL_EVENT"];
	
	EKEventViewController *controller = [[EKEventViewController alloc] init];			
	controller.event = event;
	controller.allowsEditing = YES;
	
	// Wish we had popovers for iPhones?
	if (NO == [UtilityMethods isIPadDevice]) {
		
		//	Push eventViewController onto the navigation controller stack
		//	If the underlying event gets deleted, detailViewController will remove itself from
		//	the stack and clear its event property.
		[self.navigationController pushViewController:controller animated:YES];
	}
	else  {	
		
		/* This is a hacky way to do this, but since we aren't using a navigationController
		 we create a popover, but first we have to wrap the content in a new navigationController
		 in order to get the necessary button in a nav bar to edit the event.
		 */
		
		controller.modalInPopover = NO;
		
		UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:controller];
		navC.navigationBar.tintColor = [TexLegeTheme navbar];
		UIPopoverController* aPopover = [[UIPopoverController alloc]
										 initWithContentViewController:navC];
		self.eventPopover = aPopover;
		self.eventPopover.delegate = self;
		[self.eventPopover presentPopoverFromRect:self.selectedRowRect 
												inView:self.calendarView.tableView
							  permittedArrowDirections:UIPopoverArrowDirectionAny 
											  animated:YES];
		[navC release];
		[aPopover release];				
	}
	[controller release];
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)newPop {
	return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)newPop {
	if ([newPop isEqual:self.eventPopover]) {
		self.eventPopover = nil;
	}
}

@end
