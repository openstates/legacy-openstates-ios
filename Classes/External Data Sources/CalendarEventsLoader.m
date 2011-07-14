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
	
	NSDate *firstDate = [firstItem objectForKey:kCalendarEventsLocalizedStartDateKey];
	NSDate *secondDate = [secondItem objectForKey:kCalendarEventsLocalizedStartDateKey];
	
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

@synthesize loadingStatus;

+ (id)sharedCalendarEventsLoader
{
	static dispatch_once_t pred;
	static CalendarEventsLoader *foo = nil;
	
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}

- (id)init {
	if ((self=[super init])) {
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
		eventState = [meta.selectedState copy]; // testing use [@"ut" copy] or ["ky" copy];
		
		//	http://openstates.sunlightlabs.com/api/v1/events/?state=tx&apikey=xxxxxxxxxxxxxxxx

		isLoading = YES;
		self.loadingStatus = LOADING_ACTIVE;
		NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
									 eventState, @"state",
									 SUNLIGHT_APIKEY, @"apikey",
									 nil];
		
		// Just load all events for the state.  Until we see a huge explosion of big calendars, lets not bother with filtering here...
		RKRequest *request = [[[OpenLegislativeAPIs sharedOpenLegislativeAPIs] osApiClient] get:@"/events" 
																					queryParams:queryParams 
																					   delegate:self];
		if (request) {
			request.userData = eventState;
		}
	}
	else if (loadingStatus != LOADING_NO_NET) {
		self.loadingStatus = LOADING_NO_NET;
		[[NSNotificationCenter defaultCenter] postNotificationName:kCalendarEventsNotifyError object:nil];	
	}	
}

- (BOOL)isFresh {
	// if we're over a half-hour old, it's time to refresh
	return (updated && ([[NSDate date] timeIntervalSinceDate:updated] < 1800));
}

- (NSArray*)events {
	
	BOOL doLoad = YES;
	
	if ( (self.isFresh) &&			// IF we've updated recently AND
			((isLoading)	||			// we're already loading
			 (eventState && _events))	// OR we have valid info for the state and our list of events
		)
	{	
		doLoad = NO;			// THEN we don't need to reload yet.
	
		// Do we want to do something about loadingStatus == LOADING_NO_NET ???
	}
		
	if (doLoad) {
		
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

	nice_release(_events);
	
	// We had trouble loading the events online, so pull up the cache from the one in the documents folder, if possible
	
	NSString *thePath = [self pathToEventCacheWithRequest:request];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:thePath]) {
		
		debug_NSLog(@"EventsLoader: using cached events in the documents folder.");
		
		_events = [[NSMutableArray alloc] initWithContentsOfFile:thePath];
	}
	if (!_events) {
		_events = [[NSMutableArray alloc] init];	// at least create an empty array
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
			if (newEvent) {
				[_events addObject:newEvent];
			}
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

		nice_release(updated);
		updated = [[NSDate date] retain];
					
		[[NSNotificationCenter defaultCenter] postNotificationName:kCalendarEventsNotifyLoaded object:nil];

	}
}

- (NSMutableDictionary *)standardizeEvent:(NSDictionary *)inEvent {

	// We wrap this whole thing in a try/catch because it's very easy for one tiny
	//	 event with bad data to crash the application when parsing, upon an exception

	@try {
		
		NSMutableDictionary *loadedEvent = [NSMutableDictionary dictionaryWithDictionary:inEvent];
		
		
		if ([[NSNull null] isEqual:[loadedEvent objectForKey:kCalendarEventsEndKey]])
			[loadedEvent removeObjectForKey:kCalendarEventsEndKey];
		
		if ([[NSNull null] isEqual:[loadedEvent objectForKey:kCalendarEventsNotesKey]])
			[loadedEvent setObject:@"" forKey:kCalendarEventsNotesKey];
		
		
		// Collect the start date/time of the event, and pre-format our date/time strings
		
		NSString *start = [loadedEvent objectForKey:kCalendarEventsWhenKey];
		NSDate *localStartDate = [NSDate localDateFromUTCString:start];
		
		if (!localStartDate) {	// If we can't find a start date/time, we have to skip this event.
			
			NSLog(@"--- Cannot find a date/time for this event: %@", inEvent);
			
			return nil;
		}
		
		[loadedEvent setObject:localStartDate forKey:kCalendarEventsLocalizedStartDateKey];
		
		NSString *dateString = [localStartDate stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
		if (dateString)
			[loadedEvent setObject:dateString forKey:kCalendarEventsLocalizedDateStringKey];
		
		NSString *timeString = [localStartDate stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
		if (timeString)
			[loadedEvent setObject:timeString forKey:kCalendarEventsLocalizedTimeStringKey];
		
		
		
		// Either collect or estimate the end date/time of the event
		
		NSString *end = [loadedEvent objectForKey:kCalendarEventsEndKey];
		NSDate *localEndDate = nil;
		if (!IsEmpty(end)) {
			localEndDate = [NSDate localDateFromUTCString:end];
		}
		else if (localStartDate) {
			localEndDate   = [NSDate dateWithTimeInterval:3600 sinceDate:localStartDate];
		}
		
		if (localEndDate) {
			[loadedEvent setObject:localEndDate forKey:kCalendarEventsLocalizedEndDateKey];
		}
		
		
		// Gather details on committees and chambers for a committee meeting (if possible)
		
		NSArray *participants = [loadedEvent objectForKey:kCalendarEventsParticipantsKey];
		if (!IsEmpty(participants)) {
			
			NSDictionary *participant = [participants findWhereKeyPath:kCalendarEventsParticipantTypeKey equals:kCalendarEventsCommitteeNameKey];
			if (participant) {
				[loadedEvent setObject:[participant objectForKey:kCalendarEventsParticipantNameKey] forKey:kCalendarEventsCommitteeNameKey];
				
				NSString * chamberString = [participant objectForKey:kCalendarEventsTypeChamberValue];
				if (!IsEmpty(chamberString))
					[loadedEvent setObject:[NSNumber numberWithInteger:chamberFromOpenStatesString(chamberString)] forKey:kCalendarEventsTypeChamberValue];
			}
		}
		
		// Set a boolean for convenient access to CANCELED
		
		BOOL canceled = ([[loadedEvent objectForKey:kCalendarEventsStatusKey] isEqualToString:kCalendarEventsCanceledKey]);
		[loadedEvent setObject:[NSNumber numberWithBool:canceled] forKey:kCalendarEventsCanceledKey];
		
		
		//////////// Build a summary string to use for table cells //////////////
		
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
		
		// Store a slimmed title for this event ... not elegant, but it works for at least a couple of states
		[loadedEvent setObject:eventDesc forKey:kCalendarEventsTitleKey];
		
		
		NSMutableString *summaryText = [[NSMutableString alloc] initWithString:eventDesc];
		
		if (!IsEmpty(summaryText))
			[summaryText appendString:@"\n   "];
			
		[summaryText appendFormat:NSLocalizedStringFromTable(@"When: %@ - %@", @"DataTableUI", @"The date and time for an event"), 
		 dateString, timeString];
		
		if (canceled)
			[summaryText appendString:NSLocalizedStringFromTable(@" - CANCELED", @"DataTableUI", @"an event was cancelled")];
		else
			[summaryText appendFormat:NSLocalizedStringFromTable(@"\n   Where: %@", @"DataTableUI", @"the location of an event"), 
			 [loadedEvent objectForKey:kCalendarEventsLocationKey]];
		
		
		[loadedEvent setObject:summaryText forKey:kCalendarEventsSummaryTextKey];
		
		[summaryText release];
		
		return loadedEvent;
	
	}
	@catch (NSException * e) {
		NSLog(@"Error parsing event dictionary: %@", inEvent);		
	}
	
	return nil;

}

- (NSArray *)calendarEventsForType:(NSString *)eventType {
	if (IsEmpty(_events))
		return nil;
	
	NSArray *foundEvents = self.events;
	
	if (!IsEmpty(eventType) && !IsEmpty(foundEvents)) {
		
		foundEvents = [foundEvents findAllWhereKeyPath:kCalendarEventsTypeKey equals:eventType];

	}
	return foundEvents;
}


#pragma mark -
#pragma mark EventKit
- (void)addAllEventsToiCal:(id)sender {

	// TODO: ask what calendar they want use (iOS 5)

	NSLog(@"CalendarEventsLoader == ADDING ALL MEETINGS TO ICAL == (MESSY)");
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"iCAL_ALL_MEETINGS"];
	
	for (NSDictionary *event in _events) {
		[self addEventToiCal:event delegate:nil];
	}
}


// This is a janky way to see if we've previously added an event with this Open States ID to a calendar.
//	  It helps avoid unnecessary event duplication in iCal

- (EKEvent *)findEKEventWithOpenStatesEventID:(NSString *)osEventID 
								  orStartDate:(NSDate *)meetingDate 
									 andTitle:(NSString *)title {
	EKEvent *event  = nil;

	// TODO: Update for iOS 5
	
	// Right now, the only way to do this is by storing a list of previous events we've tackled in the user defaults.
	//   Not ideal, to say the least, but it's the only way to do it until Apple beefs up the EventKit framework.
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSMutableArray *eventIDs = [[[NSUserDefaults standardUserDefaults] objectForKey:kTLEventKitKey] mutableCopy];
	NSMutableDictionary *eventEntry = [eventIDs findWhereKeyPath:kTLEventKitTLIDKey equals:osEventID];
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
			if ([foundevent.title isEqualToString:title]) {
				event = foundevent; 
				//[eventStore removeEvent:foundevent span:EKSpanThisEvent error:&error];
			}
		}
	}
	
	return event;
	
}

// This will save and event in the iCal calendar, and also
//		create a record in UserDefaults that ties our EventKit event to an open states id key 

- (void)saveEKEvent:(EKEvent *)event withOpenStatesID:(NSString *)osEventID {
	
	// Save the event in the EventKit
	
	NSError *err = nil;
	[event setCalendar:[eventStore defaultCalendarForNewEvents]];

    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
	
	if (err) {
		NSLog(@"CalendarEventsLoader: error saving event %@: %@", [event description], [err localizedDescription]);
	}
	
	
	// Now tie the open states event ID to this EK event, replacing the old record if it exists already
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSMutableArray *eventIDs = [[[NSUserDefaults standardUserDefaults] objectForKey:kTLEventKitKey] mutableCopy];
	NSMutableDictionary *eventEntry = [eventIDs findWhereKeyPath:kTLEventKitTLIDKey equals:osEventID];
	
	// Remove an old event from our custom storage box, replace it with an updated version, IF it exists
	
	if (eventEntry) {
		[eventIDs removeObject:eventEntry];
	}
	
	eventEntry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				  event.eventIdentifier, kTLEventKitEKIDKey,
				  osEventID, kTLEventKitTLIDKey,
				  nil];
	
	[eventIDs addObject:eventEntry];
	
	[[NSUserDefaults standardUserDefaults] setObject:eventIDs forKey:kTLEventKitKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[eventIDs release];
}



- (void)addEventToiCal:(NSDictionary *)eventDict delegate:(id)delegate {
	if (!eventDict || !eventStore)
		return;
	
	NSDate *startDate = [eventDict objectForKey:kCalendarEventsLocalizedStartDateKey];
	NSDate *endDate = [eventDict objectForKey:kCalendarEventsLocalizedEndDateKey];

	if (!startDate)
		return;	// can't do anything if we don't have a valid start date
	
	NSString *osEventID = [eventDict objectForKey:kCalendarEventsIDKey];
	NSString *eventTitle = [eventDict objectForKey:kCalendarEventsTitleKey];

	// See if we've already stored an event with this ID in a calendar before
	EKEvent *event  = [self findEKEventWithOpenStatesEventID:osEventID
												 orStartDate:startDate
													andTitle:eventTitle];
		
	if (!event)  // we didn't find an event, so lets create a new one
		event = [EKEvent eventWithEventStore:eventStore];
	
	
	//////  Start populating the EventKit event with the appropriate values from our event dictionary
	
	event.title = eventTitle;

	if ([[eventDict objectForKey:kCalendarEventsCanceledKey] boolValue] == YES)
		event.title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ (CANCELED)", @"DataTableUI", @"the event was cancelled"), 
					   eventTitle];
	
	if (NO == IsEmpty([eventDict objectForKey:kCalendarEventsLocationKey]))
		event.location = [eventDict objectForKey:kCalendarEventsLocationKey];
	
	if (NO == IsEmpty([eventDict objectForKey:kCalendarEventsNotesKey]))
		event.notes = [eventDict objectForKey:kCalendarEventsNotesKey];
		
	event.startDate = startDate;
	if (endDate)
		event.endDate = endDate;
	else
		event.endDate = startDate;
	
	if ([[eventDict objectForKey:kCalendarEventsAllDayKey] boolValue])
		event.allDay = YES; 
	
	
	[self saveEKEvent:event withOpenStatesID:osEventID];
	
			
	if (delegate && [delegate respondsToSelector:@selector(presentEventEditorForEvent:)]) {
		[delegate performSelector:@selector(presentEventEditorForEvent:) withObject:event];
	}
}	

@end
