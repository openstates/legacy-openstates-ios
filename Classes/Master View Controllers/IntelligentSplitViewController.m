    //
//  IntelligentSplitViewController.m
//  TexLege
//
//  Created by Gregory Combs on 9/21/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "IntelligentSplitViewController.h"
#import <objc/message.h>

@implementation IntelligentSplitViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
			
    }
    return self;
}
*/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(willRotate:)
												 name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didRotate:)
												 name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
    [super viewDidUnload];

	[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIApplicationWillChangeStatusBarOrientationNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIApplicationDidChangeStatusBarOrientationNotification];
}

/*
- (void)dealloc {
    [super dealloc];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)willRotate:(id)sender {
	NSNotification *notification = sender;
	UIInterfaceOrientation toOrientation = [[notification.userInfo valueForKey:UIApplicationStatusBarOrientationUserInfoKey] integerValue];
	//UIInterfaceOrientation fromOrientation = [UIApplication sharedApplication].statusBarOrientation;
	
	NSTimeInterval duration = [[UIApplication sharedApplication] statusBarOrientationAnimationDuration];
	if (![self.tabBarController.selectedViewController isEqual:self])  { // I don't think we're visible...
		[super willRotateToInterfaceOrientation:toOrientation duration:duration];
		
		UIViewController *master = [self.viewControllers objectAtIndex:0];
		UIBarButtonItem *button = [super valueForKey:@"_barButtonItem"];
		NSObject *theDelegate = (NSObject *)self.delegate;
		//UIBarButtonItem *buttonUgly = [[[[[self.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] navigationItem] rightBarButtonItem];
	
		if (UIInterfaceOrientationIsPortrait(toOrientation)) {
			if (theDelegate && [theDelegate respondsToSelector:@selector(splitViewController:willHideViewController:withBarButtonItem:forPopoverController:)]) {

				@try {
					UIPopoverController *popover = [super valueForKey:@"_hiddenPopoverController"];
					objc_msgSend(theDelegate, @selector(splitViewController:willHideViewController:withBarButtonItem:forPopoverController:), self, master, button, popover);
				}
				@catch (NSException * e) {
					NSLog(@"There was a nasty error while notifyng splitviewcontrollers of an orientation change: %@", [e description]);
				}
			}
		}
		else if (UIInterfaceOrientationIsLandscape(toOrientation)) {
			if (theDelegate && [theDelegate respondsToSelector:@selector(splitViewController:willShowViewController:invalidatingBarButtonItem:)]) {
				@try {
					objc_msgSend(theDelegate, @selector(splitViewController:willShowViewController:invalidatingBarButtonItem:), self, master, button);
				}
				@catch (NSException * e) {
					NSLog(@"There was a nasty error while notifyng splitviewcontrollers of an orientation change: %@", [e description]);
				}
			}
		}
	}
	
	//debug_NSLog(@"MINE WillRotate ---- sender = %@  to = %d   from = %d", [sender class], toOrientation, fromOrientation);
}
		 
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	//debug_NSLog(@"Theirs --- will rotate");
}

- (void)didRotate:(id)sender {
	NSNotification *notification = sender;
	UIInterfaceOrientation fromOrientation = [[notification.userInfo valueForKey:UIApplicationStatusBarOrientationUserInfoKey] integerValue];
	//UIInterfaceOrientation toOrientation = [UIApplication sharedApplication].statusBarOrientation;
	
	if (![self.tabBarController.selectedViewController isEqual:self]) { // I don't think we're visible...
		[super didRotateFromInterfaceOrientation:fromOrientation];
	}
	
	//debug_NSLog(@"MINE DidRotate ---- sender = %@  from = %d   to = %d", [sender class], fromOrientation, toOrientation);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	//debug_NSLog(@"Theirs --- did rotate");
}

@end
