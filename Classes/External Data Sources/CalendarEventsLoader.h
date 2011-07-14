//
//  CalendarEventsLoader.h
//  Created by Gregory Combs on 3/18/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <RestKit/RestKit.h>
#import "Kal.h"

#define kCalendarEventsNotifyError	@"CALENDAR_EVENTS_ERROR"
#define kCalendarEventsNotifyLoaded	KalDataSourceChangedNotification 
									// @"CALENDAR_EVENTS_LOADED"

#define kCalendarEventsCacheFile		@"EventsCache.plist"
#define kTLEventKitKey					@"TLEventKit"
#define kTLEventKitEKIDKey				@"TLEventEKID"
#define kTLEventKitTLIDKey				@"TLEventTLID"
#define kTLEventKitStoreKey				@"TLEventStore"

@interface CalendarEventsLoader : NSObject <RKRequestDelegate> {
	NSMutableArray *_events;
	NSString *eventState;
	NSDate *updated;
	BOOL isLoading;
	NSInteger loadingStatus;

	EKEventStore *eventStore;
}

+ (CalendarEventsLoader *)sharedCalendarEventsLoader;
- (void)loadEvents:(id)sender;

- (NSArray *)calendarEventsForType:(NSString *)eventType;

- (void)addEventToiCal:(NSDictionary *)eventDict delegate:(id)delegate;
- (void)addAllEventsToiCal:(id)sender;

@property (nonatomic,readonly) NSArray *events;
@property (nonatomic,readonly) BOOL isFresh;		// have we updated recently?
@property (nonatomic) NSInteger loadingStatus;		// used to trigger UI elements indicating "loading" or "error"

@end

/***** Event Dictionary Keys : most of these are native to the Open States API *****/

#define kCalendarEventsIDKey					@"id"				// Event ID from open states
#define kCalendarEventsWhenKey					@"when"				// In UTC ... so subtract for local time zone
#define kCalendarEventsEndKey					@"end"				// In UTC ... so subtract for local time zone
#define kCalendarEventsDescriptionKey			@"description"
#define kCalendarEventsLocationKey				@"location"
#define kCalendarEventsTypeKey					@"type"				// as in "committee:meeting"
#define kCalendarEventsSourcesKey				@"sources"
#define kCalendarEventsURLKey					@"url"
#define kCalendarEventsAnnouncementURLKey		@"link"
#define kCalendarEventsNotesKey					@"notes"			// holdes the ascii text of the announcement

#define kCalendarEventsAllDayKey				@"all_day"			// BOOL = true if we can't parse a time from the header
#define kCalendarEventsCanceledKey				@"canceled"			// BOOL = true if the event has been cancelled
#define kCalendarEventsStatusKey				@"status"			// BOOL = true if the event has been cancelled

#define kCalendarEventsParticipantsKey			@"participants"		//Array of participant dictionaries
#define kCalendarEventsParticipantNameKey		@"participant"		//name of the participant
#define kCalendarEventsParticipantTypeKey		@"type"				//name of the participant
#define kCalendarEventsTypeCommitteeValue		@"committee:meeting"

// Convenience definitions to expedite retrieving values of interest, assuming type = "committee:meeting"
#define kCalendarEventsParticipantNameKeyPath		@"participants.participant"
#define kCalendarEventsParticipantChamberKeyPath	@"participants.chamber"
#define kCalendarEventsParticipantTypeKeyPath		@"participants.type"

// Custom keys that are specific to our own event standardization process
#define kCalendarEventsCommitteeNameKey				@"committee"		// Direct access to participants name in case of committees
#define kCalendarEventsTypeChamberValue				@"chamber"			// NSNumber of chamber
#define kCalendarEventsLocalizedStartDateKey		@"date"				// NSDate for event start in local time zone
#define kCalendarEventsLocalizedEndDateKey			@"date_end"			// NSDate for event end in local time zone
#define kCalendarEventsLocalizedDateStringKey		@"dateString"		// 12/31/11
#define kCalendarEventsLocalizedTimeStringKey		@"timeString"		// 12:31pm
#define kCalendarEventsSummaryTextKey				@"summaryText"		// A "Who, What, When, Where" summary for display
#define kCalendarEventsTitleKey						@"title"			// A short description of the event

NSComparisonResult sortByDate(id firstItem, id secondItem, void *context);
