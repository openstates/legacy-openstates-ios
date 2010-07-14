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

@implementation MapsDetailViewController

@synthesize map, webView;
@synthesize popoverController;


- (void)dealloc {
	self.webView = nil;
	self.map = nil;
	self.popoverController = nil;
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	[[self navigationController] popToRootViewControllerAnimated:YES];

	self.webView = nil;
	self.map = nil;
	
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)setMap:(CapitolMap *)newObj {
	
	if (map) [map release], map = nil;
	if (newObj) {
		map = [newObj retain];

		if (popoverController != nil)
			[popoverController dismissPopoverAnimated:YES];
		
		self.navigationItem.title = map.name;
		[self.webView loadRequest:[NSURLRequest requestWithURL:map.url]];
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
	
	if (self.map) {
		self.navigationItem.title = map.name;
		[self.webView loadRequest:[NSURLRequest requestWithURL:map.url]];
	}
	else
		self.navigationItem.title = @"Maps";

	//self.navigationController.toolbarHidden = YES;	
}
/*
- (void)viewWillAppear:(BOOL)animated {
	[self showPopoverMenus:([UtilityMethods isLandscapeOrientation] == NO)];
}
*/

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
