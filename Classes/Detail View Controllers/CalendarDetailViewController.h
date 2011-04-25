//
//  CalendarDetailViewController.h
//  TexLege
//
//  Created by Gregory Combs on 7/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//
#import "Kal.h"

@class ChamberCalendarObj;

@interface CalendarDetailViewController : KalViewController <UISplitViewControllerDelegate,UISearchDisplayDelegate,UITableViewDelegate> {
	id dataObject;
	UIPopoverController *masterPopover;
	
	IBOutlet UIWebView *webView;
	ChamberCalendarObj *chamberCalendar;
}
@property (nonatomic, assign) id dataObject;
@property (nonatomic, retain) UIPopoverController *masterPopover;

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) ChamberCalendarObj *chamberCalendar;

+ (NSString *)nibName;


@end
