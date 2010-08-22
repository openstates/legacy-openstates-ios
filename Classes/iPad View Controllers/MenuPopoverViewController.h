//
//  MenuPopoverViewController.h
//  TexLege
//
//  Created by Gregory Combs on 7/3/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "TexLegeInfoController.h"

@class TexLegeAppDelegate;

@interface MenuPopoverViewController : UITableViewController <TexLegeInfoControllerDelegate,
												UIPopoverControllerDelegate> {
	
}

@property (nonatomic, retain) UIPopoverController *itemPopoverController;
@property (nonatomic, retain) IBOutlet TexLegeInfoController *aboutViewController;
@property (nonatomic, retain) IBOutlet TexLegeAppDelegate *appDelegate;

@end
