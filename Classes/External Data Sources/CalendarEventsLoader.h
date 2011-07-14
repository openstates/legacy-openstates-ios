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
//@"CALENDAR_EVENTS_LOADED"

#define kCalendarEventsCacheFile		@"EventsCache.plist"
#define kTLEventKitKey					@"TLEventKit"
#define kTLEventKitEKIDKey				@"TLEventEKID"
#define kTLEventKitTLIDKey				@"TLEventTLID"
#define kTLEventKitStoreKey				@"TLEventStore"

@interface CalendarEventsLoader : NSObject <RKRequestDelegate> {
	NSMutableArray *_events;
	NSString *eventState;
	
	BOOL isFresh, isLoading;
	NSDate *updated;
	
	NSInteger loadingStatus;

	EKEventStore *eventStore;
}
+ (CalendarEventsLoader *)sharedCalendarEventsLoader;
- (void)loadEvents:(id)sender;

- (NSArray *)calendarEventsForType:(NSString *)eventType;
- (void)addEventToiCal:(NSDictionary *)eventDict delegate:(id)delegate;
- (void)addAllEventsToiCal:(id)sender;

@property (nonatomic,readonly) NSArray *events;
@property (nonatomic) BOOL isFresh;
@property (nonatomic) NSInteger loadingStatus;

#define kCalendarEventsIDKey				@"id"
#define kCalendarEventsWhenKey				@"when"			// In UTC ... so subtract for local time zone
#define kCalendarEventsEndKey				@"end"			// In UTC ... so subtract for local time zone
#define kCalendarEventsDescriptionKey		@"description"
#define kCalendarEventsLocationKey			@"location"
#define kCalendarEventsTypeKey				@"type"			// we want to limit this to "committee:meeting"
#define kCalendarEventsSourceURLKeyPath		@"sources.url"
#define kCalendarEventsAnnouncementURLKey	@"link"
#define kCalendarEventsNotesKey				@"notes"		// holdes the ascii text of the announcement

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

// CUSTOM
#define kCalendarEventsLocalizedDateKey				@"date"			// NSDate in local time zone
#define kCalendarEventsLocalizedDateStringKey		@"dateString"	// 12/31/11
#define kCalendarEventsLocalizedTimeStringKey		@"timeString"	// 12:31pm
#define kCalendarEventsSummaryTextKey				@"summaryText"
@end

NSComparisonResult sortByDate(id firstItem, id secondItem, void *context);
