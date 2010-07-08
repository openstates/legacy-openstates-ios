//
//  MapsDetailViewController.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

 
#import "Constants.h"

@interface MapsDetailViewController : UIViewController {
	NSURL *mapURL;
	IBOutlet UIWebView *webView;
	IBOutlet UISegmentedControl *commonMenuControl;
}

@property (nonatomic,retain) IBOutlet UISegmentedControl *commonMenuControl;
@property (nonatomic,retain) NSURL *mapURL;
@property (nonatomic,retain) IBOutlet UIWebView *webView;
	
- (void)setMapString:(NSString *)newString;

@end
