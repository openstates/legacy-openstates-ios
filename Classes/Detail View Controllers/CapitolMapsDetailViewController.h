//
//  CapitolMapsDetailViewController.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

 
#import "CapitolMap.h"

@interface CapitolMapsDetailViewController : UIViewController <UISplitViewControllerDelegate> {
}
@property (nonatomic,retain) CapitolMap *map;
@property (nonatomic,retain) IBOutlet UIWebView *webView;
@property (nonatomic,retain) UIPopoverController *masterPopover;
@end
