//  
//  UIApplication+ScreenMirroring.m
//  Created by Francois Proulx on 10-04-17.
//  
//  Copyright (c) 2010 Francois Proulx.  All rights reserved.
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//  1. Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in the
//     documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
//  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "UIApplication+ScreenMirroring.h"

#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "LocalyticsSession.h"

NSString * const UIApplicationDidSetupScreenMirroringNotification = @"UIApplicationDidSetupScreenMirroringNotification";
NSString * const UIApplicationDidDisableScreenMirroringNotification = @"UIApplicationDidDisableScreenMirroringNotification";

// Assuming CA loops at 60.0 fps (which is true on iPhone OS 3 : iPhone, iPad...)
#define CORE_ANIMATION_MAX_FRAMES_PER_SECOND (60)

CGImageRef UIGetScreenImage(); // Not so private API anymore

static CFTimeInterval startTime = 0;
static NSUInteger frames = 0;

@interface UIApplication(ScreenMirroringPrivate)

- (void) setupMirroringForScreen:(UIScreen *)anExternalScreen;
- (void) disableMirroringOnCurrentScreen;
- (void) updateMirroredScreenOnDisplayLink;

@end

@implementation UIApplication (ScreenMirroring)

static double targetFramesPerSecond = 0;
static CADisplayLink *displayLink = nil;
static UIScreen *mirroredScreen = nil;
static UIWindow *mirroredScreenWindow = nil;
static UIImageView *mirroredImageView = nil;

- (BOOL) isScreenMirroringActive
{
	return (displayLink && !displayLink.paused);
}

- (UIScreen *) currentMirroringScreen
{
	return mirroredScreen;
}

- (void) setupScreenMirroring
{
	[self setupScreenMirroringWithFramesPerSecond:ScreenMirroringDefaultFramesPerSecond];
}

- (void) setupScreenMirroringWithFramesPerSecond:(double)fps
{
	// Set the desired frame rate
	targetFramesPerSecond = fps;

	// Register for screen notifications
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(screenDidConnect:) name:UIScreenDidConnectNotification object:nil]; 
	[center addObserver:self selector:@selector(screenDidDisconnect:) name:UIScreenDidDisconnectNotification object:nil]; 
	[center addObserver:self selector:@selector(screenModeDidChange:) name:UIScreenModeDidChangeNotification object:nil]; 
	
	// Register for interface orientation changes (so we don't need to query on every frame refresh)
	[center addObserver:self selector:@selector(interfaceOrientationWillChange:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
	
	// Setup screen mirroring for an existing screen
	NSArray *connectedScreens = [UIScreen screens];
	if ([connectedScreens count] > 1) {
		UIScreen *mainScreen = [UIScreen mainScreen];
		for (UIScreen *aScreen in connectedScreens) {
			if (aScreen != mainScreen) {
				// We've found an external screen !
				[self setupMirroringForScreen:aScreen];
				break;
			}
		}
	}
}

- (void) disableScreenMirroring
{
	// Unregister from screen notifications
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self name:UIScreenDidConnectNotification object:nil];
	[center removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
	[center removeObserver:self name:UIScreenModeDidChangeNotification object:nil];
	
	// Device orientation
	[center removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
	
	// Remove mirroring
	[self disableMirroringOnCurrentScreen];
}

#pragma mark -
#pragma mark UIScreen notifications

- (void) screenDidConnect:(NSNotification *)aNotification
{
	NSLog(@"A new screen got connected: %@", [aNotification object]);
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"MIRRORING_TO_VGA_SCREEN"];
	[self setupMirroringForScreen:[aNotification object]];
}

- (void) screenDidDisconnect:(NSNotification *)aNotification
{
	NSLog(@"A screen got disconnected: %@", [aNotification object]);
	[self disableMirroringOnCurrentScreen];
}

- (void) screenModeDidChange:(NSNotification *)aNotification
{
	UIScreen *someScreen = [aNotification object];
	NSLog(@"The screen mode for a screen did change: %@", [someScreen currentMode]);
	
	// Disable, then reenable with new config
	[self disableMirroringOnCurrentScreen];
	[self setupMirroringForScreen:[aNotification object]];
}

#pragma mark -
#pragma mark Inteface orientation changes notification

- (void) updateMirroredWindowTransformForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Grab the secondary window layer
	CALayer *mirrorLayer = mirroredScreenWindow.layer;
	
	// Rotate the screenshot to match interface orientation
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			mirrorLayer.transform = CATransform3DIdentity;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			mirrorLayer.transform = CATransform3DMakeRotation(M_PI / 2, 0.0f, 0.0f, 1.0f);
			break;
		case UIInterfaceOrientationLandscapeRight:
			mirrorLayer.transform = CATransform3DMakeRotation(-(M_PI / 2), 0.0f, 0.0f, 1.0f);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			mirrorLayer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
			break;
		default:
			break;
	}
}

- (void) interfaceOrientationWillChange:(NSNotification *)aNotification
{
	NSDictionary *userInfo = [aNotification userInfo];
	UIInterfaceOrientation newInterfaceOrientation = (UIInterfaceOrientation) [[userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey] unsignedIntegerValue];
	[self updateMirroredWindowTransformForInterfaceOrientation:newInterfaceOrientation];
}

#pragma mark -
#pragma mark Screen mirroring

- (void) setupMirroringForScreen:(UIScreen *)anExternalScreen
{       
	// Reset timer
	startTime = CFAbsoluteTimeGetCurrent();
	frames = 0;
	
	// Set the new screen to mirror
	BOOL done = NO;
	UIScreenMode *mainScreenMode = [UIScreen mainScreen].currentMode;
	for (UIScreenMode *externalScreenMode in anExternalScreen.availableModes) {
		if (CGSizeEqualToSize(externalScreenMode.size, mainScreenMode.size)) {
			// Select a screen that matches the main screen
			anExternalScreen.currentMode = externalScreenMode;
			done = YES;
			break;
		}
	}
	
	if (!done && [anExternalScreen.availableModes count]) {
		anExternalScreen.currentMode = [anExternalScreen.availableModes objectAtIndex:0];
	}
	
	[mirroredScreen release];
	mirroredScreen = [anExternalScreen retain];
	
	// Setup window in external screen	
	UIWindow *newWindow = [[UIWindow alloc] initWithFrame:mirroredScreen.bounds];
	newWindow.opaque = YES;
	newWindow.hidden = NO;
	newWindow.backgroundColor = [UIColor blackColor];
	newWindow.layer.contentsGravity = kCAGravityResizeAspect;
	[mirroredScreenWindow release];
	mirroredScreenWindow = [newWindow retain];
	mirroredScreenWindow.screen = mirroredScreen;
	[newWindow release];
	
	// Apply transform on mirrored window to match device's interface orientation
	[self updateMirroredWindowTransformForInterfaceOrientation:self.statusBarOrientation];
	
	// Setup periodic callbacks
	[displayLink invalidate];
	[displayLink release], displayLink = nil;
	
	// Setup display link sync
	displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(updateMirroredScreenOnDisplayLink)] retain];
	[displayLink setFrameInterval:(targetFramesPerSecond >= CORE_ANIMATION_MAX_FRAMES_PER_SECOND) ? 1 : (CORE_ANIMATION_MAX_FRAMES_PER_SECOND / targetFramesPerSecond)];
	
	// We MUST add ourselves in the commons run loop in order to mirror during UITrackingRunLoopMode.
	// Otherwise, the display won't be updated while fingering are touching the screen.
	// This has a major impact on performance though...
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	
	// Post notification advertisting that we're setting up mirroring for the external screen
	[[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidSetupScreenMirroringNotification object:anExternalScreen];
}

- (void) disableMirroringOnCurrentScreen
{
	// Post notification advertisting that we're tearing down mirroring
	[[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidDisableScreenMirroringNotification object:mirroredScreen];
	
	if (displayLink)
		[displayLink invalidate];
	[displayLink release], displayLink = nil;
	
	[mirroredScreen release], mirroredScreen = nil;
	[mirroredScreenWindow release], mirroredScreenWindow = nil;
	[mirroredImageView release], mirroredImageView = nil;
}

- (void) updateMirroredScreenOnDisplayLink
{
	// Get a screenshot of the main window
	CGImageRef mainWindowScreenshot = UIGetScreenImage();
	if (mainWindowScreenshot) {
		// Copy to secondary screen
		mirroredScreenWindow.layer.contents = (id) mainWindowScreenshot;
		// Clean up as UIGetScreenImage does NOT respect retain / release semantics
		CFRelease(mainWindowScreenshot); 
	}
}

@end
