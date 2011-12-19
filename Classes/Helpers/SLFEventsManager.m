//
//  SLFEventsManager.m
//  Created by Greg Combs on 12/17/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFEventsManager.h"

NSString * const SLFEventsManagerNotifyCalendarDidChange = @"SLFEventsManagerNotifyCalendarDidChange";

@implementation SLFEventsManager
@synthesize eventStore = _eventStore;
@synthesize eventCalendar = _eventCalendar;

+ (id)sharedManager
{
    static dispatch_once_t pred;
    static SLFEventsManager *foo = nil;
    dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
    return foo;
}

- (id)init {
    self = [super init];
    if (self) {
        _eventStore = [[EKEventStore alloc] init];
        self.eventCalendar = [_eventStore defaultCalendarForNewEvents];
    }
    return self;
}

- (void)dealloc {
    self.eventStore = nil;
    self.eventCalendar = nil;
    [super dealloc];
}

- (void)setEventCalendar:(EKCalendar *)eventCalendar {
    SLFRelease(_eventCalendar);
    _eventCalendar = [eventCalendar retain];
    if (eventCalendar) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SLFEventsManagerNotifyCalendarDidChange object:self userInfo:[NSDictionary dictionaryWithObject:eventCalendar forKey:@"calendar"]];
    }
}

- (EKEvent *)findOrCreateEventWithIdentifier:(NSString *)eventIdentifier {
    EKEvent *event = nil;
    if (!IsEmpty(eventIdentifier)) {
        event = [_eventStore eventWithIdentifier:eventIdentifier];
    }
    if (!event) {
        event = [EKEvent eventWithEventStore:_eventStore];
        event.calendar = _eventCalendar;
    }
    return event;
}

- (EKEventEditViewController *)newEventEditorForEvent:(EKEvent *)event delegate:(id<EKEventEditViewDelegate>)delegate {
    EKEventEditViewController * controller = [[EKEventEditViewController alloc] init];
    controller.eventStore       = _eventStore;
    controller.event            = event;
    controller.editViewDelegate = delegate;
    return controller;
}

- (EKCalendarChooser *)newEventCalendarChooser:(id)sender {
    if (!SLFIsIOS5OrGreater())
        return nil;
    EKCalendarChooser *chooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleSingle displayStyle:EKCalendarChooserDisplayWritableCalendarsOnly eventStore:_eventStore];
    chooser.delegate = self;
    chooser.showsDoneButton = YES;
    chooser.showsCancelButton = YES;
    return chooser;
}

- (void)calendarChooserSelectionDidChange:(EKCalendarChooser *)calendarChooser {
    if (SLFIsIpad())
        self.eventCalendar = [calendarChooser.selectedCalendars anyObject];
}

- (void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser {
    if (SLFIsIpad())
        return;
    self.eventCalendar = [calendarChooser.selectedCalendars anyObject];
    [calendarChooser dismissModalViewControllerAnimated:YES];
}

- (void)calendarChooserDidCancel:(EKCalendarChooser *)calendarChooser {
    if (SLFIsIpad())
        return;
    [calendarChooser dismissModalViewControllerAnimated:YES];
}

@end
