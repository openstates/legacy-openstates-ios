//
//  CalendarDetailViewController.h
//  TexLege
//
//  Created by Gregory Combs on 7/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//
#import "Kal.h"
#import <EventKit/EventKit.h>

@class ChamberCalendarObj;
@class TexLegeNavBar;

@interface CalendarDetailViewController : KalViewController <UISplitViewControllerDelegate,UISearchDisplayDelegate,UITableViewDelegate, UIPopoverControllerDelegate> {
	id dataObject;
	UIPopoverController *masterPopover;
	UIPopoverController *eventPopover;
	
	IBOutlet UIWebView *webView;
	ChamberCalendarObj *chamberCalendar;
	
	CGRect selectedRowRect;
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
