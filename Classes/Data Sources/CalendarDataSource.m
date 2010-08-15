//
//  CalendarDataSource.m
//  TexLege
//
//  Created by Gregory Combs on 7/27/10.
//  Copyright (c) 2010 University of Texas at Dallas. All rights reserved.
//

#import "CalendarDataSource.h"
#import "CFeedStore.h"
#import "CFeedFetcher.h"
#import "CFeedEntry.h"
#import "CFeed.h"
#import "UtilityMethods.h"
#import "RegexKitLite.h"
#import "TexLegeTheme.h"
#import "ChamberCalendarObj.h"

@interface CalendarDataSource (Private)
- (void) subscribeToAllFeeds;
- (void) loadChamberCalendars;
@end


@implementation CalendarDataSource
@synthesize managedObjectContext;
@synthesize calendarList, senateURL, houseURL, jointURL, feedStore;


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

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext {
	if (self = [super init]) {
		if (newContext)
			self.managedObjectContext = newContext;
		
		self.feedStore = [CFeedStore instance];
		[self loadChamberCalendars];
		[self subscribeToAllFeeds];
		
	}
	return self;
}

- (void) loadChamberCalendars {
	static NSString *senateURLString = @"http://www.capitol.state.tx.us/MyTLO/RSS/RSS.aspx?Type=upcomingmeetingssenate";
	static NSString *houseURLString = @"http://www.capitol.state.tx.us/MyTLO/RSS/RSS.aspx?Type=upcomingmeetingshouse";
	static NSString *jointURLString = @"http://www.capitol.state.tx.us/MyTLO/RSS/RSS.aspx?Type=upcomingmeetingsjoint";
	
	self.senateURL = [NSURL URLWithString:senateURLString];
	self.houseURL = [NSURL URLWithString:houseURLString];
	self.jointURL = [NSURL URLWithString:jointURLString];
	
	self.calendarList = [NSMutableArray arrayWithCapacity:4];
	
	
	NSMutableArray *feedURLS = [[NSMutableArray alloc] initWithObjects:self.houseURL,self.senateURL,self.jointURL,nil];
	NSMutableDictionary *calendarDict = [[NSMutableDictionary alloc] initWithCapacity:3];
	ChamberCalendarObj *calendar = nil;
	
	[calendarDict setObject:@"All Upcoming Meetings" forKey:@"title"];
	[calendarDict setObject:feedURLS forKey:@"feedURLS"];
	[calendarDict setObject:[NSNumber numberWithInteger:BOTH_CHAMBERS] forKey:@"chamber"];
	[calendarDict setObject:self.feedStore forKey:@"feedStore"];
	calendar = [[ChamberCalendarObj alloc] initWithDictionary:calendarDict];
	[self.calendarList addObject:calendar];
	[calendar release];
	[calendarDict removeAllObjects];
	[feedURLS removeAllObjects];
	
	
	[feedURLS addObject:self.houseURL];
	[calendarDict setObject:@"Upcoming House Meetings" forKey:@"title"];
	[calendarDict setObject:feedURLS forKey:@"feedURLS"];
	[calendarDict setObject:[NSNumber numberWithInteger:HOUSE] forKey:@"chamber"];
	[calendarDict setObject:self.feedStore forKey:@"feedStore"];
	calendar = [[ChamberCalendarObj alloc] initWithDictionary:calendarDict];
	[self.calendarList addObject:calendar];
	[calendar release];
	[calendarDict removeAllObjects];
	[feedURLS removeAllObjects];
	
	
	[feedURLS addObject:self.senateURL];
	[calendarDict setObject:@"Upcoming Senate Meetings" forKey:@"title"];
	[calendarDict setObject:feedURLS forKey:@"feedURLS"];
	[calendarDict setObject:[NSNumber numberWithInteger:SENATE] forKey:@"chamber"];
	[calendarDict setObject:self.feedStore forKey:@"feedStore"];
	calendar = [[ChamberCalendarObj alloc] initWithDictionary:calendarDict];
	[self.calendarList addObject:calendar];
	[calendar release];
	[calendarDict removeAllObjects];
	[feedURLS removeAllObjects];
	
	   
	[feedURLS addObject:self.jointURL];
	[calendarDict setObject:@"Upcoming Joint Meetings" forKey:@"title"];
	[calendarDict setObject:feedURLS forKey:@"feedURLS"];
	[calendarDict setObject:[NSNumber numberWithInteger:JOINT] forKey:@"chamber"];
	[calendarDict setObject:self.feedStore forKey:@"feedStore"];
	calendar = [[ChamberCalendarObj alloc] initWithDictionary:calendarDict];
	[self.calendarList addObject:calendar];
	[calendar release];
	[calendarDict release];
	[feedURLS release];
	
}

- (void) subscribeToAllFeeds {
	
	NSError *theError = NULL;
	
	@try {
		NSArray *feedURLs = [[self.calendarList objectAtIndex:BOTH_CHAMBERS] valueForKey:@"feedURLS"];

		debug_NSLog(@"Beginning feed subscriptions - %@", [NSDate date]);
		
		for (NSURL *url in feedURLs) {
			[self.feedStore.feedFetcher subscribeToURL:url error:&theError];
		}			
		debug_NSLog(@"Ended feed subscriptions -- %@", [NSDate date]);
	}
	@catch (NSException * e) {
		debug_NSLog(@"Error when initializing calendar feed subscriptions:\n  %@\n   %@", [theError description], [e description]);
	}
}

// Returns an array of the appropriate feed entries (CFeedEntry)...
- (NSArray *)feedEntriesForIndexPath:(NSIndexPath *)indexPath {	
	if (!indexPath || !self.calendarList)
		return nil;
	
	ChamberCalendarObj *calendar = [self.calendarList objectAtIndex:indexPath.row];
	if (calendar)
		return [calendar feedEntries];
	
	return nil;
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
		cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]] autorelease];
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

- (void)dealloc {
	self.senateURL = self.houseURL = self.jointURL = nil;
	self.feedStore = nil;

	self.calendarList = nil;
	self.managedObjectContext = nil;
	[super dealloc];
}


@end
