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
#import "MTInfoPanel.h"
#import <RestKit/RestKit.h>

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
        _eventCalendar = [[_eventStore defaultCalendarForNewEvents] retain];
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

- (void)loadEventCalendarFromPersistence {
    if (SLFIsIOS5OrGreater()) {
        if (!IsEmpty(SLFSelectedCalendar()))
            self.eventCalendar = [_eventStore calendarWithIdentifier:SLFSelectedCalendar()];
    }
    if (!_eventCalendar)
        _eventCalendar = [[_eventStore defaultCalendarForNewEvents] retain];
}

- (void)setEventCalendar:(EKCalendar *)eventCalendar {
    SLFRelease(_eventCalendar);
    _eventCalendar = [eventCalendar retain];
    if (!eventCalendar)
        return;
    SLFSaveSelectedCalendar(eventCalendar.calendarIdentifier);
    if (self.calendarChooserParent)
        [_calendarChooserParent calendarDidChange:eventCalendar];
}

- (EKEvent *)findOrCreateEventWithIdentifier:(NSString *)eventIdentifier {
    EKEvent *event = nil;
    if (!IsEmpty(eventIdentifier)) {
        event = [_eventStore eventWithIdentifier:eventIdentifier];
    }
    if (!event) {
        event = [EKEvent eventWithEventStore:_eventStore];
        event.calendar = [self eventCalendarOrDefault];
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
    __block SLFEventsManager *bself = self;
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!bself || !granted)
            return;
        bself.eventEditorParent = parent;
        EKEventEditViewController *editor = [bself newEventEditorForEvent:event delegate:bself];
        editor.view.width = parent.view.width;
        if (!SLFIsIpad()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [parent presentViewController:editor animated:YES completion:nil];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [parent stackOrPushViewController:editor];
            });
        }
        [editor release];
    }];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    EKEvent *event = controller.event;
    if (action == EKEventEditViewActionSaved) {
        if (!event || NO == [self saveEvent:event])
            [MTInfoPanel showPanelInView:self.eventEditorParent.view type:MTInfoPanelTypeError title:NSLocalizedString(@"Error Saving Event",@"") subtitle:NSLocalizedString(@"Unable to save this event to your calendar.  Please double-check your calendar settings and permissions then try again.",@"") hideAfter:3];
        else if (self.eventEditorParent)
            [_eventEditorParent eventWasEdited:event];
    }
    if (!SLFIsIpad()) {
        if (!SLFIsIOS5OrGreater())
            [controller dismissViewControllerAnimated:YES completion:NULL];
        else
            [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else
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

- (EKCalendar *)eventCalendarOrDefault
{
    if (!self.eventCalendar)
        return [self.eventStore defaultCalendarForNewEvents];
    return self.eventCalendar;
}

- (EKCalendarChooser *)newEventCalendarChooser:(id)sender {
    if (!SLFIsIOS5OrGreater())
        return nil;
    EKCalendarChooser *chooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleSingle displayStyle:EKCalendarChooserDisplayWritableCalendarsOnly eventStore:_eventStore];
    chooser.delegate = self;
    chooser.showsDoneButton = YES;
    chooser.showsCancelButton = YES;
    EKCalendar *calendar = [self eventCalendarOrDefault];
    if (calendar)
    {
        chooser.selectedCalendars = [NSSet setWithObject:calendar];
    }
    return chooser;
}

- (void)calendarChooserSelectionDidChange:(EKCalendarChooser *)calendarChooser {
    EKCalendar *calendar = [calendarChooser.selectedCalendars anyObject];
    if (!calendar)
        return;
    self.eventCalendar = calendar;
}

- (void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser {
    EKCalendar *calendar = [calendarChooser.selectedCalendars anyObject];
    if (calendar)
        self.eventCalendar = calendar;
    [self.calendarChooserParent popToThisViewController];
    self.calendarChooserParent = nil;
}

- (void)calendarChooserDidCancel:(EKCalendarChooser *)calendarChooser {
    [self.calendarChooserParent popToThisViewController];
    self.calendarChooserParent = nil;
}

@end
