//
//  SLFEventsManager.h
//  Created by Greg Combs on 12/17/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface SLFEventsManager : NSObject <EKCalendarChooserDelegate>
@property (nonatomic,retain) EKEventStore *eventStore;
@property (nonatomic,retain) EKCalendar *eventCalendar;
+ (id)sharedManager;
- (EKEvent *)findOrCreateEventWithIdentifier:(NSString *)eventIdentifier;
- (EKEventEditViewController *)newEventEditorForEvent:(EKEvent *)event delegate:(id<EKEventEditViewDelegate>)delegate;
- (EKCalendarChooser *)newEventCalendarChooser:(id)sender;
@end

extern NSString * const SLFEventsManagerNotifyCalendarDidChange;