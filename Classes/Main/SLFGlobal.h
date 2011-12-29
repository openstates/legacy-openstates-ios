//
//  SLFGlobal.h
//  Created by Greg Combs on 11/28/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "StackableControllerProtocol.h"
#import "APIKeys.h"
#import "SLFPersistenceManager.h"
#import "SLFAnalytics.h"
#import "SLFActionPathNavigator.h"
#import "SLFStackedViewController.h"
#import "AppBarController.h"
#import "UIView+PSSizes.h"
BOOL IsEmpty(NSObject * thing);

@class AppDelegate;
#define SLFIsIpad() ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define SLFAppStatusBarOrientation ([[UIApplication sharedApplication] statusBarOrientation])
#define SLFIsPortrait()  UIInterfaceOrientationIsPortrait(SLFAppStatusBarOrientation)
#define SLFIsLandscape() UIInterfaceOrientationIsLandscape(SLFAppStatusBarOrientation)
#define SLFAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define SLFAppDelegateNav ((UINavigationController *)[SLFAppDelegate valueForKey:@"navigationController"])
#define SLFAppDelegateStack ((SLFStackedViewController *)[SLFAppDelegate valueForKey:@"stackedViewController"])
#define SLFAppBarController ((AppBarController *)[SLFAppDelegate valueForKeyPath:@"appBarController"])
#define SLFRelease(var) if (var) [var release], var = nil
#define SLF_HOURS_TO_SECONDS(var) (var * 60 * 60)
#define SLFRunBlockAfterDelay(block,delay) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*delay), dispatch_get_current_queue(), block);
#define SLFRunBlockInNextRunLoop(block) [[NSOperationQueue mainQueue] addOperationWithBlock: block ];
#define SLFIsIOS5OrGreater() ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0f )