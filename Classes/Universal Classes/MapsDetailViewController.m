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
#import "TexLegeAppDelegate.h"

@interface MapsDetailViewController(Private)

// these are private methods that outside classes need not use
- (void)loadWebViewFromMapPDF;
- (void)loadWebViewFromURL:(NSURL *)url;
@end

@implementation MapsDetailViewController

@synthesize mapURL, webView;
@synthesize popoverController;


- (id)init {
	if (self = [super init]) {

	}
	return self;
}

- (void)dealloc {
	self.webView = nil;
	self.mapURL = nil;
	self.popoverController = nil;

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
	
	if (mapURL) [mapURL release], mapURL = nil;
	if (newObj) {
		mapURL = [newObj retain];

		if (popoverController != nil)
			[popoverController dismissPopoverAnimated:YES];

		[self.webView loadRequest:[NSURLRequest requestWithURL:mapURL]];
		[self.view setNeedsDisplay];
	}
}


#pragma mark -
#pragma mark Load Detail Views

- (void)viewDidLoad {
	//[self.webView reload];
	//self.hidesBottomBarWhenPushed = NO;
	UIImage *sealImage = [UIImage imageNamed:@"seal.png"];
	UIColor *sealColor = [UIColor colorWithPatternImage:sealImage];		
	[self.webView setBackgroundColor:[UIColor clearColor]];
	[self.webView setOpaque:NO];
	self.view.backgroundColor = sealColor;

	self.navigationItem.title = @"Maps";
	
	[self.webView loadRequest:[NSURLRequest requestWithURL:mapURL]];

	//self.navigationController.toolbarHidden = YES;	
}
/*
- (void)viewWillAppear:(BOOL)animated {
	[self showPopoverMenus:([UtilityMethods isLandscapeOrientation] == NO)];
}
*/
- (void)setMapString:(NSString *)newString {
	
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
	NSString *pdfPath = [ NSString stringWithFormat:
						 @"%@/%@.app/%@",NSHomeDirectory(),appName, newString ];
	self.navigationItem.title = [newString substringToIndex:[newString length]-4];

	self.mapURL = [NSURL fileURLWithPath:pdfPath];
}	

#pragma mark -
#pragma mark Popover Support

- (void)showMasterListPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    // Add the popover button to the left navigation item.
	barButtonItem.title = @"Maps";
    [self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
}

- (void)invalidateMasterListPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    // Remove the popover button.
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc 
	 willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem 
	   forPopoverController: (UIPopoverController*)pc {
	
	[self showMasterListPopoverButtonItem:barButtonItem];
	
    self.popoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc 
	 willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	
	[self invalidateMasterListPopoverButtonItem:barButtonItem];
	self.popoverController = nil;
}

- (void) splitViewController:(UISplitViewController *)svc popoverController: (UIPopoverController *)pc
   willPresentViewController: (UIViewController *)aViewController
{
    if (pc != nil) {
        [pc dismissPopoverAnimated:YES];
		// do I need to set pc to nil?  I need to confirm, but I think it breaks things.
    }
}


#pragma mark -
#pragma mark Orientation
/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self showPopoverMenus:UIDeviceOrientationIsPortrait(toInterfaceOrientation)];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
	return YES;
}

@end
