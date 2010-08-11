//
//  AboutViewController.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs All rights reserved.
//

#import "Constants.h"

@protocol AboutViewControllerDelegate;


@interface AboutViewController : UIViewController {
	
}

@property (nonatomic, assign) IBOutlet id <AboutViewControllerDelegate> delegate;
@property (nonatomic, retain) NSURL *projectWebsiteURL;
@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UIButton *projectWebsiteButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *dismissButton;
@property (nonatomic, retain) IBOutlet UITextView *infoTextView;


- (IBAction)done:(id)sender;
- (IBAction)weblink_click:(id)sender;
@end

@protocol AboutViewControllerDelegate
- (void)modalViewControllerDidFinish:(UIViewController *)controller;
@optional
- (IBAction)showOrHideAboutMenuPopover:(id)sender;
- (void)showAboutDialog:(UIViewController *)controller;
@end

