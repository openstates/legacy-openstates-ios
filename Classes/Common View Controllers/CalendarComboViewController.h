//
//  CalendarComboViewController.h
//  TexLege
//
//  Created by Gregory Combs on 7/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <TapkuLibrary/TapkuLibrary.h>

@interface CalendarComboViewController : TKCalendarComboViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
	UIPopoverController *popoverController;
	NSArray *feedEntries;
	
	NSMutableArray *currentEvents;

}
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) NSArray *feedEntries;
@property (nonatomic, retain) NSMutableArray *currentEvents;

@end
