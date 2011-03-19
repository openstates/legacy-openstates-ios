//
//  CalendarEventsLoader.m
//  TexLege
//
//  Created by Gregory Combs on 3/18/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "CalendarEventsLoader.h"
#import "NSDate+Helper.h"
#import "JSON.h"
#import "UtilityMethods.h"
#import "TexLegeReachability.h"
#import "LegislativeAPIUtils.h"
#import <EventKitUI/EventKitUI.h>
#import "LocalyticsSession.h"

@implementation CalendarEventsLoader
SYNTHESIZE_SINGLETON_FOR_CLASS(CalendarEventsLoader);
@synthesize isFresh, eventApiClient;

- (id)init {
	if (self=[super init]) {
		isFresh = NO;
		_events = nil;
		updated = nil;
		eventApiClient = [[RKClient clientWithBaseURL:osApiBaseURL] retain];
		
		if ([UtilityMethods supportsEventKit]) {
			eventStore = [[[EKEventStore alloc] init] retain];
			[eventStore defaultCalendarForNewEvents];

			/*#warning danger
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
	}
	return self;
}

- (void)dealloc {
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
	if (updated)
		[updated release], updated = nil;
	if (eventApiClient)
		[eventApiClient release], eventApiClient = nil;
	if (_events)
		[_events release], _events = nil;
	
	if ([UtilityMethods supportsEventKit]) {
		if (eventStore)
			[eventStore release], eventStore = nil;
	}
	[super dealloc];
}

- (void)loadEvents:(id)sender {
	if ([TexLegeReachability canReachHostWithURL:[NSURL URLWithString:osApiBaseURL] alert:NO]) {
		//	http://openstates.sunlightlabs.com/api/v1/events/?state=tx&apikey=350284d0c6af453b9b56f6c1c7fea1f9

		if (eventApiClient) {
			NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"tx", @"state",
										 osApiKeyValue, osApiKeyKey,
										 nil];
			[eventApiClient get:@"/events" queryParams:queryParams delegate:self];
		}
	}
}

- (NSArray*)events {
	if (!isFresh || !updated || ([[NSDate date] timeIntervalSinceDate:updated] > 3600)) {	// if we're over an hour old, let's refresh
		isFresh = NO;
		debug_NSLog(@"CalendarEventsLoader is stale, need to refresh");
		
		[self loadEvents:nil];
	}
	
	return _events;
}

#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
	if (error && request) {
		debug_NSLog(@"Error loading events from %@: %@", [request description], [error localizedDescription]);
		[[NSNotificationCenter defaultCenter] postNotificationName:kCalendarEventsNotifyError object:nil];
	}
	
	isFresh = NO;

	// We had trouble loading the events online, so pull up the cache from the one in the documents folder, if possible
	NSError *newError = nil;
	NSArray *jsonArray = nil;
	NSString *localPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kCalendarEventsCacheFile];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:localPath]) {
		debug_NSLog(@"EventsLoader: No events cache and no network connection, can't show any events.");
	}
	else {
		debug_NSLog(@"EventsLoader: using cached events in the documents folder.");
		NSString *jsonMenus = [NSString stringWithContentsOfFile:localPath encoding:NSUTF8StringEncoding error:&newError];
		if (!error)
			jsonArray = [jsonMenus JSONValue];
	}
	
	if (_events)
		[_events release];
	if (jsonArray)
		_events = [[NSMutableArray arrayWithArray:jsonArray] retain];
	else
		_events = [[NSMutableArray array] retain];

	[[NSNotificationCenter defaultCenter] postNotificationName:kCalendarEventsNotifyLoaded object:nil];
	
}


// Handling GET /BillMetadata.json  
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
	if ([request isGET] && [response isOK]) {  
		// Success! Let's take a look at the data  
		if (_events)
			[_events release];	
		
		_events = [[NSMutableArray arrayWithArray:[response bodyAsJSON]] retain];
		if (_events) {
			NSString *localPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kCalendarEventsCacheFile];
			[_events writeToFile:localPath atomically:YES];	
			isFresh = YES;
			updated = [[NSDate date] retain];
			[[NSNotificationCenter defaultCenter] postNotificationName:kCalendarEventsNotifyLoaded object:nil];
			debug_NSLog(@"EventsLoader network download successfull, archiving for others.");
		}		
		else {
			[self request:request didFailLoadWithError:nil];
			return;
		}
	}
}

- (NSDictionary *)parseEvent:(NSMutableDictionary *)loadedEvent {
	
	BOOL unknownTime = YES;
	NSString *when = [loadedEvent objectForKey:kCalendarEventsWhenKey];
	if (when) {
		NSDate *utcDate = [NSDate dateFromTimestampString:when];
		NSDate *localDate = [NSDate dateFromDate:utcDate fromTimeZone:@"UTC"];
		
		unknownTime = ([when hasSuffix:@"00:00:00"] || [utcDate equalsDefaultDate] || [localDate equalsDefaultDate]);
		
		if (localDate) {
			[loadedEvent setObject:localDate forKey:kCalendarEventsLocalizedDateKey];
			
			NSString *dateString = [localDate stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
			if (dateString)
				[loadedEvent setObject:dateString forKey:kCalendarEventsLocalizedDateStringKey];
			
			NSString *timeString = [localDate stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
			if (timeString) {
				if ([timeString isEqualToString:@"12:00am"])
					unknownTime = YES;
				[loadedEvent setObject:timeString forKey:kCalendarEventsLocalizedTimeStringKey];
			}
		}
	}
	[loadedEvent setObject:[NSNumber numberWithBool:unknownTime] forKey:kCalendarEventsUnknownTimeKey];
	
	NSArray *participants = [loadedEvent objectForKey:kCalendarEventsParticipantsKey];
	if (participants) {
		NSDictionary *participant = [participants findWhereKeyPath:kCalendarEventsParticipantTypeKey equals:@"committee"];
		if (participant)
			[loadedEvent setObject:[participant objectForKey:kCalendarEventsParticipantNameKey] forKey:kCalendarEventsCommitteeNameKey];
	}
	
	NSString *description = [loadedEvent objectForKey:kCalendarEventsDescriptionKey];
	
	BOOL canceled = NO;
	if (description && [description hasSubstring:@"(canceled)" caseInsensitive:YES])
		canceled = YES;
	[loadedEvent setObject:[NSNumber numberWithBool:canceled] forKey:kCalendarEventsCanceledKey];
	
	return loadedEvent;
}

- (NSArray *)commiteeeMeetingsForChamber:(NSInteger)chamber {
	if (!self.events || ![_events count])
		return nil;
	
	NSArray *meetings = [_events findAllWhereKeyPath:kCalendarEventsTypeKey equals:kCalendarEventsTypeCommitteeValue];
	if (meetings && [meetings count]) {
		NSMutableArray *chamberMeetings = [NSMutableArray array];
		
		for (NSDictionary *meeting in meetings) {
			NSMutableDictionary *newMeeting = [NSMutableDictionary dictionaryWithDictionary:meeting];
			id sourcePath = [meeting valueForKeyPath:kCalendarEventsSourceURLKeyPath];
			NSString *sourceURL = nil;
			if ([sourcePath isKindOfClass:[NSArray class]])
				sourceURL = [sourcePath objectAtIndex:0];
			else if ([sourcePath isKindOfClass:[NSString class]])
				sourceURL = sourcePath;
			
			for (NSInteger eventChamber = HOUSE; eventChamber<=JOINT; eventChamber++) {
				NSString *guessString = [stringForChamber(eventChamber, TLReturnFull) lowercaseString];
				if ([sourceURL hasSuffix:guessString]) {
					if (chamber == BOTH_CHAMBERS || chamber == eventChamber) {
						[newMeeting setObject:[NSNumber numberWithInt:eventChamber] forKey:kCalendarEventsTypeChamberValue];
						[chamberMeetings addObject:[self parseEvent:newMeeting]];
					}
					break;
				}
			}
		}
		meetings = chamberMeetings;
	}
	return meetings;	
}


#pragma mark -
#pragma mark EventKit
- (void)addAllEventsToiCal:(id)sender {
#warning see about asking what calendar they want to put these in

	NSLog(@"CalendarEventsLoader == ADDING ALL MEETINGS TO ICAL == (MESSY)");
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"iCAL_ALL_MEETINGS"];

	NSArray *meetings = [self commiteeeMeetingsForChamber:BOTH_CHAMBERS];
	for (NSDictionary *meeting in meetings) {
		[self addEventToiCal:meeting delegate:nil];
	}
}

- (void)addEventToiCal:(NSDictionary *)eventDict delegate:(id)delegate {
	if (!eventDict)
		return;
	
	
	if (![UtilityMethods supportsEventKit] || !eventStore) {
		debug_NSLog(@"EventKit not available on this device");
		return;
	}
			
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
		event.title = [NSString stringWithFormat:@"%@ (CANCELLED)", event.title];
	
	event.location = [eventDict objectForKey:kCalendarEventsLocationKey];
	
	event.notes = @"[TexLege] Length of this meeting is only an estimate.";
	if (NO == IsEmpty([eventDict objectForKey:kCalendarEventsAnnouncementURLKey])) {
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
	
	if (!meetingDate || [[eventDict objectForKey:kCalendarEventsUnknownTimeKey] boolValue]) {
		debug_NSLog(@"Calendar Detail ... don't know the complete event time/date");
		event.allDay = YES; 
		if ([eventDict objectForKey:kCalendarEventsLocalizedDateKey]) {
			event.startDate = [eventDict objectForKey:kCalendarEventsLocalizedDateKey];
			event.endDate = [eventDict objectForKey:kCalendarEventsLocalizedDateKey];
		}
		event.location = [eventDict objectForKey:kCalendarEventsDescriptionKey];
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
		
	//if (!delegate)
	//	delegate = [[TexLegeAppDelegate appDelegate] detailNavigationController];
	
	if (delegate) {
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"iCAL_EVENT"];

		EKEventViewController *eventVC = [[EKEventViewController alloc] initWithNibName:nil bundle:nil];			
		eventVC.event = event;
		
		// Allow event editing.
		eventVC.allowsEditing = YES;
		
		//	Push eventViewController onto the navigation controller stack
		//	If the underlying event gets deleted, detailViewController will remove itself from
		//	the stack and clear its event property.
		[delegate pushViewController:eventVC animated:YES];
		[eventVC release];
	}
	[eventIDs release];
}	


@end
