//
//  ChamberCalendarObj.m
//  TexLege
//
//  Created by Gregory Combs on 8/12/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "ChamberCalendarObj.h"
#import "UtilityMethods.h"
#import "NSDate+Helper.h"
#import "NSDate+TKCategory.h"

#import "CalendarEventsLoader.h"

static BOOL IsDateBetweenInclusive(NSDate *date, NSDate *begin, NSDate *end)
{
	return [date compare:begin] != NSOrderedAscending && [date compare:end] != NSOrderedDescending;
}

@interface ChamberCalendarObj (Private)
- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate;
@end

@implementation ChamberCalendarObj

@synthesize title, chamber;

- (id)initWithDictionary:(NSDictionary *)calendarDict {
	if (self = [super init]) {
		self.title = [calendarDict valueForKey:@"title"];
		self.chamber = [calendarDict valueForKey:@"chamber"];
		rows = [[NSMutableArray alloc] init];
		hasPostedAlert = NO;
	}
	return self;
}

- (void)dealloc {
	
	self.title = nil;
	self.chamber = nil;
	[rows release];

    [super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"title: %@ - chamber: %@", 
			self.title, self.chamber];
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
	
	NSString *chamberString = stringForChamber([[event objectForKey:kCalendarEventsTypeChamberValue] integerValue], TLReturnInitial);
	NSString *committeeString = [NSString stringWithFormat:@"%@ %@", chamberString, [event objectForKey:kCalendarEventsCommitteeNameKey]];
	
	NSString *time = [event objectForKey:kCalendarEventsLocalizedTimeStringKey];
	if (IsEmpty(time) || [[event objectForKey:kCalendarEventsUnknownTimeKey] boolValue])
		time = @"(?)";
		
	NSString *timeLoc = [NSString stringWithFormat:@"Time: %@ - Place: %@", time, [event objectForKey:kCalendarEventsLocationKey]]; 

//	else
//		timeLoc = [event objectForKey:@"rawDateTime"];

	cell.textLabel.text = [NSString stringWithFormat:@"%@\n %@", committeeString, timeLoc];
	
	
	if ([[event objectForKey:kCalendarEventsCanceledKey] boolValue] == YES)
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

- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
	NSMutableArray *matches = [NSMutableArray array];
	for (NSDictionary *event in [[CalendarEventsLoader sharedCalendarEventsLoader] commiteeeMeetingsForChamber:[self.chamber integerValue]]) {
		
		if (IsDateBetweenInclusive([event objectForKey:kCalendarEventsLocalizedDateKey], fromDate, toDate))
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
		
	//if (!events || ![events count])
	//	[self fetchEvents];
	
	if (delegate && [delegate respondsToSelector:@selector(loadedDataSource:)]) {
		[delegate loadedDataSource:self];
	}
	
}

- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate
{	
	NSArray *temp = [[self eventsFrom:fromDate to:toDate] valueForKeyPath:kCalendarEventsLocalizedDateKey];
	if (!temp)
		temp = [NSArray array];
	return temp;
}

- (void)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	NSArray *temp = [self eventsFrom:fromDate to:toDate];
	if (!temp)
		temp = [NSArray array];
	
	[rows addObjectsFromArray:temp];
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
	
	NSArray *newEvents = [[CalendarEventsLoader sharedCalendarEventsLoader] commiteeeMeetingsForChamber:[self.chamber integerValue]];
	if (!IsEmpty(newEvents)){
		[rows removeAllObjects];
		
		for (NSDictionary *event in newEvents) {
			NSRange committeeRange = [[event objectForKey:kCalendarEventsCommitteeNameKey] 
									  rangeOfString:filterString options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)];
			
			NSRange locationRange = [[event objectForKey:kCalendarEventsLocationKey] 
									 rangeOfString:filterString options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)];
			
			if (committeeRange.location != NSNotFound || locationRange.location != NSNotFound) {
				[rows addObject:event];
			}
		}
	}
	return rows;
}
@end
