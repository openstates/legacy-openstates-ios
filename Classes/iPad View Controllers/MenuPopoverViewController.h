//
//  MenuPopoverViewController.h
//  TexLege
//
//  Created by Gregory Combs on 7/3/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "AboutViewController.h"

@class TexLegeAppDelegate;

@interface MenuPopoverViewController : UITableViewController <AboutViewControllerDelegate,
												UIPopoverControllerDelegate> {
	
}

@property (nonatomic, retain) UIPopoverController *itemPopoverController;
@property (nonatomic, retain) IBOutlet AboutViewController *aboutViewController;
@property (nonatomic, retain) IBOutlet TexLegeAppDelegate *appDelegate;

@end
