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

@implementation CalendarDataSource
@synthesize managedObjectContext;
@synthesize calendarList;


- (NSString *)navigationBarName
{ return @"Committee Meetings"; }

- (NSString *)name
{ return @"Meetings"; }

- (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"83-calendar.png"]; }

- (BOOL)showDisclosureIcon
{ return YES; }

- (BOOL)usesCoreData
{ return NO; }

- (BOOL)usesToolbar
{ return NO; }

- (BOOL)usesSearchbar
{ return NO; }

- (BOOL)canEdit
{ return NO; }

- (CGFloat) rowHeight {	
	return 44.0f;
}


// displayed in a plain style tableview
- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
}

- (id)init {
	self = [super init];
	if (self !=nil) {
		/* Build a list of files */		
		self.calendarList = [NSArray arrayWithObjects:
							 @"All Committee Meetings", @"House Committee Meetings", 
							 @"Senate Committee Meetings", @"Joint Committee Meetings", nil];		
	}
	return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext {
	if ([self init])
		if (newContext) self.managedObjectContext = newContext;
	return self;
}


// Returns an array of the appropriate feed entries (CFeedEntry)...
- (NSArray *)feedEntriesForIndexPath:(NSIndexPath *)indexPath {	
	NSArray *feedURLs = nil;
	
	if (![UtilityMethods isNetworkReachable]) {
		[UtilityMethods noInternetAlert];
		return nil;
	}
	
	const NSURL *senateURL = [NSURL URLWithString:@"http://www.capitol.state.tx.us/MyTLO/RSS/RSS.aspx?Type=upcomingmeetingssenate"];
	const NSURL *houseURL = [NSURL URLWithString:@"http://www.capitol.state.tx.us/MyTLO/RSS/RSS.aspx?Type=upcomingmeetingshouse"];
	const NSURL *jointURL = [NSURL URLWithString:@"http://www.capitol.state.tx.us/MyTLO/RSS/RSS.aspx?Type=upcomingmeetingsjoint"];
	NSMutableArray *entryArray = [NSMutableArray array];
	NSNumber *chamberType = [NSNumber numberWithInteger:indexPath.row];		// save this for later
	
	switch (indexPath.row) {
		case JOINT:
			feedURLs = [[NSArray alloc] initWithObjects:jointURL,nil];
			break;
		case HOUSE:
			feedURLs = [[NSArray alloc] initWithObjects:houseURL,nil];
			break;
		case SENATE:
			feedURLs = [[NSArray alloc] initWithObjects:senateURL,nil];
			break;
		default:	// "BOTH" ... but really this means all (0)
			feedURLs = [[NSArray alloc] initWithObjects:houseURL,senateURL,jointURL,nil];
			break;
	}
	
	if ([UtilityMethods canReachHostWithURL:[feedURLs objectAtIndex:0]]) {		// I think just doing it once is enough?
		NSError *theError = NULL;
		CFeedStore * feedStore = [CFeedStore instance];
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLenient:YES];
		[dateFormatter setDateFormat:@"M/d/yyyy"];
		NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
		[timeFormatter setLenient:YES];
		[timeFormatter setDateFormat:@"h:mm a"];
		
		NSInteger index = 1;
		for (NSURL *url in feedURLs) {
			[feedStore.feedFetcher subscribeToURL:url error:&theError];
			CFeed * theFeed = [feedStore feedForURL:url fetch:YES];
			
			for (CFeedEntry *entry in theFeed.entries) {
				if (indexPath.row == BOTH_CHAMBERS) /// this is when we've got mutliple feeds, must be "all", educate it
					chamberType = [NSNumber numberWithInteger:index];
				
				NSMutableDictionary *entryDict = [[NSMutableDictionary alloc] initWithCapacity:15];
				[entryDict setObject:chamberType forKey:@"chamber"];
				
				NSArray *components = [entry.title componentsSeparatedByString:@" - "];
				if (components && ([components count] >= 2)) {
					[entryDict setObject:[components objectAtIndex:0] forKey:@"committee"];
					
					NSDate *refDate = [dateFormatter dateFromString:[components objectAtIndex:1]];
					if (refDate)
						[entryDict setObject:refDate forKey:@"date"];
					
					if ([components objectAtIndex:1])
						[entryDict setObject:[components objectAtIndex:1] forKey:@"dateString"];
				}
				
				if (entry.link)
					[entryDict setObject:entry.link forKey:@"url"];
			
				NSString *searchString = entry.content;
				if (searchString) {
					
					// Catches:			"Time: 8:00 AM  (Canceled), Location: North Texas Tollway Authority Headquarters, Plano"
					//   also:			"Time: 9:00 AM, Location: Senate Chamber"
					static NSString *regexString = @"Time:\\s+([0-9]+:[0-9]+\\s+[AP]M)(\\s+\\(Cance[l]+ed\\))?,\\s+Location:\\s+(.+)$";
					
					if([searchString isMatchedByRegex:regexString]) {
						NSString *timeString = [searchString stringByMatching:regexString capture:1L];
						if (timeString) {
							[entryDict setObject:[timeFormatter dateFromString:timeString] forKey:@"time"];
							[entryDict setObject:timeString forKey:@"timeString"];
						}
						
						NSString *cancelledStr   = [searchString stringByMatching:regexString capture:2L];
						[entryDict setObject:[NSNumber numberWithBool:(cancelledStr != nil)] forKey:@"cancelled"];

						NSString *location   = [searchString stringByMatching:regexString capture:3L];
						if (location)
							[entryDict setObject:location forKey:@"location"];
					}
				}
				
				[entryArray addObject:entryDict];
				[entryDict release];
			 }	
			index++;
		}	
		[dateFormatter release];
		[timeFormatter release];

	}
	[feedURLs release];

	return entryArray;
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{		
	static NSString *CellIdentifier = @"Cell";
	NSInteger row = indexPath.row;
	
	/* Look up cell in the table queue */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	/* Not found in queue, create a new cell object */
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// configure cell contents
	if ([self showDisclosureIcon])
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = [self.calendarList objectAtIndex:row];
	cell.textLabel.textAlignment = UITextAlignmentLeft;
	cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
	
	return cell;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{		
	return [self.calendarList count];
}

- (void)dealloc {
	
	self.calendarList = nil;
	self.managedObjectContext = nil;
	[super dealloc];
}


@end
