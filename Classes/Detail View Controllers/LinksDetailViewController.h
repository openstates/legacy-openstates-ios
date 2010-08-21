//
//  LinksDetailViewController.h
//  TexLege
//
//  Created by Gregory Combs on 8/12/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "LinkObj.h"

@class MiniBrowserController, TexLegeInfoController;
@interface LinksDetailViewController : UIViewController <UISplitViewControllerDelegate> {
	
}

@property (nonatomic,retain) LinkObj *link;
@property (nonatomic,retain) IBOutlet MiniBrowserController *miniBrowser;
@property (nonatomic,retain) IBOutlet TexLegeInfoController *aboutControl;

- (NSString *)popoverButtonTitle;
@end
