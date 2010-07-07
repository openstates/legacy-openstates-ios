//
//  MenuPopoverViewController.h
//  TexLege
//
//  Created by Gregory Combs on 7/3/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TexLegeAppDelegate.h"
@class AboutViewController;
@class VoteInfoViewController;
@class TexLegeAppDelegate;

@interface MenuPopoverViewController : UITableViewController <AboutViewControllerDelegate, VoteInfoViewControllerDelegate,
												UIPopoverControllerDelegate> {
	UIPopoverController *itemPopoverController;

@private
	IBOutlet TexLegeAppDelegate *appDelegate;
	IBOutlet AboutViewController *aboutViewController;
	IBOutlet VoteInfoViewController *voteInfoViewController;
	
}

@property (nonatomic, retain) UIPopoverController *itemPopoverController;
@property (nonatomic, retain) IBOutlet AboutViewController *aboutViewController;
@property (nonatomic, retain) IBOutlet VoteInfoViewController *voteInfoViewController;
@property (nonatomic, retain) IBOutlet TexLegeAppDelegate *appDelegate;
@end
