//
//  CommonPopoversController.m
//  TexLege
//
//  Created by Gregory Combs on 8/9/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "CommonPopoversController.h"
#import "TexLegeAppDelegate.h"
#import "MenuPopoverViewController.h"
#import "UtilityMethods.h"


@implementation CommonPopoversController

#pragma mark -
#pragma mark Properties
SYNTHESIZE_SINGLETON_FOR_CLASS(CommonPopoversController);

@synthesize masterListPopoverPC;
@synthesize mainMenuPopoverPC;
@synthesize mainMenuPopoverVC;
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
		self.mainMenuPopoverPC = nil;
		
		if ([UtilityMethods isIPadDevice])
			self.mainMenuPopoverVC = [[MenuPopoverViewController alloc] initWithNibName:@"MenuPopoverViewController" bundle:nil];

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
    self.mainMenuPopoverPC = nil;
    self.mainMenuPopoverVC = nil;
	
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
	
	[self dismissMainMenuPopover:sender];
	[self dismissMasterListPopover:sender];
	
	BOOL masterSplitVisible = ([UtilityMethods isLandscapeOrientation]);
	UIViewController *commander = masterSplitVisible ? self.currentMasterViewController : self.currentDetailViewController; 
	if (!commander) {
		debug_NSLog(@"CurrentMasterViewController or CurrentDetailViewController is empty. Popovers not possible.");
		return;
	}
		
	UIBarButtonItem *mainMenuButton = [[UIBarButtonItem alloc]
									   initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered 
									   target:self action:@selector(displayMainMenuPopover:)];
	
	[commander.navigationItem setLeftBarButtonItem:mainMenuButton animated:YES];
	[mainMenuButton release], mainMenuButton = nil;
	
	if (masterSplitVisible) {	// Don't show any menu buttons on the detail side of the split if we're in landscape
		[[self.currentDetailViewController navigationItem] setLeftBarButtonItem:nil animated:YES];
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
	
	[self dismissMainMenuPopover:sender];		//  they want to show this popover, lets close up the other one if it's open.
		
	self.masterListPopoverPC = [[UIPopoverController alloc] initWithContentViewController:self.currentMasterViewController]; // (Autorelease??)
	self.masterListPopoverPC.delegate = (id<UIPopoverControllerDelegate>)self; //self.currentDetailViewController;		
	UIBarButtonItem *menuButton = self.currentDetailViewController.navigationItem.rightBarButtonItem;

	if (!menuButton || !self.masterListPopoverPC) {
		debug_NSLog(@"Menu Button Item or Master List Popover Controller is unallocated ... cannot display master list popover.");
		return;		// should never happen?
	}
	self.isOpening = YES;
	[self.masterListPopoverPC presentPopoverFromBarButtonItem:menuButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	self.isOpening = NO;
	
	// now that the menu is displayed, let's reset the action so it's ready to go away again on demand
	[menuButton setAction:@selector(dismissMasterListPopover:)];
}


- (IBAction)dismissMasterListPopover:(id)sender {
	if (!self.currentDetailViewController || ![UtilityMethods isIPadDevice] || self.isOpening)
		return;
		
	if (self.masterListPopoverPC)	{
		if ([self.masterListPopoverPC isPopoverVisible])
			[self.masterListPopoverPC dismissPopoverAnimated:YES];
		self.masterListPopoverPC = nil;
	}
	
	UIBarButtonItem *menuButton = self.currentDetailViewController.navigationItem.rightBarButtonItem;
	if (menuButton)
		[menuButton setAction:@selector(displayMasterListPopover:)];
}

#pragma mark MainMenuPopover

- (IBAction)displayMainMenuPopover:(id)sender {	
	if (!self.currentMasterViewController || ![UtilityMethods isIPadDevice])
		return;
	
	[self dismissMasterListPopover:sender];		//  they want to show this popover, lets close up the other one if it's open.
	
	BOOL masterSplitVisible = ([UtilityMethods isLandscapeOrientation]);	
	UIViewController *commander = masterSplitVisible ? self.currentMasterViewController : self.currentDetailViewController; 
	if (!commander) {
		debug_NSLog(@"CurrentMasterViewController or CurrentDetailViewController is empty. Popovers not possible.");
		return;
	}
	
	self.mainMenuPopoverPC = [[UIPopoverController alloc] initWithContentViewController:self.mainMenuPopoverVC]; // (Autorelease??)
	self.mainMenuPopoverPC.delegate = (id<UIPopoverControllerDelegate>)self; //self.currentDetailViewController;	
	UIBarButtonItem *menuButton = commander.navigationItem.leftBarButtonItem;
	
	if (!menuButton || !self.mainMenuPopoverPC) {
		debug_NSLog(@"Menu Button Item or Main Menu Popover Controller is unallocated ... cannot display main menu popover.");
		return;		// should never happen?
	}
	
	self.isOpening = YES;

	[self.mainMenuPopoverPC presentPopoverFromBarButtonItem:menuButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
	self.isOpening = NO;
	
	// now that the menu is displayed, let's reset the action so it's ready to go away again on demand
	[menuButton setAction:@selector(dismissMainMenuPopover:)];
}


- (IBAction)dismissMainMenuPopover:(id)sender {
	if (![UtilityMethods isIPadDevice] || self.isOpening)
		return;

	if (self.mainMenuPopoverPC)	{
		if ([self.mainMenuPopoverPC isPopoverVisible])
			[self.mainMenuPopoverPC dismissPopoverAnimated:YES];
		self.mainMenuPopoverPC = nil;
	}
	
	BOOL masterSplitVisible = ([UtilityMethods isLandscapeOrientation]);
	UIViewController *commander = masterSplitVisible ? self.currentMasterViewController : self.currentDetailViewController; 
	if (!commander) {
		debug_NSLog(@"CurrentMasterViewController or CurrentDetailViewController is empty. Popovers not possible.");
		return;
	}
	
	UIBarButtonItem *menuButton = commander.navigationItem.leftBarButtonItem;
	if (menuButton)
		[menuButton setAction:@selector(displayMainMenuPopover:)];
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
	else if ([popoverController isEqual:self.mainMenuPopoverPC])
		[self dismissMainMenuPopover:nil];
	else
		debug_NSLog(@"Unexpected condition, we received a unknown popover controller dismissal notification.");
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
	if (self.mainMenuPopoverPC)
		[self dismissMainMenuPopover:nil];
	*/
	[self resetPopoverMenus:nil];
}


@end
