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
@synthesize chamberCalendar;
@synthesize webView;
@synthesize masterPopover;

- (NSString *)nibName {
	if ([UtilityMethods isIPadDevice])
		return @"CalendarDetailViewController~ipad";
	else
		return @"CalendarDetailViewController~iphone";	
}

- (id)dataObject {
	return self.chamberCalendar;
}

- (void)setDataObject:(id)newObj {
	[self setChamberCalendar:newObj];
}

- (void)finalizeUI {
	if ([UtilityMethods isIPadDevice]) {
		UIImage *sealImage = [UIImage imageNamed:@"seal.png"];
		UIColor *sealColor = [UIColor colorWithPatternImage:sealImage];		
		self.view.backgroundColor = sealColor;
	}
	//if (![UtilityMethods supportsEventKit])
	//	self.tableView.tableFooterView = nil;
	
	//self.navigationItem.title = @"Upcoming Committee Meetings";
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];
	self.searchDisplayController.searchBar.tintColor = [TexLegeTheme navbar];
	self.navigationItem.titleView = self.searchDisplayController.searchBar;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	if (!self.logic) {
		[[NSBundle mainBundle] loadNibNamed:[self nibName] owner:self options:nil];
	}
	
	[self finalizeUI];
}	

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self finalizeUI];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if ([UtilityMethods isIPadDevice] && !self.chamberCalendar && ![UtilityMethods isLandscapeOrientation])  {
		TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
		
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


- (void)didReceiveMemoryWarning {
	UINavigationController *nav = [self navigationController];
	//if (nav && [nav.viewControllers count]>1)
		[nav popToRootViewControllerAnimated:YES];
		
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


/*
 - (void)viewDidUnload {
    // Release any retained subviews of the main view.
	self.chamberCalendar = nil;
	if (![UtilityMethods isIPadDevice])
		self.webView = nil;
	self.masterPopover = nil;
	// add this to done: or something

    [super viewDidUnload];
}*/


- (void)dealloc {
	self.chamberCalendar = nil;
	self.webView = nil;
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

- (void)setChamberCalendar:(ChamberCalendarObj *)newObj {
	if (chamberCalendar && newObj && self.webView) {
		if (![[chamberCalendar valueForKey:@"title"] isEqualToString:[newObj valueForKey:@"title"]])
			[self.webView loadHTMLString:@"<html></html>" baseURL:nil];
	}
	
	if (chamberCalendar) [chamberCalendar release], chamberCalendar = nil;
	if (newObj) {
		if (masterPopover)
			[masterPopover dismissPopoverAnimated:YES];

		chamberCalendar = [newObj retain];
		
		[self view];

		[self setDelegate:self];
		[self setDataSource:chamberCalendar];
		[self.searchDisplayController setSearchResultsDataSource:chamberCalendar];
		
		//[newObj filterEventsByString:@""]; 

		[self reloadData];
//		[self.monthView reload];
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
	
	NSString *chamberString = stringForChamber([[eventDict objectForKey:@"chamber"] integerValue], TLReturnFull); 
	
	NSString *committee = [eventDict objectForKey:@"committee"];	
	
	EKEventStore *eventStore = [[EKEventStore alloc] init];
	EKCalendar *defaultCalendar = [eventStore defaultCalendarForNewEvents];
	
	EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
    event.title     = [NSString stringWithFormat:@"%@ %@", chamberString, committee];
	if ([eventDict objectForKey:@"cancelled"] && [[eventDict objectForKey:@"cancelled"] boolValue] == YES)
		event.title = [NSString stringWithFormat:@"%@ (CANCELLED)", event.title];
					   
	event.location = [eventDict objectForKey:@"location"];

	event.notes = @"[TexLege] Length of this meeting is only an estimate.";
	if ([eventDict objectForKey:@"url"] && [[eventDict objectForKey:@"url"] length]) {
		NSURL *url = [NSURL URLWithString:[eventDict objectForKey:@"url"]];
		if ([TexLegeReachability canReachHostWithURL:url alert:NO]) {
			NSError *error = nil;
			NSString *urlcontents = [NSString stringWithContentsOfURL:url encoding:NSWindowsCP1252StringEncoding error:&error];
			if (!error && urlcontents && [urlcontents length]) {
				NSString *flattened = [[urlcontents flattenHTML] stringByReplacingOccurrencesOfString:@"Schedule Display" withString:@""];
				flattened = [flattened stringByReplacingOccurrencesOfString:@"\r\n\r\n" withString:@"\r\n"];
				event.notes = flattened;
			}
		}
	}
	
	NSDate *meetingDate = [eventDict objectForKey:@"fullDate"];
	if (!meetingDate) {
		debug_NSLog(@"Calendar Detail ... couldn't locate full meeting date");
		event.allDay = YES; 
		if ([eventDict objectForKey:@"date"]) {
			event.startDate = [eventDict objectForKey:@"date"];
			event.endDate = [eventDict objectForKey:@"date"];
		}
		event.location = [eventDict objectForKey:@"rawDateTime"];
	}
	else {
		event.startDate = meetingDate;
		event.endDate   = [NSDate dateWithTimeInterval:3600 sinceDate:event.startDate];
	}
	
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


- (void)tableView:(UITableView *)tv accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *eventDict = [self.chamberCalendar eventForIndexPath:indexPath];
	if (eventDict)
		[self addEventToiCal:eventDict parent:self.navigationController];	
}


- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *eventDict = [self.chamberCalendar eventForIndexPath:indexPath];
	
	if (tv == self.searchDisplayController.searchResultsTableView) {
		[self.searchDisplayController setActive:NO animated:YES];
		[self showAndSelectDate:[eventDict objectForKey:@"date"]];
		
	}
		
	NSURL *url = [NSURL URLWithString:[eventDict objectForKey:@"url"]];
	
	if ([TexLegeReachability canReachHostWithURL:url]) { // do we have a good URL/connection?
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

#pragma mark -
#pragma mark Search Results Delegate

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	id gridView = [self.view valueForKey:@"gridView"];
	if (gridView && [gridView respondsToSelector:@selector(setAlpha:)])
		[gridView setAlpha:0.4f];
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	id gridView = [self.view valueForKey:@"gridView"];
	if (gridView && [gridView respondsToSelector:@selector(setAlpha:)])
		[gridView setAlpha:1.0f];
	
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	//NSArray *foundItems = 
		[self.chamberCalendar filterEventsByString:searchString];
	
	return YES; // or foundSomething?
}


@end
