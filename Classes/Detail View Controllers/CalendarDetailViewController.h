//
//  CalendarDetailViewController.h
//  Created by Gregory Combs on 7/29/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//
#import "Kal.h"
#import <EventKit/EventKit.h>

@class ChamberCalendarObj;
@class TexLegeNavBar;

@interface CalendarDetailViewController : KalViewController <UISplitViewControllerDelegate,UISearchDisplayDelegate,UITableViewDelegate, UIPopoverControllerDelegate> {
}
@property (nonatomic, assign) id dataObject;
@property (nonatomic, retain) UIPopoverController *masterPopover;
@property (nonatomic, retain) UIPopoverController *eventPopover;

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) ChamberCalendarObj *chamberCalendar;
@property (nonatomic) CGRect selectedRowRect;

+ (NSString *)nibName;

- (void)presentEventEditorForEvent:(EKEvent *)event;
@end
