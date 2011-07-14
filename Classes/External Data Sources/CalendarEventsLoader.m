//
//  CalendarEventsLoader.m
//  Created by Gregory Combs on 3/18/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "CalendarEventsLoader.h"
#import "NSDate+Helper.h"
#import "JSONKit.h"
#import "UtilityMethods.h"
#import "TexLegeReachability.h"
#import "OpenLegislativeAPIs.h"

#import "LocalyticsSession.h"
#import "OpenLegislativeAPIs.h"
#import "LoadingCell.h"

#import "CalendarDetailViewController.h"
#import "StateMetaLoader.h"

/*
 Sorts an array of CalendarItems objects by date.  
 */
NSComparisonResult sortByDate(id firstItem, id secondItem, void *context)
{
	NSComparisonResult comparison = NSOrderedSame;
	
	NSDate *firstDate = [firstItem objectForKey:kCalendarEventsLocalizedDateKey];
	NSDate *secondDate = [secondItem objectForKey:kCalendarEventsLocalizedDateKey];
	
	NSString *firstWhen = [firstItem objectForKey:kCalendarEventsWhenKey];
	NSString *secondWhen = [secondItem objectForKey:kCalendarEventsWhenKey];
	
	NSString *firstID = [firstItem objectForKey:kCalendarEventsIDKey];
	NSString *secondID = [secondItem objectForKey:kCalendarEventsIDKey];
	
	if (firstDate && secondDate)
		comparison = [firstDate compare:secondDate];
	else if (firstWhen && secondWhen)
		comparison = [firstWhen compare:secondWhen];
	else if (firstID && secondID)
		comparison = [firstID compare:secondID];
	
	return comparison;
}

@interface CalendarEventsLoader (Private)
- (NSMutableDictionary *)standardizeEvent:(NSDictionary *)inEvent;
@end

@implementation CalendarEventsLoader

@synthesize isFresh, loadingStatus;

+ (id)sharedCalendarEventsLoader
{
	static dispatch_once_t pred;
	static CalendarEventsLoader *foo = nil;
	
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}

- (id)init {
	if ((self=[super init])) {
		isFresh = NO;
		_events = nil;
		updated = nil;
		eventState = nil;
		isLoading = NO;
		loadingStatus = LOADING_IDLE;

		[[TexLegeReachability sharedTexLegeReachability] addObserver:self 
														  forKeyPath:@"openstatesConnectionStatus" 
															 options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) 
															 context:nil];

		[OpenLegislativeAPIs sharedOpenLegislativeAPIs];
		
		[[StateMetaLoader sharedStateMeta] addObserver:self 
													  forKeyPath:@"selectedState" 
														 options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) 
														 context:nil];
		
		eventStore = [[EKEventStore alloc] init];
		[eventStore defaultCalendarForNewEvents];

		/*
		#warning danger
		NSDate *past = [NSDate dateFromString:@"December 1, 2009" withFormat:@"MMM d, yyyy"];
		NSDate *future = [NSDate dateFromString:@"December 1, 2011" withFormat:@"MMM d, yyyy"];
		NSPredicate *pred = [eventStore predicateForEventsWithStartDate:past endDate:future calendars:nil];
		NSArray *allEvents = [eventStore eventsMatchingPredicate:pred];
		for (EKEvent *event in allEvents) {
			NSError *error = nil;
			if (![eventStore removeEvent:event span:EKSpanThisEvent error:&error])
				NSLog(@"%@", [error localizedDescription]);
		}
		
		[[NSUserDefaults standardUserDefaults] synchronize];
		if (IsEmpty([[NSUserDefaults standardUserDefaults] objectForKey:kTLEventKitKey])) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSMutableArray array] forKey:kTLEventKitKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		*/

	}
	return self;
}

- (void)dealloc {
	[[StateMetaLoader sharedStateMeta] removeObserver:self forKeyPath:@"selectedState"];
	[[TexLegeReachability sharedTexLegeReachability] removeObserver:self forKeyPath:@"openstatesConnectionStatus"];
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
	
	if (updated)
		[updated release], updated = nil;
	if (_events)
		[_events release], _events = nil;
	if (eventStore)
		[eventStore release], eventStore = nil;
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
	if (!IsEmpty(keyPath)) {
		if ([keyPath isEqualToString:@"openstatesConnectionStatus"] ||
			[keyPath isEqualToString:@"selectedState"]) {
			
			/*
			if ([change valueForKey:NSKeyValueChangeKindKey] == NSKeyValueChangeSetting) {
				id newVal = [change valueForKey:NSKeyValueChangeNewKey];
			}*/
			
			if ([TexLegeReachability openstatesReachable])
				[self loadEvents:nil];
			else if (self.loadingStatus != LOADING_NO_NET) {
				self.loadingStatus = LOADING_NO_NET;
				[[NSNotificationCenter defaultCenter] postNotificationName:kCalendarEventsNotifyError object:nil];	
			}
		}
	}	
}

- (void)loadEvents:(id)sender {
	if (isLoading)
		return;	// we're already working on it
	
	if ([TexLegeReachability openstatesReachable]) {
		StateMetaLoader *meta = [StateMetaLoader sharedStateMeta];
		
		if (IsEmpty(meta.selectedState))
			return;
		
		nice_release(eventState);
		eventState = [meta.selectedState copy]; // testing [@"ut" copy];
		
		//	http://openstates.sunlightlabs.com/api/v1/events/?state=tx&apikey=xxxxxxxxxxxxxxxx

		isLoading = YES;
		self.loadingStatus = LOADING_ACTIVE;
		NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
									 eventState, @"state",
//									 kCalendarEventsTypeCommitteeValue, kCalendarEventsTypeKey,	// right now, lets just do committee meetings
									 SUNLIGHT_APIKEY, @"apikey",
									 nil];
		RKRequest *request = [[[OpenLegislativeAPIs sharedOpenLegislativeAPIs] osApiClient] get:@"/events" queryParams:queryParams delegate:self];
		if (request) {
			request.userData = eventState;
		}
	}
	else if (self.loadingStatus != LOADING_NO_NET) {
		self.loadingStatus = LOADING_NO_NET;
		[[NSNotificationCenter defaultCenter] postNotificationName:kCalendarEventsNotifyError object:nil];	
	}	
}

- (NSArray*)events {
	if (isLoading && (updated && ([[NSDate date] timeIntervalSinceDate:updated] < 1800))) // if we're over a half-hour old, let's refresh
		return _events;	// we're already working on it

	if (!eventState || self.loadingStatus > LOADING_NO_NET || !_events || !isFresh) {
		isFresh = NO;
		debug_NSLog(@"CalendarEventsLoader is stale, need to refresh");
		
		[self loadEvents:nil];
	}
	return _events;
}

- (NSString *)pathToEventCacheWithRequest:(RKRequest *)request {
	NSString *loadedState = eventState; // default to what we stored at the time of our last request
	
	if (request && request.userData && [request.userData isKindOfClass:[NSString class]]) {
		if (!IsEmpty(request.userData)) {
			loadedState = request.userData;	// if we received a valid request object, find the state we stored...
		}
	}
	
	// We had trouble loading the events online, so pull up the cache from the one in the documents folder, if possible
	
	NSString *stateEventsCache = [NSString stringWithFormat:@"%@-%@", loadedState, kCalendarEventsCacheFile];
	NSString *thePath = [[UtilityMethods applicationCachesDirectory] stringByAppendingPathComponent:stateEventsCache];
	
	return thePath;
}

#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
	if (error && request) {
		debug_NSLog(@"Error loading events from %@: %@", [request description], [error localizedDescription]);
	}
	
	isLoading = NO;
	isFresh = NO;

	nice_release(_events);
	
	// We had trouble loading the events online, so pull up the cache from the one in the documents folder, if possible
	
	NSString *thePath = [self pathToEventCacheWithRequest:request];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:thePath]) {
		debug_NSLog(@"EventsLoader: using cached events in the documents folder.");
		_events = [[NSMutableArray arrayWithContentsOfFile:thePath] retain];
	}
	if (!_events) {
		_events = [[NSMutableArray array] retain];	// at least create an empty array
	}
	if (self.loadingStatus != LOADING_NO_NET) {
		self.loadingStatus = LOADING_NO_NET;
		[[NSNotificationCenter defaultCenter] postNotificationName:kCalendarEventsNotifyError object:nil];
	}
}


- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
	
	isLoading = NO;
	
	if ([request isGET] && [response isOK]) {  
		// Success! Let's take a look at the data
		self.loadingStatus = LOADING_IDLE;

		nice_release(_events);
		
		NSArray *allEvents = [response.body objectFromJSONData];
		//allEvents = [allEvents findAllWhereKeyPath:kCalendarEventsTypeKey equals:kCalendarEventsTypeCommitteeValue];		

		_events = [[NSMutableArray alloc] init];
		for (NSDictionary *event in allEvents) {
			NSMutableDictionary *newEvent = [self standardizeEvent:event];	// clean up events, parsing for our needs

			[_events addObject:newEvent];
		}
				
		if (NO == IsEmpty(_events)) {
			debug_NSLog(@"EventsLoader network download successful, archiving for others.");

			[_events sortUsingFunction:sortByDate context:nil];

			NSString *thePath = [self pathToEventCacheWithRequest:request];		
			if (![_events writeToFile:thePath atomically:YES]) {
				NSLog(@"CalendarEventsLoader: Error writing event cache to file: %@", thePath);
			}
		
		}
		/*else {	// we might just have a state that doesn't have events yet!
			[self request:request didFailLoadWithError:nil];
		}*/

		isFresh = YES;
		nice_release(updated);
		updated = [[NSDate date] retain];
					
		[[NSNotificationCenter defaultCenter] postNotificationName:kCalendarEventsNotifyLoaded object:nil];

	}
}

- (NSMutableDictionary *)standardizeEvent:(NSDictionary *)inEvent {
	NSMutableDictionary *loadedEvent = [NSMutableDictionary dictionaryWithDictionary:inEvent];
	
				
	if ([[NSNull null] isEqual:[loadedEvent objectForKey:kCalendarEventsEndKey]])
		[loadedEvent removeObjectForKey:kCalendarEventsEndKey];
	if ([[NSNull null] isEqual:[loadedEvent objectForKey:kCalendarEventsNotesKey]])
		[loadedEvent setObject:@"" forKey:kCalendarEventsNotesKey];

		
	NSString *when = [loadedEvent objectForKey:kCalendarEventsWhenKey];
	NSDate *utcDate = [NSDate dateFromTimestampString:when];
	NSDate *localDate = [NSDate dateFromDate:utcDate fromTimeZone:@"UTC"];
	
	// Set the date and time, and pre-format our strings
	if (localDate) {
		[loadedEvent setObject:localDate forKey:kCalendarEventsLocalizedDateKey];
		
		NSString *dateString = [localDate stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
		if (dateString)
			[loadedEvent setObject:dateString forKey:kCalendarEventsLocalizedDateStringKey];
		
		NSString *timeString = [localDate stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
		if (timeString) {
			[loadedEvent setObject:timeString forKey:kCalendarEventsLocalizedTimeStringKey];
		}
	}
	
	NSArray *participants = [loadedEvent objectForKey:kCalendarEventsParticipantsKey];
	if (!IsEmpty(participants)) {
		NSDictionary *participant = [participants findWhereKeyPath:kCalendarEventsParticipantTypeKey equals:@"committee"];
		if (participant) {
			[loadedEvent setObject:[participant objectForKey:kCalendarEventsParticipantNameKey] forKey:kCalendarEventsCommitteeNameKey];
			
			NSString * chamberString = [participant objectForKey:kCalendarEventsTypeChamberValue];
			if (!IsEmpty(chamberString))
				[loadedEvent setObject:[NSNumber numberWithInteger:chamberFromOpenStatesString(chamberString)] forKey:kCalendarEventsTypeChamberValue];
		}
	}
		
	BOOL canceled = ([[loadedEvent objectForKey:kCalendarEventsStatusKey] isEqualToString:kCalendarEventsCanceledKey]);
	[loadedEvent setObject:[NSNumber numberWithBool:canceled] forKey:kCalendarEventsCanceledKey];
	
	NSString *announceUrl = [loadedEvent objectForKey:kCalendarEventsAnnouncementURLKey]; // "link"
	if (IsEmpty(announceUrl)) {
		NSArray *sources = [loadedEvent valueForKey:@"sources"];
		NSDictionary *sourceDict = [sources objectAtIndex:0];
		announceUrl = [sourceDict valueForKey:@"url"];		// "sources.url"
		
		if (!IsEmpty(announceUrl)) {
			[loadedEvent setObject:announceUrl forKey:kCalendarEventsAnnouncementURLKey];  // set a link if we have one
		}
	}
	
	#warning Build a shortened event title, if at all possible
	
	//////////// Build a summary string to use for table cells //////////////

	@try {
	
		NSString *time = [loadedEvent objectForKey:kCalendarEventsLocalizedTimeStringKey];
		if (IsEmpty(time) || [[loadedEvent objectForKey:kCalendarEventsAllDayKey] boolValue]) {
			NSRange loc = [[loadedEvent objectForKey:kCalendarEventsNotesKey] rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
			if (loc.location != NSNotFound && loc.length > 0) {
				time = [[loadedEvent objectForKey:kCalendarEventsNotesKey] substringToIndex:loc.location];
			}
			else {
				time = [loadedEvent objectForKey:kCalendarEventsNotesKey];
			}
		}
		
		
		BOOL isCancelled = ([[loadedEvent objectForKey:kCalendarEventsCanceledKey] boolValue] == YES);		
		
		NSString *eventDesc = [loadedEvent objectForKey:kCalendarEventsDescriptionKey];
		
		NSString *chamberName = nil;
		NSNumber *chamberValue = [loadedEvent objectForKey:kCalendarEventsTypeChamberValue];
		if (chamberValue) {
			chamberName = stringForChamber([chamberValue integerValue], TLReturnInitial);		
		}
		
		NSString *committeeName = [loadedEvent objectForKey:kCalendarEventsCommitteeNameKey];
		if (!IsEmpty(committeeName)) {
			if (!IsEmpty(chamberName)) {
				eventDesc = [NSString stringWithFormat:@"%@ %@", chamberName, committeeName];
			}
			else {
				eventDesc = committeeName;
			}
		}
		
		NSMutableString *summaryText = [[NSMutableString alloc] initWithString:eventDesc];
		
		if (!IsEmpty(summaryText))
			[summaryText appendString:@"\n   "];
			
		[summaryText appendFormat:NSLocalizedStringFromTable(@"When: %@ - %@", @"DataTableUI", @"The date and time for an event"), 
		 [loadedEvent objectForKey:kCalendarEventsLocalizedDateStringKey], time];
		
		if (isCancelled)
			[summaryText appendString:NSLocalizedStringFromTable(@" - CANCELED", @"DataTableUI", @"an event was cancelled")];
		else
			[summaryText appendFormat:NSLocalizedStringFromTable(@"\n   Where: %@", @"DataTableUI", @"the location of an event"), 
			 [loadedEvent objectForKey:kCalendarEventsLocationKey]];
		
		
		[loadedEvent setObject:summaryText forKey:kCalendarEventsSummaryTextKey];
		
		[summaryText release];
	
	}
	@catch (NSException * e) {
		NSLog(@"Error parsing event dictionary: %@", loadedEvent);
	}
	
	return loadedEvent;
}

- (NSArray *)calendarEventsForType:(NSString *)eventType {
	if (IsEmpty(_events))
		return nil;
	
	NSArray *foundEvents = nil;
	
	if (!IsEmpty(eventType)) {
		foundEvents = [self.events findAllWhereKeyPath:kCalendarEventsTypeKey equals:eventType];

	}
	return foundEvents;
}


#pragma mark -
#pragma mark EventKit
- (void)addAllEventsToiCal:(id)sender {
#warning see about asking what calendar they want use (iOS 5)

	if (![UtilityMethods supportsEventKit] || !eventStore) {
		debug_NSLog(@"EventKit not available on this device");
		return;
	}
	
	NSLog(@"CalendarEventsLoader == ADDING ALL MEETINGS TO ICAL == (MESSY)");
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"iCAL_ALL_MEETINGS"];

	NSArray *meetings = [self calendarEventsForType:BOTH_CHAMBERS];
	for (NSDictionary *meeting in meetings) {
		[self addEventToiCal:meeting delegate:nil];
	}
}

#warning specific to committee meetings in texas

- (void)addEventToiCal:(NSDictionary *)eventDict delegate:(id)delegate {
	if (!eventDict || !eventStore)
		return;
	
	NSString *chamberString = stringForChamber([[eventDict objectForKey:kCalendarEventsTypeChamberValue] integerValue], TLReturnFull); 
	NSString *committee = [eventDict objectForKey:kCalendarEventsCommitteeNameKey];	
	NSDate *meetingDate = [eventDict objectForKey:kCalendarEventsLocalizedDateKey];
	NSString *chamberCommitteeString = [NSString stringWithFormat:@"%@ %@", chamberString, committee];

	EKEvent *event  = nil;
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSMutableArray *eventIDs = [[[NSUserDefaults standardUserDefaults] objectForKey:kTLEventKitKey] mutableCopy];
	NSMutableDictionary *eventEntry = [eventIDs findWhereKeyPath:kTLEventKitTLIDKey equals:[eventDict objectForKey:kCalendarEventsIDKey]];
	if (eventEntry) {
		id eventIdentifier = [eventEntry objectForKey:kTLEventKitEKIDKey];
		if (eventIdentifier)
			event = [eventStore eventWithIdentifier:eventIdentifier];
	}
	if (!event && meetingDate) {
		NSPredicate *pred = [eventStore predicateForEventsWithStartDate:meetingDate endDate:meetingDate calendars:nil];
		NSArray *allEvents = [eventStore eventsMatchingPredicate:pred];
		for (EKEvent *foundevent in allEvents) {
			//NSError *error = nil;
			if ([foundevent.title isEqualToString:chamberCommitteeString]) {
				NSLog(@"found event %@", foundevent.title);
				event = foundevent; //[eventStore removeEvent:foundevent span:EKSpanThisEvent error:&error];
			}
		}
	}
	if (!event)
		// we didn't find an event, so lets create
		event = [EKEvent eventWithEventStore:eventStore];
	
	event.title     = chamberCommitteeString;
	if ([[eventDict objectForKey:kCalendarEventsCanceledKey] boolValue] == YES)
		event.title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ (CANCELED)", @"DataTableUI", @"the event was cancelled"), 
					   event.title];
	
	event.location = [eventDict objectForKey:kCalendarEventsLocationKey];
	
	event.notes = NSLocalizedStringFromTable(@"[TexLege] Length of this meeting is only an estimate.", @"DataTableUI", @"inserted into iOS calendar events");
	if (NO == IsEmpty([eventDict objectForKey:kCalendarEventsNotesKey]))
		event.notes = [eventDict objectForKey:kCalendarEventsNotesKey];
	else if (NO == IsEmpty([eventDict objectForKey:kCalendarEventsAnnouncementURLKey])) {
		NSURL *url = [NSURL URLWithString:[eventDict objectForKey:kCalendarEventsAnnouncementURLKey]];
		if ([TexLegeReachability canReachHostWithURL:url alert:NO]) {
			NSError *error = nil;
			NSString *urlcontents = [NSString stringWithContentsOfURL:url encoding:NSWindowsCP1252StringEncoding error:&error];
			if (!error && urlcontents && [urlcontents length]) {
				NSString *flattened = [[urlcontents flattenHTML] stringByReplacingOccurrencesOfString:@"Schedule Display" withString:@""];
				flattened = [flattened stringByReplacingOccurrencesOfString:@"\r\n\r\n" withString:@"\r\n"];
				event.notes = flattened;
			}
		}
	}
	
	if (!meetingDate || [[eventDict objectForKey:kCalendarEventsAllDayKey] boolValue]) {
		debug_NSLog(@"Calendar Detail ... don't know the complete event time/date");
		event.allDay = YES; 
		if ([eventDict objectForKey:kCalendarEventsLocalizedDateKey]) {
			event.startDate = [eventDict objectForKey:kCalendarEventsLocalizedDateKey];
			event.endDate = [eventDict objectForKey:kCalendarEventsLocalizedDateKey];
		}
		event.location = [eventDict objectForKey:kCalendarEventsLocationKey];
	}
	else {
		event.startDate = meetingDate;
		event.endDate   = [NSDate dateWithTimeInterval:3600 sinceDate:event.startDate];
	}
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
	
	NSError *err = nil;
    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
	if (err)
		NSLog(@"CalendarEventsLoader: error saving event %@: %@", [event description], [err localizedDescription]);

	if (eventEntry)
		[eventIDs removeObject:eventEntry];
	
	eventEntry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				  event.eventIdentifier, kTLEventKitEKIDKey,
				  [eventDict objectForKey:kCalendarEventsIDKey], kTLEventKitTLIDKey,
				  //eventStore.eventStoreIdentifier, kTLEventKitStoreKey,
				  nil];
	[eventIDs addObject:eventEntry];

	[[NSUserDefaults standardUserDefaults] setObject:eventIDs forKey:kTLEventKitKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
			
	if (delegate && [delegate respondsToSelector:@selector(presentEventEditorForEvent:)]) {
		[delegate performSelector:@selector(presentEventEditorForEvent:) withObject:event];
	}
	[eventIDs release];
}	

@end
