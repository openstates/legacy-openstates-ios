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
@synthesize isOpening;

#pragma mark -
#pragma mark Initialization & Memory Management
- (id) init
{
    if ((self = [super init]))
    {
		self.isOpening = NO;
		
		self.masterListPopoverPC = nil;

		if ([UtilityMethods isIPadDevice])
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) 
													 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    }
    return self;
}


/* dealloc */
- (void) dealloc
{
	if ([UtilityMethods isIPadDevice])
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];

    self.masterListPopoverPC = nil;
	
    [super dealloc];
}

#pragma mark -
#pragma mark Popover Menu Management

// before this we should listen for rotations and invalidate menu items in the appropriate controllers
// This would happen on rotations or on new menu selections with a VC change
- (IBAction)resetPopoverMenus:(id)sender {
	if (![UtilityMethods isIPadDevice] || self.isOpening)
		return;
	
	BOOL animated = YES;
	if (!sender)
		animated = NO;
	
	
	[self dismissMasterListPopover:sender];
	
	UIViewController *detail = [[TexLegeAppDelegate appDelegate] currentDetailViewController];
	if ([UtilityMethods isLandscapeOrientation]) {	// Don't show any menu buttons on the detail side of the split if we're in landscape
		[[detail navigationItem] setRightBarButtonItem:nil animated:animated];
		return;			// don't go any further if we don't need to show the other one.
	}
	
	NSString *buttonTitle = nil;
	if ([detail respondsToSelector:@selector(popoverButtonTitle)])
		buttonTitle = [detail performSelector:@selector(popoverButtonTitle)];
	if (buttonTitle) {
		UIBarButtonItem *masterListButton = [[UIBarButtonItem alloc] 
											 initWithTitle:buttonTitle style:UIBarButtonItemStyleBordered 
											 target:self action:@selector(displayMasterListPopover:)];
		[detail.navigationItem setRightBarButtonItem:masterListButton animated:animated];
		[masterListButton release], masterListButton = nil;
	}
			
}

#pragma mark MasterListPopover

- (IBAction)displayMasterListPopover:(id)sender {	
	UIViewController *master = [[TexLegeAppDelegate appDelegate] currentMasterViewController];
	UIViewController *detail = [[TexLegeAppDelegate appDelegate] currentDetailViewController];

	if (!detail || ![UtilityMethods isIPadDevice])
		return;
			
	BOOL animated = YES;
	if (!sender)
		animated = NO;
		
	if (!self.masterListPopoverPC) {
		self.masterListPopoverPC = [[[UIPopoverController alloc] initWithContentViewController:master] autorelease];
		self.masterListPopoverPC.delegate = (id<UIPopoverControllerDelegate>)self; //self.currentDetailViewController;	
	}
	UIBarButtonItem *menuButton = detail.navigationItem.rightBarButtonItem;		
	if (!menuButton && [sender isKindOfClass:[UIBarButtonItem class]])
		menuButton = sender;
		
	if (!menuButton || !self.masterListPopoverPC) {
		debug_NSLog(@"Menu Button Item or Master List Popover Controller is unallocated ... cannot display master list popover.");
		debug_NSLog(@"Button Item :%@    Popover Controller: %@    sender: %@", menuButton, self.masterListPopoverPC, sender);
		return;		// should never happen?
	}
	self.isOpening = YES;
	[self.masterListPopoverPC presentPopoverFromBarButtonItem:menuButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:animated];
	self.isOpening = NO;
	
	// now that the menu is displayed, let's reset the action so it's ready to go away again on demand
	[menuButton setTarget:self];
	[menuButton setAction:@selector(dismissMasterListPopover:)];
}


- (IBAction)dismissMasterListPopover:(id)sender {
	UIViewController *detail = [[TexLegeAppDelegate appDelegate] currentDetailViewController];
		
	if (!self.masterListPopoverPC || !detail || ![UtilityMethods isIPadDevice] || self.isOpening)
		return;
	
	BOOL animated = YES;
	if (!sender)
		animated = NO;
		
	if (self.masterListPopoverPC)	{
		if ([self.masterListPopoverPC isPopoverVisible])
			[self.masterListPopoverPC dismissPopoverAnimated:animated];
		self.masterListPopoverPC = nil;
	}
	
	UIBarButtonItem *menuButton = detail.navigationItem.rightBarButtonItem;
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
		[self dismissMasterListPopover:popoverController];
}


#pragma mark -
#pragma mark Orientation Changes

- (void)deviceOrientationDidChange:(void*)object { 
	if (![UtilityMethods isIPadDevice])
		return;

/*	UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		UIViewController *detail = [[TexLegeAppDelegate appDelegate] currentDetailViewController];
		
		if ([UtilityMethods isLandscapeOrientation]) {	// Don't show any menu buttons on the detail side of the split if we're in landscape
			[[detail navigationItem] setRightBarButtonItem:nil animated:YES];
			return;			// don't go any further if we don't need to show the other one.
		}
	} else {
		// do something else
	}
	
	
	[self dismissMasterListPopover:nil];
*/	
	[self resetPopoverMenus:nil];
}


@end
