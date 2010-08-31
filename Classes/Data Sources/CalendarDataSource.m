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
#import "TexLegeTheme.h"
#import "ChamberCalendarObj.h"
#import "DisclosureQuartzView.h"

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
	
	
	NSMutableDictionary *calendarDict = [[NSMutableDictionary alloc] initWithCapacity:10];
	ChamberCalendarObj *calendar = nil;
	
	[calendarDict setObject:@"All Upcoming Meetings" forKey:@"title"];
	[calendarDict setObject:[NSArray arrayWithObjects:self.houseURL, self.senateURL, self.jointURL, nil] forKey:@"feedURLS"];
	[calendarDict setObject:[NSNumber numberWithInteger:BOTH_CHAMBERS] forKey:@"chamber"];
	[calendarDict setObject:self.feedStore forKey:@"feedStore"];
	calendar = [[ChamberCalendarObj alloc] initWithDictionary:calendarDict];
	[self.calendarList addObject:calendar];
	[calendar release];
	[calendarDict removeAllObjects];
	
	
	[calendarDict setObject:@"Upcoming House Meetings" forKey:@"title"];
	[calendarDict setObject:[NSArray arrayWithObject:self.houseURL]  forKey:@"feedURLS"];
	[calendarDict setObject:[NSNumber numberWithInteger:HOUSE] forKey:@"chamber"];
	[calendarDict setObject:self.feedStore forKey:@"feedStore"];
	calendar = [[ChamberCalendarObj alloc] initWithDictionary:calendarDict];
	[self.calendarList addObject:calendar];
	[calendar release];
	[calendarDict removeAllObjects];
	
	
	[calendarDict setObject:@"Upcoming Senate Meetings" forKey:@"title"];
	[calendarDict setObject:[NSArray arrayWithObject:self.senateURL] forKey:@"feedURLS"];
	[calendarDict setObject:[NSNumber numberWithInteger:SENATE] forKey:@"chamber"];
	[calendarDict setObject:self.feedStore forKey:@"feedStore"];
	calendar = [[ChamberCalendarObj alloc] initWithDictionary:calendarDict];
	[self.calendarList addObject:calendar];
	[calendar release];
	[calendarDict removeAllObjects];
	
	   
	[calendarDict setObject:@"Upcoming Joint Meetings" forKey:@"title"];
	[calendarDict setObject:[NSArray arrayWithObject:self.jointURL] forKey:@"feedURLS"];
	[calendarDict setObject:[NSNumber numberWithInteger:JOINT] forKey:@"chamber"];
	[calendarDict setObject:self.feedStore forKey:@"feedStore"];
	calendar = [[ChamberCalendarObj alloc] initWithDictionary:calendarDict];
	[self.calendarList addObject:calendar];
	[calendar release];
	[calendarDict release];
	
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
		DisclosureQuartzView *qv = [[DisclosureQuartzView alloc] initWithFrame:CGRectMake(0.f, 0.f, 25.f, 25.f)];
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

- (void)dealloc {
	self.senateURL = self.houseURL = self.jointURL = nil;
	self.feedStore = nil;

	self.calendarList = nil;
	self.managedObjectContext = nil;
	[super dealloc];
}


@end
