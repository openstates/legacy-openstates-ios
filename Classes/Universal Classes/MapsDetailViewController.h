//
//  MapsDetailViewController.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

 
#import "Constants.h"
#import "CapitolMap.h"

@interface MapsDetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
	CapitolMap *map;
	IBOutlet UIWebView *webView;	
	UIPopoverController *popoverController;
}
@property (nonatomic,retain) UIPopoverController *popoverController;
@property (nonatomic,retain) CapitolMap *map;
@property (nonatomic,retain) IBOutlet UIWebView *webView;

@end
