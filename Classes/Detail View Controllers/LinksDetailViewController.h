//
//  LinksDetailViewController.h
//  TexLege
//
//  Created by Gregory Combs on 8/12/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "LinkObj.h"

@class MiniBrowserController, AboutViewController;
@interface LinksDetailViewController : UIViewController <UISplitViewControllerDelegate> {
	
}

@property (nonatomic,retain) LinkObj *link;
@property (nonatomic,retain) IBOutlet MiniBrowserController *miniBrowser;
@property (nonatomic,retain) IBOutlet AboutViewController *aboutControl;

- (NSString *)popoverButtonTitle;
@end
