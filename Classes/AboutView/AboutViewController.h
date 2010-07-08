//
//  AboutViewController.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs All rights reserved.
//

#import "Constants.h"

@protocol AboutViewControllerDelegate;


@interface AboutViewController : UIViewController <UIAlertViewDelegate> {
	id <AboutViewControllerDelegate> delegate;
	
	IBOutlet UITextView *textView;
	IBOutlet UILabel *versionLabel;
	IBOutlet UIView *infoView;
	IBOutlet UISegmentedControl *projectWebsiteButton;
	IBOutlet UIBarButtonItem *dismissButton;
	NSURL *projectWebsiteURL;

}

@property (nonatomic, assign) id <AboutViewControllerDelegate> delegate;
@property (nonatomic, retain) NSURL *projectWebsiteURL;
@property (nonatomic, retain) UILabel *versionLabel;
@property (nonatomic, retain) UIView *infoView;
@property (nonatomic, retain) UISegmentedControl *projectWebsiteButton;
@property (nonatomic, retain) UIBarButtonItem *dismissButton;
@property (nonatomic, retain) UITextView *textView;


- (IBAction)done:(id)sender;
- (IBAction)weblink_click:(id)sender;
- (void) alertViewWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle;
- (void) alertViewWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle otherTitle:(NSString *)otherTitle;
@end


@protocol AboutViewControllerDelegate
- (void)modalViewControllerDidFinish:(UIViewController *)controller;
@optional
- (IBAction)showOrHideAboutMenuPopover:(id)sender;
- (void)showAboutDialog:(UIViewController *)controller;
@end

