//
//  MapsDetailViewController.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

 
#import "Constants.h"

@interface MapsDetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
	NSURL *mapURL;
	IBOutlet UIWebView *webView;
	
	UIPopoverController *popoverController;

}
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic,retain) NSURL *mapURL;
@property (nonatomic,retain) IBOutlet UIWebView *webView;
	
- (void)setMapString:(NSString *)newString;

@end
