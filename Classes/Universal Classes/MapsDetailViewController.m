//
//  MapsDetailViewController.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "MapsDetailViewController.h"
#import "CommitteeObj.h"
#import "UtilityMethods.h"
#import "MiniBrowserController.h"

@interface MapsDetailViewController(Private)

// these are private methods that outside classes need not use
- (void)loadWebViewFromMapPDF;
- (void)loadWebViewFromURL:(NSURL *)url;
@end

@implementation MapsDetailViewController

@synthesize mapURL, webView;


- (id)init {
	if (self = [super init]) {

	}
	return self;
}

- (void)dealloc {
	self.webView = nil;
	self.mapURL = nil;
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	[[self navigationController] popToRootViewControllerAnimated:YES];

	self.webView = nil;
	self.mapURL = nil;
	
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)setMapURL:(NSURL *)newObj {
	//if (self.startupSplashView) {
	//	[self.startupSplashView removeFromSuperview];
	//}
	
	if (mapURL) [mapURL release], mapURL = nil;
	if (newObj) {
		mapURL = [newObj retain];

		//self.navigationItem.title = self.committee.committeeName;
		/*
		 if (self.popoverController != nil) {
		 [self.popoverController dismissPopoverAnimated:YES];
		 //self.popoverController = nil; // i think this breaks, unless you're in a showHide type of situation.
		 }        
		 
		 [self createSectionList];
		 */
		[self.webView loadRequest:[NSURLRequest requestWithURL:mapURL]];
		//[self.webView setNeedsDisplay];
		[self.view setNeedsDisplay];
	}

	
}

#pragma mark -
#pragma mark Load Detail Views

- (void)viewDidLoad {
	//[self.webView reload];
	self.hidesBottomBarWhenPushed = NO;
	[self.webView loadRequest:[NSURLRequest requestWithURL:mapURL]];

	//self.navigationController.toolbarHidden = YES;	

}

- (void)setMapString:(NSString *)newString {
	
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
	NSString *pdfPath = [ NSString stringWithFormat:
						 @"%@/%@.app/%@",NSHomeDirectory(),appName, newString ];
	self.navigationItem.title = [newString substringToIndex:[newString length]-4];

	self.mapURL = [NSURL fileURLWithPath:pdfPath];
}	



#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
	return YES;
}

@end
