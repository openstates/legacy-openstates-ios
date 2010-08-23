//
//  CommonPopoversController.m
//  TexLege
//
//  Created by Gregory Combs on 8/9/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "CommonPopoversController.h"
#import "TexLegeAppDelegate.h"
#import "UtilityMethods.h"


@implementation CommonPopoversController

#pragma mark -
#pragma mark Properties
SYNTHESIZE_SINGLETON_FOR_CLASS(CommonPopoversController);

@synthesize masterListPopoverPC;
@synthesize currentMasterViewController;
@synthesize currentDetailViewController;
@synthesize isOpening;

#pragma mark -
#pragma mark Initialization & Memory Management
- (id) init
{
    if ((self = [super init]))
    {
		self.isOpening = NO;
		
		self.masterListPopoverPC = nil;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) 
													 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    }
    return self;
}


/* dealloc */
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];

    self.masterListPopoverPC = nil;
	
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors

/* currentMasterViewController */
- (UIViewController *) currentMasterViewController { return [[TexLegeAppDelegate appDelegate] currentMasterViewController]; }

/* currentDetailViewController */
- (UIViewController *) currentDetailViewController { return [[TexLegeAppDelegate appDelegate] currentDetailViewController]; }


#pragma mark -
#pragma mark Popover Menu Management

// before this we should listen for rotations and invalidate menu items in the appropriate controllers
// This would happen on rotations or on new menu selections with a VC change
- (IBAction)resetPopoverMenus:(id)sender {
	if (![UtilityMethods isIPadDevice])
		return;
	
	[self dismissMasterListPopover:sender];
	
	BOOL masterSplitVisible = ([UtilityMethods isLandscapeOrientation]);
	UIViewController *commander = masterSplitVisible ? self.currentMasterViewController : self.currentDetailViewController; 
	if (!commander) {
		debug_NSLog(@"CurrentMasterViewController or CurrentDetailViewController is empty. Popovers not possible.");
		return;
	}
		
	if (masterSplitVisible) {	// Don't show any menu buttons on the detail side of the split if we're in landscape
		[[self.currentDetailViewController navigationItem] setRightBarButtonItem:nil animated:YES];
		return;			// don't go any further if we don't need to show the other one.
	}
	
	NSString *buttonTitle = nil;
	if ([self.currentDetailViewController respondsToSelector:@selector(popoverButtonTitle)])
		buttonTitle = [self.currentDetailViewController performSelector:@selector(popoverButtonTitle)];
	if (buttonTitle) {
		UIBarButtonItem *masterListButton = [[UIBarButtonItem alloc] 
											 initWithTitle:buttonTitle style:UIBarButtonItemStyleBordered 
											 target:self action:@selector(displayMasterListPopover:)];
		[self.currentDetailViewController.navigationItem setRightBarButtonItem:masterListButton animated:YES];
		[masterListButton release], masterListButton = nil;
	}
			
}

#pragma mark MasterListPopover

- (IBAction)displayMasterListPopover:(id)sender {	
	if (!self.currentDetailViewController || ![UtilityMethods isIPadDevice])
		return;
			
	if (!self.masterListPopoverPC) {
		self.masterListPopoverPC = [[UIPopoverController alloc] initWithContentViewController:self.currentMasterViewController]; // (Autorelease??)
		self.masterListPopoverPC.delegate = (id<UIPopoverControllerDelegate>)self; //self.currentDetailViewController;	
	}
	UIBarButtonItem *menuButton = self.currentDetailViewController.navigationItem.rightBarButtonItem;

	if (!menuButton || !self.masterListPopoverPC) {
		debug_NSLog(@"Menu Button Item or Master List Popover Controller is unallocated ... cannot display master list popover.");
		return;		// should never happen?
	}
	self.isOpening = YES;
	[self.masterListPopoverPC presentPopoverFromBarButtonItem:menuButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	self.isOpening = NO;
	
	// now that the menu is displayed, let's reset the action so it's ready to go away again on demand
	[menuButton setTarget:self];
	[menuButton setAction:@selector(dismissMasterListPopover:)];
}


- (IBAction)dismissMasterListPopover:(id)sender {
	if (!self.masterListPopoverPC || !self.currentDetailViewController || ![UtilityMethods isIPadDevice] || self.isOpening)
		return;
		
	if (self.masterListPopoverPC)	{
		if ([self.masterListPopoverPC isPopoverVisible])
			[self.masterListPopoverPC dismissPopoverAnimated:YES];
		self.masterListPopoverPC = nil;
	}
	
	UIBarButtonItem *menuButton = self.currentDetailViewController.navigationItem.rightBarButtonItem;
	if (menuButton) {
		[menuButton setTarget:self];
		[menuButton setAction:@selector(displayMasterListPopover:)];
	}
}



#pragma mark -
#pragma mark Popover Controller Delegate

// Called on the delegate when the popover controller will dismiss the popover. Return NO to prevent the dismissal of the view.
//- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController;

// Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	// the user (not us) has dismissed the popover, let's cleanup.
	if ([popoverController isEqual:self.masterListPopoverPC])
		[self dismissMasterListPopover:nil];
	//else
	//	debug_NSLog(@"Unexpected condition, we received a unknown popover controller dismissal notification.");
}


#pragma mark -
#pragma mark Orientation Changes

- (void)deviceOrientationDidChange:(void*)object { 
	//UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	/*if (UIInterfaceOrientationIsLandscape(orientation)) {
		// do something
	} else {
		// do something else
	}*/
	
	/*
	if (self.masterListPopoverPC)
		[self dismissMasterListPopover:nil];
	*/
	[self resetPopoverMenus:nil];
}


@end
