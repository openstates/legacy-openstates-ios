//
//  CalendarDetailViewController.h
//  TexLege
//
//  Created by Gregory Combs on 7/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <TapkuLibrary/TapkuLibrary.h>

@class ChamberCalendarObj;

@interface CalendarDetailViewController : TKCalendarMonthTableViewController <UISplitViewControllerDelegate> {

}
@property (nonatomic, retain) IBOutlet UIImageView *leftShadow, *rightShadow;
@property (nonatomic, retain) IBOutlet UIImageView *portShadow, *landShadow;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) ChamberCalendarObj *chamberCalendar;
@property (nonatomic, retain) NSArray *feedEntries;
@property (nonatomic, retain) NSMutableArray *currentEvents;
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, retain) UIPopoverController *masterPopover;


@end
