//
//  CapitolMapsDetailViewController.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "CapitolMapsDetailViewController.h"
#import "CapitolMapsMasterViewController.h"
#import "CommitteeObj.h"
#import "UtilityMethods.h"
#import "MiniBrowserController.h"
#import "TexLegeAppDelegate.h"
#import "CommonPopoversController.h"

@implementation CapitolMapsDetailViewController

@synthesize map, webView;


#pragma mark -
#pragma mark Intialization and Memory Management

- (void)viewDidLoad {
	self.hidesBottomBarWhenPushed = YES;
	
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


- (void)viewWillAppear:(BOOL)animated {
	//[[CommonPopoversController sharedCommonPopoversController] resetPopoverMenus:self];
	
	if ([UtilityMethods isIPadDevice] && !self.map && ![UtilityMethods isLandscapeOrientation])  {
		TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
		
		self.map = [[appDelegate capitolMapsMasterVC] selectObjectOnAppear];		

	}
	/*
	 if ([UtilityMethods isIPadDevice] && ![UtilityMethods isLandscapeOrientation] && !self.link) {
	 UIBarButtonItem *button = self.navigationItem.rightBarButtonItem;
	 
	 if (button)
	 debug_NSLog(@"no selection yet ... %@", button);
	 }
	 */
	
}


- (void)dealloc {
	self.webView = nil;
	self.map = nil;
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

		if ([UtilityMethods isIPadDevice]) {
			[[CommonPopoversController sharedCommonPopoversController] dismissMasterListPopover:self.navigationItem.rightBarButtonItem];
		}
				
		self.navigationItem.title = map.name;
		[self.webView loadRequest:[NSURLRequest requestWithURL:map.url]];
		[self.view setNeedsDisplay];
	}
}


#pragma mark -
#pragma mark Popover Support

- (NSString*)popoverButtonTitle {
	return  @"Maps";
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc 
	 willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem 
	   forPopoverController: (UIPopoverController*)pc {
	
	//[self showMasterListPopoverButtonItem:barButtonItem];
	
    //self.popoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc 
	 willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	
	//[self invalidateMasterListPopoverButtonItem:barButtonItem];
	//self.popoverController = nil;
}

- (void) splitViewController:(UISplitViewController *)svc popoverController: (UIPopoverController *)pc
   willPresentViewController: (UIViewController *)aViewController
{
/*    if (pc != nil) {
        [[TexLegeAppDelegate appDelegate] dismissMasterListPopover:self.navigationItem.rightBarButtonItem];
    }
*/
}


#pragma mark -
#pragma mark Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//	[[TexLegeAppDelegate appDelegate] resetPopoverMenus];
	[self.webView reload];
}


@end
