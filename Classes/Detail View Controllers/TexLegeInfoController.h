//
//  TexLegeInfoController.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs All rights reserved.
//


@protocol TexLegeInfoControllerDelegate;


@interface TexLegeInfoController : UIViewController {
	
}

@property (nonatomic, assign) IBOutlet id <TexLegeInfoControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *dismissButton;
@property (nonatomic, retain) IBOutlet UITextView *infoTextView;

- (NSString *)popoverButtonTitle;

- (IBAction)done:(id)sender;

@end

@protocol TexLegeInfoControllerDelegate
- (void)modalViewControllerDidFinish:(UIViewController *)controller;
@optional
- (void)showAboutDialog:(UIViewController *)controller;
@end

