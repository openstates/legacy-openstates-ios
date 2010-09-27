//
//  CalendarDetailViewController.m
//  TexLege
//
//  Created by Gregory Combs on 7/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//
#import "CalendarDetailViewController.h"
#import "CalendarMasterViewController.h"
#import "UtilityMethods.h"
#import "MiniBrowserController.h"
#import "TexLegeAppDelegate.h"
#import "ChamberCalendarObj.h"
#import "TexLegeTheme.h"
#import "LocalyticsSession.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface CalendarDetailViewController (Private) 

- (void)selectSoonestEvent;
- (void)changeLayoutForOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)deviceOrientationDidChange:(void*)object;
	
@end

@implementation CalendarDetailViewController
@synthesize chamberCalendar, feedEntries;
@synthesize currentEvents, webView, searchResults;
@synthesize leftShadow, rightShadow, portShadow, landShadow;
@synthesize masterPopover;

- (id)dataObject {
	return self.chamberCalendar;
}

- (void)setDataObject:(id)newObj {
	[self setChamberCalendar:newObj];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if ([UtilityMethods isIPadDevice]) {
		UIImage *sealImage = [UIImage imageNamed:@"seal.png"];
		UIColor *sealColor = [UIColor colorWithPatternImage:sealImage];		
		self.view.backgroundColor = sealColor;
	}
	if (![UtilityMethods supportsEventKit])
		self.tableView.tableFooterView = nil;
	
		//self.navigationItem.title = @"Upcoming Committee Meetings";
	self.searchDisplayController.searchBar.tintColor = self.navigationController.navigationBar.tintColor;
	self.navigationItem.titleView = self.searchDisplayController.searchBar;

	self.currentEvents = [NSMutableArray array];
	self.searchResults = [NSMutableArray array];
	
	if ([UtilityMethods isIPadDevice])
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:@"UIApplicationDidChangeStatusBarOrientationNotification" object:nil];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if ([UtilityMethods isIPadDevice] && !self.chamberCalendar && ![UtilityMethods isLandscapeOrientation])  {
		TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
		
		self.chamberCalendar = [[appDelegate calendarMasterVC] selectObjectOnAppear];		
	}
	
	if ([UtilityMethods isIPadDevice])
		[self changeLayoutForOrientation:[UIApplication sharedApplication].statusBarOrientation];
	else 
		[self changeLayoutForOrientation:UIInterfaceOrientationPortrait];
		
	if (self.chamberCalendar)
		self.searchDisplayController.searchBar.placeholder = self.chamberCalendar.title;
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];	
	if (![self.currentEvents count] && self.feedEntries && [self.feedEntries count])	// we don't have anything selected yet
		[self selectSoonestEvent];
}

- (void)changeLayoutForOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (![UtilityMethods isIPadDevice]) {
		
		CGRect monthPortrait = CGRectMake(0, 0, 320, 265);
		CGRect tablePortrait = CGRectMake(0, 265, 320, 151);
		CGRect tableLandscape = CGRectMake(320.f, 0.f, 160.f, 268.f);
		//CGRect shadowLandscape = CGRectMake(143.f, 0.f, 198.f, 268.f);
		
		self.monthView.bounds = monthPortrait;
		
		if (UIDeviceOrientationIsLandscape(interfaceOrientation)) {
			self.tableView.frame = tableLandscape;
			self.landShadow.hidden = NO;
			self.portShadow.hidden = YES;
		}
		else {
			self.tableView.frame = tablePortrait;
			self.landShadow.hidden = YES;
			self.portShadow.hidden = NO;
		}	
		[self.tableView setNeedsDisplay];	
	}
}

// add this to init: or something
- (void)deviceOrientationDidChange:(void*)object { 
	UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	[self changeLayoutForOrientation:orientation];	
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if ([UtilityMethods isIPadDevice])
		return YES;
	else
		return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


- (void)didReceiveMemoryWarning {
	UINavigationController *nav = [self navigationController];
	//if (nav && [nav.viewControllers count]>1)
		[nav popToRootViewControllerAnimated:YES];
	
	self.leftShadow = self.rightShadow = self.portShadow = self.landShadow = nil;
	[self.currentEvents removeAllObjects];
	[self.searchResults removeAllObjects];
	
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    // Release any retained subviews of the main view.
	self.leftShadow = self.rightShadow = self.portShadow = self.landShadow = nil;
	self.chamberCalendar = nil;
	self.tableView = nil;		// this is okay, since we're not a decendent of UITableViewController
	self.webView = nil;
	self.feedEntries = nil;
	self.currentEvents = nil;
	self.searchResults = nil;
	self.masterPopover = nil;
	// add this to done: or something

	if ([UtilityMethods isIPadDevice])
		//[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIApplicationDidChangeStatusBarOrientationNotification" object:nil];

    [super viewDidUnload];
}


- (void)dealloc {
	self.chamberCalendar = nil;
	self.feedEntries = nil;
	self.currentEvents = nil;
	self.webView = nil;
	self.leftShadow = self.rightShadow = self.portShadow = self.landShadow = nil;
	self.searchResults = nil;
	self.tableView = nil;		// this is okay, since we're not a decendent of UITableViewController
	self.masterPopover = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Popover Support


- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
	//debug_NSLog(@"Entering portrait, showing the button: %@", [aViewController class]);
    barButtonItem.title = @"Meetings";
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
#pragma ComboVC Utilities
/*
 Sorts an array of CalendarItems objects by date.  
 */
NSComparisonResult sortByDate(id firstItem, id secondItem, void *context)
{
	NSDate *firstDate = [firstItem objectForKey:@"date"];
	NSDate *secondDate = [secondItem objectForKey:@"date"];
    
    /* Compare both date strings */
    NSComparisonResult comparison = [firstDate compare:secondDate];
	
	if (comparison == NSOrderedSame) {
		firstDate = [firstItem objectForKey:@"time"];
		secondDate = [secondItem objectForKey:@"time"];
		comparison = [firstDate compare:secondDate];
	}
	
    return comparison;
}

- (void)setChamberCalendar:(ChamberCalendarObj *)newObj {
	
	if (chamberCalendar) [chamberCalendar release], chamberCalendar = nil;
	if (newObj) {
		if (masterPopover)
			[masterPopover dismissPopoverAnimated:YES];

		chamberCalendar = [newObj retain];
		
		self.feedEntries = [[self.chamberCalendar feedEntries] sortedArrayUsingFunction:sortByDate context:nil];
		
		[self.searchResults removeAllObjects];
		[self.tableView reloadData];
		[self.monthView reload];
		[self selectSoonestEvent];
	}
}

- (void)selectSoonestEvent {	
	for (NSDictionary *entryDict in self.feedEntries) {
		NSDate *entryDate = [entryDict objectForKey:@"date"];
		if ([entryDate compare:[NSDate date]] != NSOrderedAscending) {  // don't select a date before today
			[self.monthView selectDate:[entryDict objectForKey:@"date"]];
			[self calendarMonthView:self.monthView didSelectDate:[entryDict objectForKey:@"date"]];
			return;
		}	
	}
}

#pragma mark -
#pragma mark EventKit
- (void)addEventToiCal:(NSDictionary *)eventDict parent:(id)parentController {
	
	if (!eventDict)
		return;
	
	if (![UtilityMethods supportsEventKit]) {
		debug_NSLog(@"EventKit not available on this device");
		return;
	}
	if (!parentController)
		parentController = [[TexLegeAppDelegate appDelegate] detailNavigationController];
	
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"iCAL_EVENT"];
	/* keys in our event dictionary:
	 fullDate (hopefully)
	 date
	 dateString
	 time
	 timeString
	 committee
	 chamber
	 location
	 url
	 */	
	
	NSDate *meetingDate = [eventDict objectForKey:@"fullDate"];
	if (!meetingDate) {
		debug_NSLog(@"Calendar Detail ... couldn't locate full meeting date");
		return;
	}
	NSString *chamberString = @""; 
	NSInteger chamber = [[eventDict objectForKey:@"chamber"] integerValue];
	if (chamber == HOUSE)
		chamberString = @"House";
	else if (chamber == SENATE)
		chamberString = @"Senate";
	else
		chamberString = @"Joint";
	
	NSString *committee = [eventDict objectForKey:@"committee"];	
	
	EKEventStore *eventStore = [[EKEventStore alloc] init];
	EKCalendar *defaultCalendar = [eventStore defaultCalendarForNewEvents];
	
	EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
    event.title     = [NSString stringWithFormat:@"%@ %@", chamberString, committee];
	event.location = [eventDict objectForKey:@"location"];
	event.notes = @"[TexLege] Length of this meeting is only an estimate.";
	
	
    event.startDate = meetingDate;
    event.endDate   = [NSDate dateWithTimeInterval:3600 sinceDate:event.startDate];
	
    [event setCalendar:defaultCalendar];
	
    NSError *err;
    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];     
	
	[eventStore release];
	
	EKEventViewController *eventVC = [[EKEventViewController alloc] initWithNibName:nil bundle:nil];			
	eventVC.event = event;
	
	// Allow event editing.
	eventVC.allowsEditing = YES;
	
	//	Push eventViewController onto the navigation controller stack
	//	If the underlying event gets deleted, detailViewController will remove itself from
	//	the stack and clear its event property.
	[parentController pushViewController:eventVC animated:YES];
	[eventVC release];
}	

#pragma -
#pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
	if (tv == self.searchDisplayController.searchResultsTableView) 
		return [self.searchResults count];
    else
		return [self.currentEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.numberOfLines = 2;
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    }
	
	NSDictionary *entry = nil;
	
	if (tv == self.searchDisplayController.searchResultsTableView)
		entry = [self.searchResults objectAtIndex:indexPath.row];		
	else
		entry = [self.currentEvents objectAtIndex:indexPath.row];
	
	NSString *chamberString = nil;
	switch ([[entry objectForKey:@"chamber"] integerValue]) {
		case JOINT:
			chamberString = @"(J)";
			break;
		case SENATE:
			chamberString = @"(S)";
			break;
		default:	//case HOUSE:
			chamberString = @"(H)";
			break;
	}
	NSString *committeeString = [[NSString alloc] initWithFormat:@"%@ %@", chamberString, [entry objectForKey:@"committee"]];
	NSString *cellText = nil;
	if (tv == self.searchDisplayController.searchResultsTableView) {  // give a different format in searches
		cellText = [[NSString alloc] initWithFormat:@"%@ - %@\n%@", [entry objectForKey:@"dateString"], [entry objectForKey:@"timeString"], 
					committeeString];
	}
	else {
		cellText = [[NSString alloc] initWithFormat:@"%@\nTime:%@ - Location: %@", committeeString, [entry objectForKey:@"timeString"], [entry objectForKey:@"location"]];

	}
	if ([UtilityMethods supportsEventKit])
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

	cell.textLabel.text = cellText;
	[committeeString release];
	[cellText release];
    return cell;
	
}

- (void)tableView:(UITableView *)tv accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *eventDict = nil;
	if (tv == self.searchDisplayController.searchResultsTableView)
		eventDict = [self.searchResults objectAtIndex:indexPath.row];
	else
		eventDict = [self.currentEvents objectAtIndex:indexPath.row];
	
	if (eventDict)
		[self addEventToiCal:eventDict parent:self.navigationController];	
}


- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *eventDict = nil;
	if (tv == self.searchDisplayController.searchResultsTableView) {
		eventDict = [self.searchResults objectAtIndex:indexPath.row];
		[self.searchDisplayController setActive:NO animated:YES];
		[self.monthView selectDate:[eventDict objectForKey:@"date"]];
		[self calendarMonthView:self.monthView didSelectDate:[eventDict objectForKey:@"date"]];
	}
	else {
		eventDict = [self.currentEvents objectAtIndex:indexPath.row];
		// add something to enable/disable the "addToiCal" button?
		
		NSURL *url = [NSURL URLWithString:[eventDict objectForKey:@"url"]];
		
		if ([UtilityMethods canReachHostWithURL:url]) { // do we have a good URL/connection?
			if ([UtilityMethods isIPadDevice]) {	
				NSURLRequest *urlReq = [NSURLRequest requestWithURL:url];
				if (urlReq)
					[self.webView loadRequest:urlReq];	
			}
			else {
				MiniBrowserController *mbc = [MiniBrowserController sharedBrowserWithURL:url];				
				[mbc display:self.tabBarController];
			}		
		}
	}
}

#pragma -
#pragma TKCalendarMonthViewDelegate

- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)d{	
	[self.currentEvents removeAllObjects];
	for (NSDictionary *entry in self.feedEntries) {
		//debug_NSLog(@"%@ compared to %@", d, [entry objectForKey:@"date"]);
		if ([[entry objectForKey:@"date"] isEqualToDate:d])
			[self.currentEvents addObject:entry];
	}
	[self.tableView reloadData];
	
	if ([self.currentEvents count] && [UtilityMethods isIPadDevice]) {
		NSIndexPath *selectionPath = [NSIndexPath indexPathForRow:0 inSection:0];
		[self.tableView selectRowAtIndexPath:selectionPath animated:NO scrollPosition:UITableViewScrollPositionTop];
		[self tableView:self.tableView didSelectRowAtIndexPath:selectionPath];
	}
}	

- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)endDate{
		
	NSMutableArray *matches = [NSMutableArray array];
	NSDate *d = startDate;
	
	while(YES){
		BOOL mark = NO;
		
		for (NSDictionary *entry in self.feedEntries) {
			if ([[entry objectForKey:@"date"] isEqualToDate:d]) {
				mark = YES;
				break;
			}
		}
		
		[matches addObject:[NSNumber numberWithBool:mark]];
		
		TKDateInformation info = [d dateInformation];
		info.day++;
		d = [NSDate dateFromDateInformation:info];
		if([d compare:endDate]==NSOrderedDescending) break;
	}
	
	return matches;
}


- (void) updateTableOffset{
	if ([UtilityMethods isIPadDevice]) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.4];
		
		float y =  monthView.frame.size.height;
		CGRect newSize = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, y);
		self.tableView.frame = newSize;
		
		newSize = CGRectMake(self.leftShadow.frame.origin.x, self.leftShadow.frame.origin.y, self.leftShadow.frame.size.width, y);
		self.leftShadow.frame = newSize;
		
		newSize = CGRectMake(self.rightShadow.frame.origin.x, self.rightShadow.frame.origin.y, self.rightShadow.frame.size.width, y);
		self.rightShadow.frame = newSize;
		
		[UIView commitAnimations];
	}
	else {
		if (![UtilityMethods isLandscapeOrientation])
			[super updateTableOffset];
	}
	return;				// normally this would move the tableView down as the monthView changes size
}

#pragma mark -
#pragma mark Search Results Delegate
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	[self.monthView setAlpha:0.4f];
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
		//[self.monthView selectDate:self.savedDateFromSearch];
	[self.monthView setAlpha:1.0f];
	
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	BOOL shouldReload = YES;
	
	[self.searchResults removeAllObjects];
	
	if (searchString) {
		for (NSDictionary *entry in self.feedEntries) {
			NSRange committeeRange = [[entry objectForKey:@"committee"] 
									  rangeOfString:searchString options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)];
			
			NSRange locationRange = [[entry objectForKey:@"location"] 
									  rangeOfString:searchString options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)];

			if (committeeRange.location != NSNotFound || locationRange.location != NSNotFound)
				[self.searchResults addObject:entry];
		}
			
	}
	
	return shouldReload;
}


@end
