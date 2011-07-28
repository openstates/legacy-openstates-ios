//
//  CalendarDataSource.m
//  Created by Gregory Combs on 7/27/10.
//  Copyright (c) 2010 Gregory S. Combs. All rights reserved.
//

#import "CalendarDataSource.h"
#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "ChamberCalendarObj.h"
#import "DisclosureQuartzView.h"
#import "CalendarEventsLoader.h"

@interface CalendarDataSource (Private)
- (void) loadCalendarMenuItems;
@end


@implementation CalendarDataSource
@synthesize calendarList;


- (NSString *)name 
{ return NSLocalizedStringFromTable(@"Events", @"StandardUI", @"The short title for buttons and tabs related to committee meetings (or calendar events)"); }

- (NSString *)navigationBarName 
{ return NSLocalizedStringFromTable(@"Upcoming Events", @"StandardUI", @"The long title for buttons and tabs related to committee meetings (or calendar events)"); }

- (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"83-calendar-inv.png"]; }

- (BOOL)showDisclosureIcon
{ return YES; }

- (BOOL)usesCoreData
{ return NO; }

- (BOOL)canEdit
{ return NO; }


// displayed in a plain style tableview
- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
}

- (id)init {
	if ((self = [super init])) {
		
		[self loadCalendarMenuItems];
		
	}
	return self;
}

- (void)dealloc {
	self.calendarList = nil;
	[super dealloc];
}


- (void) loadCalendarMenuItems {
	[[CalendarEventsLoader sharedCalendarEventsLoader] loadEvents:self];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	self.calendarList = [NSMutableArray array];
	
	// Right now we're only doing committee meetings
	
	NSString *localizedString = NSLocalizedStringFromTable(@"Upcoming Committee Meetings", @"DataTableUI", @"Menu item to display upcoming calendar events");
	NSMutableDictionary *calendarDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
										 localizedString, @"title",
										 kCalendarEventsTypeCommitteeValue, kCalendarEventsTypeKey,
										 nil];
	ChamberCalendarObj *calendar = [[ChamberCalendarObj alloc] initWithDictionary:calendarDict];
	[self.calendarList addObject:calendar];
	[calendar release];
	[calendarDict removeAllObjects];
	
	// Any other event types will go here
	// .....
	
	[calendarDict release];
	[pool drain];
	
}

- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
	return [self.calendarList objectAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForDataObject:(id)dataObject {
	
	NSInteger row = [self.calendarList indexOfObject:dataObject];
	if (row == NSNotFound)
		row = 0;
		
	return [NSIndexPath indexPathForRow:row inSection:0];
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{		
	static NSString *CellIdentifier = @"Cell";
	
	/* Look up cell in the table queue */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	/* Not found in queue, create a new cell object */
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.textColor =	[TexLegeTheme textDark];
		cell.textLabel.font = [TexLegeTheme boldFifteen];
		
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.textLabel.minimumFontSize = 12.0f;

		DisclosureQuartzView *qv = [[DisclosureQuartzView alloc] initWithFrame:CGRectMake(0.f, 0.f, 28.f, 28.f)];
		cell.accessoryView = qv;
		[qv release];
		
    }
	// configure cell contents

	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
		
	ChamberCalendarObj *calendar = [self dataObjectForIndexPath:indexPath];
	
	cell.textLabel.text = calendar.title;
		
	return cell;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{		
	return [self.calendarList count];
}



@end
