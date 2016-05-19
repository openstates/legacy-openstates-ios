//
//  SLFEventsManager.m
//  Created by Greg Combs on 12/17/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFEventsManager.h"
#import "SLFInfoView.h"
#import <SLFRestKit/RestKit.h>

@interface SLFEventsManager()
@property (nonatomic,strong) UIViewController <StackableController,SLFEventsManagerDelegate> *eventEditorParent;
@property (nonatomic,strong) UIViewController <StackableController,SLFEventsManagerDelegate> *calendarChooserParent;
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
        _eventCalendar = [_eventStore defaultCalendarForNewEvents];
    }
    return self;
}

- (void)dealloc {
    self.eventCalendar = nil;
}

- (void)loadEventCalendarFromPersistence {
    if (SLFIsIOS5OrGreater()) {
        NSString *selectedCal = SLFSelectedCalendar();
        if (selectedCal)
            self.eventCalendar = [_eventStore calendarWithIdentifier:selectedCal];
    }
    if (!_eventCalendar)
        _eventCalendar = [_eventStore defaultCalendarForNewEvents];
}

- (void)setEventCalendar:(EKCalendar *)eventCalendar {
    SLFRelease(_eventCalendar);
    _eventCalendar = eventCalendar;
    if (!eventCalendar)
        return;
    SLFSaveSelectedCalendar(eventCalendar.calendarIdentifier);
    if (self.calendarChooserParent)
        [_calendarChooserParent calendarDidChange:eventCalendar];
}

- (EKEvent *)findOrCreateEventWithIdentifier:(NSString *)eventIdentifier {
    EKEvent *event = nil;
    if (SLFTypeNonEmptyStringOrNil(eventIdentifier)) {
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
    __weak SLFEventsManager *bself = self;
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
    }];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    EKEvent *event = controller.event;
    if (action == EKEventEditViewActionSaved) {
        if (!event || NO == [self saveEvent:event])
            [SLFInfoView showInfoInView:self.eventEditorParent.view type:SLFInfoTypeError title:NSLocalizedString(@"Error Saving Event",@"") subtitle:NSLocalizedString(@"Unable to save this event to your calendar.  Please double-check your calendar settings and permissions then try again.",@"")  image:nil hideAfter:3];
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
        viewControllerToPush = nav;
    }
    [parent stackOrPushViewController:viewControllerToPush];
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
