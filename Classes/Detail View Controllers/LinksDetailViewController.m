    //
//  LinksDetailViewController.m
//  TexLege
//
//  Created by Gregory Combs on 8/12/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "LinksDetailViewController.h"
#import "UtilityMethods.h"
#import "MiniBrowserController.h"
#import "TexLegeEmailComposer.h"
#import "CommonPopoversController.h"
#import "TexLegeTheme.h"
#import "TexLegeAppDelegate.h"
#import "TableDataSourceProtocol.h"
@implementation LinksDetailViewController
@synthesize link, miniBrowser, aboutControl;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		
		UIImage *sealImage = [UIImage imageNamed:@"seal.png"];
		UIColor *sealColor = [UIColor colorWithPatternImage:sealImage];		
		[self.view setBackgroundColor:sealColor];

		[self.view setOpaque:YES];
		self.navigationController.navigationBar.backgroundColor = [TexLegeTheme navbar];
		
    }
    return self;
}


- (void)viewDidLoad {	
	
/*	if (self.link) {
		self.navigationItem.title = link.label;
		//[self.webView loadRequest:[NSURLRequest requestWithURL:map.url]];
	}
	else
*/
	self.navigationItem.title = @"Resources";
}



- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	self.miniBrowser = nil;
	self.aboutControl = nil;

}


- (void)dealloc {
    [super dealloc];
	self.miniBrowser = nil;
	self.link = nil;
	self.aboutControl = nil;
}



- (void)viewWillAppear:(BOOL)animated {
	[[CommonPopoversController sharedCommonPopoversController] resetPopoverMenus:self];
	
	if ([UtilityMethods isIPadDevice] && ![UtilityMethods isLandscapeOrientation] && !self.link) {
		UIBarButtonItem *button = self.navigationItem.rightBarButtonItem;
		
		if (button)
			debug_NSLog(@"no selection yet ... %@", button);
	}
	
}


- (void)setLink:(LinkObj *)newObj {
	
	if (link) [link release], link = nil;
	if (newObj) {
		link = [newObj retain];
		
		if ([UtilityMethods isIPadDevice]) {
			[[CommonPopoversController sharedCommonPopoversController] dismissMasterListPopover:self.navigationItem.rightBarButtonItem];
		}
		
		if ([self.link.url isEqualToString:@"aboutView"]) {
			self.miniBrowser = nil;
			if (!self.aboutControl)
				self.aboutControl = [[AboutViewController alloc] initWithNibName:@"TexLegeInfo~ipad" bundle:nil];
			//[self.navigationController pushViewController:self.aboutControl animated:NO];
			[[[TexLegeAppDelegate appDelegate] detailNavigationController] setViewControllers:[NSArray arrayWithObject:self.aboutControl] animated:NO];
//			[[TexLegeAppDelegate appDelegate] setCurrentDetailViewController:self.aboutControl];

			//[[TexLegeAppDelegate appDelegate] showAboutDialog:self];
		}
		else if ([self.link.url isEqualToString:@"contactMail"])
			[[TexLegeEmailComposer sharedTexLegeEmailComposer] presentMailComposerTo:
			 @"support@texlege.com" subject:@"TexLege Support Question" body:@""];
		
		else {
			self.aboutControl = nil;
			
			NSURL *aURL = [UtilityMethods safeWebUrlFromString:link.url];
			if (aURL && [UtilityMethods canReachHostWithURL:aURL alert:NO]) // got a network connection
			{
				if (!self.miniBrowser)
					self.miniBrowser = [[MiniBrowserController alloc] initWithNibName:@"MiniBrowserView" bundle:nil];
				self.miniBrowser.link = link;
				
				[[[TexLegeAppDelegate appDelegate] detailNavigationController] setViewControllers:[NSArray arrayWithObject:self.miniBrowser] animated:NO];
				debug_NSLog(@"mini browser %@", [self.miniBrowser description]);
				debug_NSLog(@"vc's %@", [self.navigationController viewControllers]);
				
				//[[TexLegeAppDelegate appDelegate] setCurrentDetailViewController:self.miniBrowser];
			}
			
		}
	}
}	

#pragma mark -
#pragma mark Popover Support

- (NSString*)popoverButtonTitle {
	return  @"Resources";
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

/*
 - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	//	[[TexLegeAppDelegate appDelegate] resetPopoverMenus];
	//[self.webView reload];
}

@end
