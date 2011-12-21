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
#import "MKInfoPanel.h"

NSString * const SLFEventsManagerNotifyCalendarDidChange = @"SLFEventsManagerNotifyCalendarDidChange";

@interface SLFEventsManager()
@property (nonatomic,retain) UIViewController <StackableController,SLFEventsManagerDelegate> *eventEditorParent;
@property (nonatomic,retain) UIViewController <StackableController,SLFEventsManagerDelegate> *calendarChooserParent;
- (EKEventEditViewController *)newEventEditorForEvent:(EKEvent *)event delegate:(id<EKEventEditViewDelegate>)delegate;
- (EKCalendarChooser *)newEventCalendarChooser:(id)sender;
@end

@implementation SLFEventsManager
@synthesize eventStore = _eventStore;
@synthesize eventCalendar = _eventCalendar;
@synthesize eventEditorParent = _eventEditorParent;
@synthesize calendarChooserParent = _calendarChooserParent;

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
    self.eventEditorParent = nil;
    self.calendarChooserParent = nil;
    [super dealloc];
}

- (void)setEventCalendar:(EKCalendar *)eventCalendar {
    SLFRelease(_eventCalendar);
    _eventCalendar = [eventCalendar retain];
    if (eventCalendar && self.calendarChooserParent) {
        [_calendarChooserParent calendarDidChange:eventCalendar];
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

- (BOOL)saveEvent:(EKEvent *)event {
    NSParameterAssert(event != NULL);
    NSError *error = nil;
    BOOL success = [_eventStore saveEvent:event span:EKSpanThisEvent error:&error];
    if (error) {
        RKLogError(@"Error while attempting to save a calendar event: %@ (%@)", event, [error localizedDescription]);
    }
    return success;
}

- (EKEventEditViewController *)newEventEditorForEvent:(EKEvent *)event delegate:(id<EKEventEditViewDelegate>)delegate {
    EKEventEditViewController * controller = [[EKEventEditViewController alloc] init];
    controller.eventStore       = _eventStore;
    controller.event            = event;
    controller.editViewDelegate = delegate;
    return controller;
}

- (void)presentEventEditorForEvent:(EKEvent *)event fromParent:(UIViewController <StackableController,SLFEventsManagerDelegate> *)parent {
    if (!event)
        return;
    self.eventEditorParent = parent;
    EKEventEditViewController *editor = [self newEventEditorForEvent:event delegate:self];
    editor.view.width = parent.view.width;
    [parent stackOrPushViewController:editor];
    [editor release];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    EKEvent *event = controller.event;
    if (action == EKEventEditViewActionSaved) {
        if (!event || NO == [self saveEvent:event])
            [MKInfoPanel showPanelInView:self.eventEditorParent.view type:MKInfoPanelTypeError title:NSLocalizedString(@"Error Saving Event",@"") subtitle:NSLocalizedString(@"Unable to save this event to your calendar.  Please double-check your calendar settings and permissions then try again.",@"") hideAfter:3];
        else if (self.eventEditorParent)
            [_eventEditorParent eventWasEdited:event];
    }
    [self.eventEditorParent popToThisViewController];
    self.eventEditorParent = nil;
}

- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
    return [[SLFEventsManager sharedManager] eventCalendar];
}

- (void)presentCalendarChooserFromParent:(UIViewController <StackableController,SLFEventsManagerDelegate> *)parent {
    if (!SLFIsIOS5OrGreater())
        return;
    self.calendarChooserParent = parent;
    EKCalendarChooser *chooser = [self newEventCalendarChooser:parent];
    UIViewController *viewControllerToPush = chooser;
    if (SLFIsIpad()) {
        chooser.title = NSLocalizedString(@"Select a Calendar", @"");
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:chooser];
        nav.view.width = parent.view.width;
        [chooser release];
        viewControllerToPush = nav;
    }
    [parent stackOrPushViewController:viewControllerToPush];
    [viewControllerToPush release];
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
    self.eventCalendar = [calendarChooser.selectedCalendars anyObject];
}

- (void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser {
    self.eventCalendar = [calendarChooser.selectedCalendars anyObject];
    [self.calendarChooserParent popToThisViewController];
    self.calendarChooserParent = nil;
}

- (void)calendarChooserDidCancel:(EKCalendarChooser *)calendarChooser {
    [self.calendarChooserParent popToThisViewController];
    self.calendarChooserParent = nil;
}

@end
