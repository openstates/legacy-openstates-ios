//
//  CalendarComboViewController.m
//  TexLege
//
//  Created by Gregory Combs on 7/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//
#import "Constants.h"
#import "CalendarComboViewController.h"
//#import "CFeedEntry.h"
#import "UtilityMethods.h"

@implementation CalendarComboViewController
@synthesize popoverController, feedEntries, currentEvents;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIImage *sealImage = [UIImage imageNamed:@"seal.png"];
	UIColor *sealColor = [UIColor colorWithPatternImage:sealImage];		
	self.view.backgroundColor = sealColor;
	
	self.navigationItem.title = @"Upcoming Committee Meetings";
	
	self.currentEvents = [NSMutableArray array];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
	[[self navigationController] popToRootViewControllerAnimated:YES];

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.popoverController = nil;
	self.feedEntries = nil;
	self.currentEvents = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Popover Support

- (void)showMasterListPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    // Add the popover button to the left navigation item.
	barButtonItem.title = @"Meetings";
    [self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
}

- (void)invalidateMasterListPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    // Remove the popover button.
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc 
	 willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem 
	   forPopoverController: (UIPopoverController*)pc {
	
	[self showMasterListPopoverButtonItem:barButtonItem];
	
    self.popoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc 
	 willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	
	[self invalidateMasterListPopoverButtonItem:barButtonItem];
	self.popoverController = nil;
}

- (void) splitViewController:(UISplitViewController *)svc popoverController: (UIPopoverController *)pc
   willPresentViewController: (UIViewController *)aViewController
{
    if (pc != nil) {
        [pc dismissPopoverAnimated:YES];
		// do I need to set pc to nil?  I need to confirm, but I think it breaks things.
    }
}

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

- (void)setFeedEntries:(NSArray *)newObj {
	
	if (feedEntries) [feedEntries release], feedEntries = nil;
	if (newObj) {
		feedEntries = [[newObj sortedArrayUsingFunction:sortByDate context:nil] retain];
		
		if (popoverController != nil)
			[popoverController dismissPopoverAnimated:YES];
				
		[self.view setNeedsDisplay];
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.currentEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NSDictionary *entry = [self.currentEvents objectAtIndex:indexPath.row];
	
	NSString *chamberString = nil;
	switch ([[entry objectForKey:@"chamber"] integerValue]) {
		case HOUSE:
			chamberString = @"(H)";
			break;
		case SENATE:
			chamberString = @"(Sen)";
			break;
		case JOINT:
			chamberString = @"(Joint)";
			break;
		default:
			chamberString = @"";
			break;
	}
	cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", chamberString, [entry objectForKey:@"committee"]];;
	cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
	//cell.textLabel.textColor = [UIColor lightGrayColor];
	
	
    return cell;
	
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSDictionary *eventDict = [self.currentEvents objectAtIndex:indexPath.row];
	
	NSURL *url = [NSURL URLWithString:[eventDict objectForKey:@"url"]];
	if (url)
		[UtilityMethods openURLWithTrepidation:url];

}

- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)d{
	[self.currentEvents removeAllObjects];
	for (NSDictionary *entry in self.feedEntries) {
		//NSLog(@"%@ compared to %@", d, [entry objectForKey:@"date"]);
		if ([[entry objectForKey:@"date"] isEqualToDate:d])
			[self.currentEvents addObject:entry];
	}
	[self.tableView reloadData];
	self.calendarDayTimelineView.currentDay = d;
	[self.calendarDayTimelineView reloadDay];
}	

- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)endDate{
		
	NSMutableArray *matches = [NSMutableArray array];
	NSDate *d = startDate;
	
	while(YES){
		BOOL mark = NO;
		
		for (NSDictionary *entry in self.feedEntries) {
			if ([[entry objectForKey:@"date"] isEqualToDate:d]) {
				mark = YES;
				continue;
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


#pragma mark -
#pragma mark ODCalendarDayTimelineViewDelegate

#pragma mark -
#pragma mark Calendar Day Timeline View delegate

- (NSArray *)calendarDayTimelineView:(ODCalendarDayTimelineView*)calendarDayTimeline eventsForDate:(NSDate *)eventDate
{
	NSMutableArray *odEvents = [NSMutableArray arrayWithCapacity:[self.currentEvents count]];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLenient:YES];
	[dateFormatter setDateFormat:@"M/d/yyyy h:mm a"];
	
	for (NSDictionary *eventDict in self.currentEvents) {
		
		NSString *eventDateString = [NSString stringWithFormat:@"%@ %@", [eventDict objectForKey:@"dateString"], [eventDict objectForKey:@"timeString"]];
		NSDate *eventDate = [dateFormatter dateFromString:eventDateString];

		
		ODCalendarDayEventView *eventView = [ODCalendarDayEventView eventViewWithFrame:CGRectZero
																					 id:nil 
																				  //startDate:[eventDict objectForKey:@"time"]
																					//endDate:[[eventDict objectForKey:@"time"] addTimeInterval:60 * 60 * 24]
																			 startDate:eventDate 
																			   endDate:[eventDate addTimeInterval:60 * 60 * 1]
																			  //startDate:[[NSDate date]addTimeInterval:60 * 60 * 2] 
																			  //endDate:[[NSDate date]addTimeInterval:60 * 60 * 24]
																				  title:[eventDict objectForKey:@"committee"]
																			   location:[NSString stringWithFormat:@"Location: %@ - (Approx. length)",[eventDict objectForKey:@"location"]]];
		[odEvents addObject:eventView];
	}
	[dateFormatter release];
	
	return odEvents;
}

- (void)calendarDayTimelineView:(ODCalendarDayTimelineView*)calendarDayTimeline eventViewWasSelected:(ODCalendarDayEventView *)eventView
{
	NSLog(@"CalendarDayTimelineView: EventViewWasSelected");
}


@end
