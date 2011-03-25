//
//  CalendarEventsLoader.h
//  TexLege
//
//  Created by Gregory Combs on 3/18/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import <EventKit/EventKit.h>
#import <RestKit/RestKit.h>

#define kCalendarEventsNotifyError	@"CALENDAR_EVENTS_ERROR"
#define kCalendarEventsNotifyLoaded	@"CALENDAR_EVENTS_LOADED"

#define kCalendarEventsCacheFile		@"TexLegeEventsCache.plist"
#define kTLEventKitKey					@"TLEventKit"
#define kTLEventKitEKIDKey				@"TLEventEKID"
#define kTLEventKitTLIDKey				@"TLEventTLID"
#define kTLEventKitStoreKey				@"TLEventStore"

@interface CalendarEventsLoader : NSObject <RKRequestDelegate> {
	NSMutableArray *_events;
	BOOL isFresh;
	NSDate *updated;
	
	EKEventStore *eventStore;
}
+ (CalendarEventsLoader *)sharedCalendarEventsLoader;
- (void)loadEvents:(id)sender;
- (NSArray *)commiteeeMeetingsForChamber:(NSInteger)chamber;
- (void)addEventToiCal:(NSDictionary *)eventDict delegate:(id)delegate;
- (void)addAllEventsToiCal:(id)sender;

@property (nonatomic,readonly) NSArray *events;
@property (nonatomic) BOOL isFresh;

#define kCalendarEventsIDKey				@"id"
#define kCalendarEventsWhenKey				@"when"			// In UTC ... so subtract for local time zone
#define kCalendarEventsEndKey				@"end"			// In UTC ... so subtract for local time zone
#define kCalendarEventsDescriptionKey		@"description"
#define kCalendarEventsLocationKey			@"location"
#define kCalendarEventsTypeKey				@"type"			// we want to limit this to "committee:meeting"
#define kCalendarEventsSourceURLKeyPath		@"sources.url"
#define kCalendarEventsAnnouncementURLKey	@"link"
#define kCalendarEventsNotesKey				@"notes"		// holdes the ascii text of the announcement

#define kCalendarEventsLocalizedDateKey				@"date"			// NSDate in local time zone
#define kCalendarEventsLocalizedDateStringKey		@"dateString"	// 12/31/11
#define kCalendarEventsLocalizedTimeStringKey		@"timeString"	// 12:31pm
#define kCalendarEventsAllDayKey					@"all_day"		// BOOL = true if we can't parse a time from the header
#define kCalendarEventsCanceledKey					@"canceled"		// BOOL = true if the event has been cancelled
#define kCalendarEventsStatusKey					@"status"		// BOOL = true if the event has been cancelled

#define kCalendarEventsParticipantsKey			@"participants"			//Array of participant dictionaries
#define kCalendarEventsParticipantNameKey		@"participant"			//name of the participant
#define kCalendarEventsParticipantTypeKey		@"type"					//name of the participant
#define kCalendarEventsParticipantNameKeyPath	@"participants.participant"	// assuming type = "committee:meeting"
#define kCalendarEventsParticipantChamberKeyPath @"participants.chamber"	// assuming type = "committee:meeting"
#define kCalendarEventsParticipantTypeKeyPath	@"participants.type"	// assuming type = "committee:meeting"
#define kCalendarEventsCommitteeNameKey			@"committee"			//simplified access to participants name in case of committees
#define kCalendarEventsTypeCommitteeValue		@"committee:meeting"
#define kCalendarEventsTypeChamberValue			@"chamber"				// NSNumber of chamber

@end
