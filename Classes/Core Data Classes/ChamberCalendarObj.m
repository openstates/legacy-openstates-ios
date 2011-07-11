//
//  ChamberCalendarObj.m
//  Created by Gregory Combs on 8/12/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "ChamberCalendarObj.h"
#import "UtilityMethods.h"
#import "NSDate+Helper.h"
#import "LoadingCell.h"
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
	if ((self = [super init])) {
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
	NSInteger loadingStatus = [CalendarEventsLoader sharedCalendarEventsLoader].loadingStatus;
	if (loadingStatus > LOADING_IDLE) {
		if (indexPath.row == 0) {
			return [LoadingCell loadingCellWithStatus:loadingStatus tableView:tableView];
		}
		else {	// to make things work with our upcoming configureCell:, we need to trick this a little
			indexPath = [NSIndexPath indexPathForRow:(indexPath.row-1) inSection:indexPath.section];
		}
	}
	
	static NSString *identifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
		cell.textLabel.numberOfLines = 3;
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
	}
	
	NSDictionary *event = [self eventForIndexPath:indexPath];
	
	NSString *chamberString = stringForChamber([[event objectForKey:kCalendarEventsTypeChamberValue] integerValue], TLReturnInitial);
	NSString *committeeString = [NSString stringWithFormat:@"%@ %@", chamberString, [event objectForKey:kCalendarEventsCommitteeNameKey]];
	
	NSString *time = [event objectForKey:kCalendarEventsLocalizedTimeStringKey];
	if (IsEmpty(time) || [[event objectForKey:kCalendarEventsAllDayKey] boolValue]) {
		NSRange loc = [[event objectForKey:kCalendarEventsNotesKey] rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
		if (loc.location != NSNotFound && loc.length > 0) {
			time = [[event objectForKey:kCalendarEventsNotesKey] substringToIndex:loc.location];
		}
		else {
			time = [event objectForKey:kCalendarEventsNotesKey];
		}
	}
		
	BOOL isCancelled = ([[event objectForKey:kCalendarEventsCanceledKey] boolValue] == YES);		
	BOOL isSearching = NO;
	NSMutableString *cellText = [NSMutableString stringWithFormat:@"%@\n   ", committeeString];
	
	if (tableView.delegate && [tableView.delegate respondsToSelector:@selector(searchDisplayController)]) {
		UISearchDisplayController *sdc = [tableView.delegate performSelector:@selector(searchDisplayController)];
		if (sdc && sdc.searchResultsTableView && [tableView isEqual:sdc.searchResultsTableView]) {
			isSearching = YES;			
		}
	}
	[cellText appendFormat:NSLocalizedStringFromTable(@"When: %@ - %@", @"DataTableUI", @"The date and time for an event"), 
			[event objectForKey:kCalendarEventsLocalizedDateStringKey], time];
	
	if (isCancelled)
		[cellText appendString:NSLocalizedStringFromTable(@" - CANCELED", @"DataTableUI", @"an event was cancelled")];
	else if (!isSearching)
		[cellText appendFormat:NSLocalizedStringFromTable(@"\n   Where: %@", @"DataTableUI", @"the location of an event"), 
			[event objectForKey:kCalendarEventsLocationKey]];

	cell.textLabel.text = cellText;
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger count = 0;
	if (!IsEmpty(rows))
		count = [rows count];
	if ([CalendarEventsLoader sharedCalendarEventsLoader].loadingStatus > LOADING_IDLE)
		count++;
	return count;	
}

#pragma mark -
#pragma mark Data Storage

- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
	NSMutableArray *matches = [NSMutableArray array];
	NSArray *events = [[CalendarEventsLoader sharedCalendarEventsLoader] commiteeeMeetingsForChamber:[self.chamber integerValue]];
	for (NSDictionary *event in events) {
		
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
