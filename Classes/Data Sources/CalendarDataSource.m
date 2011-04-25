//
//  CalendarDataSource.m
//  TexLege
//
//  Created by Gregory Combs on 7/27/10.
//  Copyright (c) 2010 Gregory S. Combs. All rights reserved.
//

#import "CalendarDataSource.h"
#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "ChamberCalendarObj.h"
#import "DisclosureQuartzView.h"
#import "TexLegeAppDelegate.h"
#import "CalendarEventsLoader.h"

@interface CalendarDataSource (Private)
- (void) loadChamberCalendars;
@end


@implementation CalendarDataSource
@synthesize calendarList;


- (NSString *)navigationBarName
{ return @"Upcoming Meetings"; }

- (NSString *)name
{ return @"Meetings"; }

- (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"83-calendar.png"]; }

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

- (NSManagedObjectContext *)managedObjectContext {
	return nil;
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
	
	NSMutableDictionary *calendarDict = [[NSMutableDictionary alloc] initWithCapacity:10];
	ChamberCalendarObj *calendar = nil;
	[calendarDict setObject:@"All Upcoming Meetings" forKey:@"title"];
	[calendarDict setObject:[NSNumber numberWithInteger:BOTH_CHAMBERS] forKey:@"chamber"];
	calendar = [[ChamberCalendarObj alloc] initWithDictionary:calendarDict];
	[self.calendarList addObject:calendar];
	[calendar release];
	[calendarDict removeAllObjects];
	
	
	[calendarDict setObject:@"Upcoming House Meetings" forKey:@"title"];
	[calendarDict setObject:[NSNumber numberWithInteger:HOUSE] forKey:@"chamber"];
	calendar = [[ChamberCalendarObj alloc] initWithDictionary:calendarDict];
	[self.calendarList addObject:calendar];
	[calendar release];
	[calendarDict removeAllObjects];
	
	
	[calendarDict setObject:@"Upcoming Senate Meetings" forKey:@"title"];
	[calendarDict setObject:[NSNumber numberWithInteger:SENATE] forKey:@"chamber"];
	calendar = [[ChamberCalendarObj alloc] initWithDictionary:calendarDict];
	[self.calendarList addObject:calendar];
	[calendar release];
	[calendarDict removeAllObjects];
	
	   
	[calendarDict setObject:@"Upcoming Joint Meetings" forKey:@"title"];
	[calendarDict setObject:[NSNumber numberWithInteger:JOINT] forKey:@"chamber"];
	calendar = [[ChamberCalendarObj alloc] initWithDictionary:calendarDict];
	[self.calendarList addObject:calendar];
	[calendar release];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.textColor =	[TexLegeTheme textDark];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
		
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.textLabel.minimumFontSize = 12.0f;
		//cell.accessoryView = [TexLegeTheme disclosureLabel:YES];
		//cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]] autorelease];
		DisclosureQuartzView *qv = [[DisclosureQuartzView alloc] initWithFrame:CGRectMake(0.f, 0.f, 28.f, 28.f)];
		//UIImageView *iv = [[UIImageView alloc] initWithImage:[qv imageFromUIView]];
		cell.accessoryView = qv;
		[qv release];
		//[iv release];
		
    }
	// configure cell contents

	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	
	//if ([self showDisclosureIcon])
	//	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	ChamberCalendarObj *calendar = [self dataObjectForIndexPath:indexPath];
	
	cell.textLabel.text = calendar.title;
		
	return cell;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{		
	return [self.calendarList count];
}



@end
