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
#import "StatesLegeAppDelegate.h"
#import "CalendarEventsLoader.h"

@interface CalendarDataSource (Private)
- (void) loadChamberCalendars;
@end


@implementation CalendarDataSource
@synthesize calendarList;


- (NSString *)name 
{ return NSLocalizedStringFromTable(@"Meetings", @"StandardUI", @"The short title for buttons and tabs related to committee meetings (or calendar events)"); }

- (NSString *)navigationBarName 
{ return NSLocalizedStringFromTable(@"Upcoming Meetings", @"StandardUI", @"The long title for buttons and tabs related to committee meetings (or calendar events)"); }

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
		
		[self loadChamberCalendars];
		
	}
	return self;
}

- (void)dealloc {
	self.calendarList = nil;
	[super dealloc];
}


- (void) loadChamberCalendars {
	[[CalendarEventsLoader sharedCalendarEventsLoader] loadEvents:self];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	self.calendarList = [NSMutableArray arrayWithCapacity:4];
	
	/* ALL OR BOTH LEGISLATIVE CHAMBERS */
	NSInteger numberOfChambers = 4;	// All chambers, House only, Senate only, Joint committees
	NSInteger chamberIndex = BOTH_CHAMBERS;
	NSString *chamberName = stringForChamber(chamberIndex, TLReturnFull);
	
	NSString *localizedString = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ Upcoming Meetings", @"DataTableUI", @"Menu item to display upcoming calendar events in a legislative chamber"), 
					   chamberName];

	NSMutableDictionary *calendarDict = [[NSMutableDictionary alloc] initWithCapacity:10];
	ChamberCalendarObj *calendar = nil;
	[calendarDict setObject:localizedString forKey:@"title"];
	[calendarDict setObject:[NSNumber numberWithInteger:chamberIndex] forKey:@"chamber"];
	calendar = [[ChamberCalendarObj alloc] initWithDictionary:calendarDict];
	[self.calendarList addObject:calendar];
	[calendar release];
	[calendarDict removeAllObjects];

	for (chamberIndex=HOUSE; chamberIndex < numberOfChambers; chamberIndex++) {
		chamberName = stringForChamber(chamberIndex, TLReturnFull);
		localizedString = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Upcoming %@ Meetings", @"DataTableUI", @"Menu item to display upcoming calendar events in a legislative chamber"), 
						   chamberName];
		[calendarDict setObject:localizedString forKey:@"title"];
		[calendarDict setObject:[NSNumber numberWithInteger:chamberIndex] forKey:@"chamber"];
		calendar = [[ChamberCalendarObj alloc] initWithDictionary:calendarDict];
		[self.calendarList addObject:calendar];
		[calendar release];
		[calendarDict removeAllObjects];
	}
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
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
		
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
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
