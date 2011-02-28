//
//  ChamberCalendarObj.m
//  TexLege
//
//  Created by Gregory Combs on 8/12/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "ChamberCalendarObj.h"
#import "UtilityMethods.h"
#import "CFeedFetcher.h"
#import "CFeedEntry.h"
#import "CFeed.h"
#import "NSDate+TKCategory.h"

static BOOL IsDateBetweenInclusive(NSDate *date, NSDate *begin, NSDate *end)
{
	return [date compare:begin] != NSOrderedAscending && [date compare:end] != NSOrderedDescending;
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

@interface ChamberCalendarObj (Private)
- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate;
- (NSDictionary *)parseFeedEntry:(CFeedEntry*)entry forChamber:(NSNumber*)entryChamber;
- (void)fetchEvents;
@end

@implementation ChamberCalendarObj

@synthesize title, chamber, feedURLS, feedStore;

- (id)initWithDictionary:(NSDictionary *)calendarDict {
	if (self = [super init]) {
		self.title = [calendarDict valueForKey:@"title"];
		self.chamber = [calendarDict valueForKey:@"chamber"];
		self.feedURLS = [calendarDict valueForKey:@"feedURLS"];
		self.feedStore = [calendarDict valueForKey:@"feedStore"];
		rows = [[NSMutableArray alloc] init];
		events = [[NSMutableArray alloc] init];
		hasPostedAlert = NO;
	}
	return self;
}

- (void)dealloc {
	
	self.title = nil;
	self.chamber = nil;
	self.feedURLS = nil;
	self.feedStore = nil;
	[rows release];
	[events release];

    [super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"title: %@ - chamber: %@ - feedURLS: %@ - feedStore: %@", 
			self.title, self.chamber, self.feedURLS, self.feedStore];
}

- (NSDictionary *) eventForIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *event = nil;
	@try {
		event = [rows objectAtIndex:indexPath.row];
	}
	@catch (NSException * e) {
		event = nil;
	}
	return event;	
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *identifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
		cell.textLabel.numberOfLines = 2;
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
	}
	
	NSDictionary *event = [self eventForIndexPath:indexPath];
	
	NSString *chamberString = stringForChamber([[event objectForKey:@"chamber"] integerValue], TLReturnInitial);
	NSString *committeeString = [NSString stringWithFormat:@"%@ %@", chamberString, [event objectForKey:@"committee"]];

	/*
	 if ([self.filterString length])
		cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@\n%@", 
					[event objectForKey:@"dateString"], [event objectForKey:@"timeString"], committeeString];
	else */
	
	NSString *timeLocation = nil;
	if ([event objectForKey:@"time"])
		timeLocation = [NSString stringWithFormat:@"Time:%@ - Location: %@",[event objectForKey:@"timeString"], [event objectForKey:@"location"]];
	else
		timeLocation = [event objectForKey:@"rawDateTime"];

	cell.textLabel.text = [NSString stringWithFormat:@"%@\n %@", committeeString, timeLocation];
	
	
	if ([[event objectForKey:@"cancelled"] boolValue] == YES)
		cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@" (Cancelled)"];
	
	
	if ([UtilityMethods supportsEventKit])
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [rows count];
}

#pragma mark -
#pragma mark Data Storage

- (NSDictionary *)parseFeedEntry:(CFeedEntry*)entry forChamber:(NSNumber*)entryChamber {
	NSMutableDictionary *entryDict = [NSMutableDictionary dictionary];
	[entryDict setObject:entryChamber forKey:@"chamber"];
	
	@try {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLenient:YES];
		
		NSArray *components = [entry.title componentsSeparatedByString:@" - "];
		if (components && ([components count] >= 2)) {
			[entryDict setObject:[components objectAtIndex:0] forKey:@"committee"];
			
			[dateFormatter setDateFormat:@"M/d/yyyy"];
			NSDate *refDate = [dateFormatter dateFromString:[components lastObject]];
			if (refDate)
				[entryDict setObject:refDate forKey:@"date"];
			
			if ([components lastObject])
				[entryDict setObject:[components lastObject] forKey:@"dateString"];
		}
		
		if (entry.link)
			[entryDict setObject:entry.link forKey:@"url"];
		
		NSString *searchString = entry.content;
		if (searchString) {
			
			// Catches:			"Time: 8:00 AM  (Canceled), Location: North Texas Tollway Authority Headquarters, Plano"
			//   also:			"Time: 9:00 AM, Location: Senate Chamber"				
			
			//static NSRange kRangeNotFound = {NSNotFound, 0};
			
			// Set whether it's cancelled/canceled(!)
			NSRange cancelRange = [searchString rangeOfString:@" (Canceled),"];
			if (cancelRange.length == 0)
				cancelRange = [searchString rangeOfString:@" (Cancelled),"];
			[entryDict setObject:[NSNumber numberWithBool:(cancelRange.length > 0)] forKey:@"cancelled"];
			
			// Time
			NSRange timeRange = [searchString rangeOfString:@"Time: "];
			NSRange placeRange = [searchString rangeOfString:@" Location: "];
			if ( timeRange.length <= 0 )
				debug_NSLog(@"Unexpected content in schedule parsing ... expected 'Time:[...]', got: %@", searchString);
			else {
				NSInteger start = timeRange.location + timeRange.length;
				NSInteger end = 0;
				if (cancelRange.location != NSNotFound && cancelRange.location > 0)
					end = cancelRange.location-1;
				else if (placeRange.location != NSNotFound && placeRange.location > 0)
					end = placeRange.location-1;
				
				if (start < end) {
					timeRange = NSMakeRange(start, end-start);
					NSString *timeString = [searchString substringWithRange:timeRange];
					if (timeString) {						
						if ([timeString length] > 8)	// assholes
							timeString = [timeString substringToIndex:8];
						
						[dateFormatter setDateFormat:@"h:mm a"];	
						NSDate *tempTime = [dateFormatter dateFromString:timeString];
						if (tempTime)
							[entryDict setObject:tempTime forKey:@"time"];
						[entryDict setObject:timeString forKey:@"timeString"];
						
						// fullDate = (date + time) ... if possible
						NSString *gotDate = [entryDict objectForKey:@"dateString"];
						if (timeString && gotDate) {
							NSString *fullString = [NSString stringWithFormat:@"%@ %@", gotDate, timeString];
							
							[dateFormatter setDateFormat:@"M/d/yyyy h:mm a"];
							NSDate *fullDate = [dateFormatter dateFromString:fullString];
							if (fullDate) {
								[entryDict setObject:fullDate forKey:@"fullDate"];
							}
							else
								debug_NSLog(@"Trouble parsing full date from %@", fullString);						
						}
					}
				}	
				
				[entryDict setObject:searchString forKey:@"rawDateTime"];
			}
			
			// Location
			if ( placeRange.length <= 0 )
				debug_NSLog(@"Unexpected content in schedule parsing ... expected 'Location:[...]', got: %@", searchString);
			else {
				NSInteger start = placeRange.location + placeRange.length;
				NSInteger end = [searchString length];
				if (start < end) {
					placeRange = NSMakeRange(start, end-start);
					NSString *placeString = [searchString substringWithRange:placeRange];
					if (placeString)
						[entryDict setObject:placeString forKey:@"location"];
				}					
			}
		}
		
		[dateFormatter release];		
	}
	@catch (NSException * e) {
		NSLog(@"Error parsing event entry: %@", entry.content);
	}
	
	return entryDict;
}

- (void)fetchEvents {
	
	// We should start looking into openstates' Event API:
	// http://openstates.sunlightlabs.com/api/v1/events/?state=tx&type=committee:meeting&apikey=350284d0c6af453b9b56f6c1c7fea1f9
	
	if (![TexLegeReachability canReachHostWithURL:[self.feedURLS objectAtIndex:0]])		// I think just doing it once is enough?
		return;
	if (!self.feedStore)
		return;
	
	[events removeAllObjects];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSMutableArray *noMeetingsList = [NSMutableArray arrayWithCapacity:4];
									  
	NSInteger index = 1;
	for (NSURL *url in self.feedURLS) {
		CFeed * theFeed = [self.feedStore feedForURL:url fetch:YES];
		if (!theFeed) {
			NSLog(@"ChamberCalendarObj-feedEntries: error obtaining the necessary feed for the url:%@", url);
			continue;
		}
		for (CFeedEntry *entry in theFeed.entries) {
			NSNumber *entryChamber = self.chamber;
			if ([self.chamber integerValue] == BOTH_CHAMBERS) /// this is when we've got mutliple feeds, must be "all", educate it
				entryChamber = [NSNumber numberWithInteger:index];
			
			if ([entry.title isEqualToString:@"No committee meetings scheduled."]) {				
				[noMeetingsList addObject:stringForChamber([entryChamber integerValue], TLReturnFull)];
				break;
			}
			NSDictionary *entryDict = [self parseFeedEntry:entry forChamber:entryChamber];
			if (entryDict)
				[events addObject:entryDict];
		}	
		index++;
	}
									  
	// At least one of our calendar feeds was empty (no meetings)
	if (!hasPostedAlert && [noMeetingsList count]) {
		NSString *titleString = nil;
		NSString *messageString = nil;
		
		if ([noMeetingsList count] > 1) {
			NSMutableString *chamberList = [NSMutableString string];
			NSInteger index = 1;
			for (NSString *chamberName in noMeetingsList) {
				if (index > 1) {
					if ([noMeetingsList count] > 2)
						[chamberList appendString:@", "];
					else
						[chamberList appendString:@" "];
				}
				if (index == [noMeetingsList count]) {
					[chamberList appendString:@"or "];
				}
				[chamberList appendString:chamberName];
				index++;
			}
			titleString = [NSString stringWithFormat:@"No meetings scheduled.", chamberList];
			messageString = [NSString stringWithFormat:@"Currently, there are no %@ meetings scheduled.", chamberList];
			
		}
		else {
			NSString *chamberName = [noMeetingsList objectAtIndex:0];
			titleString = [NSString stringWithFormat:@"No %@ meetings scheduled.", chamberName];
			messageString = [NSString stringWithFormat:@"Currently, there are no %@ meetings scheduled.", chamberName];
		}

		UIAlertView *noMeetingsAlert = [[[ UIAlertView alloc ] 
										 initWithTitle:titleString 
										 message:messageString 
										 delegate:nil // we're static, so don't do "self"
										 cancelButtonTitle: @"Cancel" 
										 otherButtonTitles:nil, nil] autorelease];
		hasPostedAlert = YES;
		[ noMeetingsAlert show ];		
	}
	
	if (events && [events count]) {
		[events sortUsingFunction:sortByDate context:nil];
	}
	[pool drain];
}

- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
	NSMutableArray *matches = [NSMutableArray array];
	for (NSDictionary *event in events) {
		
		if (IsDateBetweenInclusive([event objectForKey:@"date"], fromDate, toDate))
			[matches addObject:event];
	}
	
	return matches;
}

#pragma mark KalDataSource protocol conformance

/*    presentingDatesFrom:to:delegate:
 *  
 *        This message will be sent to your dataSource whenever the calendar
 *        switches to a different month. Your code should respond by
 *        loading application data for the specified range of dates and sending the
 *        loadedDataSource: callback message as soon as the appplication data
 *        is ready and available in memory. If the lookup of your application
 *        data is expensive, you should perform the lookup using an asynchronous
 *        API (like NSURLConnection for web service resources) or in a background
 *        thread.
 *
 *        If the application data for the new month is already in-memory,
 *        you must still issue the callback.
 */
- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
	/* 
	 * In this example, I load the entire dataset in one HTTP request, so the date range that is 
	 * being presented is irrelevant. So all I need to do is make sure that the data is loaded
	 * the first time and that I always issue the callback to complete the asynchronous request
	 * (even in the trivial case where we are responding synchronously).
	 */
		
	if (!events || ![events count])
		[self fetchEvents];
	
	if (delegate && [delegate respondsToSelector:@selector(loadedDataSource:)]) {
		[delegate loadedDataSource:self];
	}
	
}

- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate
{	
	if (events && [events count])
		return [[self eventsFrom:fromDate to:toDate] valueForKeyPath:@"date"];
	else
		return [NSArray array];
}

- (void)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	if (events && [events count])
		[rows addObjectsFromArray:[self eventsFrom:fromDate to:toDate]];
}

- (void)removeAllItems
{
	[rows removeAllObjects];
}

- (NSArray *)filterEventsByString:(NSString *)filterString {
	
	if (!filterString)
		filterString = @"";
	
	/*if ([filterString isEqualToString:@""]) {
		[self fetchEvents];
	}*/
	
	if (events && [events count]) {
		[rows removeAllObjects];
		
		for (NSDictionary *event in events) {
			NSRange committeeRange = [[event objectForKey:@"committee"] 
									  rangeOfString:filterString options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)];
			
			NSRange locationRange = [[event objectForKey:@"location"] 
									 rangeOfString:filterString options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)];
			
			if (committeeRange.location != NSNotFound || locationRange.location != NSNotFound) {
				[rows addObject:event];
			}
		}
	}
	return rows;
}
@end
