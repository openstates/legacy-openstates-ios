//
//  SLFEventsManager.h
//  Created by Greg Combs on 12/17/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@protocol SLFEventsManagerDelegate <NSObject>
@required
- (void)calendarDidChange:(EKCalendar *)calendar;
- (void)eventWasEdited:(EKEvent *)event;
@end

@interface SLFEventsManager : NSObject <EKCalendarChooserDelegate, EKEventEditViewDelegate>
@property (nonatomic,retain) EKEventStore *eventStore;
@property (nonatomic,retain) EKCalendar *eventCalendar;
+ (id)sharedManager;
- (EKEvent *)findOrCreateEventWithIdentifier:(NSString *)eventIdentifier;
- (BOOL)saveEvent:(EKEvent *)event;
- (void)presentEventEditorForEvent:(EKEvent *)event fromParent:(UIViewController <StackableController,SLFEventsManagerDelegate> *)parent;
- (void)presentCalendarChooserFromParent:(UIViewController <StackableController, SLFEventsManagerDelegate> *)parent;
- (void)loadEventCalendarFromPersistence;
@end
