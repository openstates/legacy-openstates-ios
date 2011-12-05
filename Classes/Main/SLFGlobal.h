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

#import "PSStackedViewGlobal.h"
#import "PSStackedView.h"
#import "StackableControllerProtocol.h"
#import "APIKeys.h"
#import "SLFPersistenceManager.h"
#import "SLFAnalytics.h"

BOOL IsEmpty(NSObject * thing);

@class AppDelegate;
#define SLFIsIpad() ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define SLFAppStatusBarOrientation ([[UIApplication sharedApplication] statusBarOrientation])
#define SLFIsPortrait()  UIInterfaceOrientationIsPortrait(SLFAppStatusBarOrientation)
#define SLFIsLandscape() UIInterfaceOrientationIsLandscape(SLFAppStatusBarOrientation)
#define SLFAppDelegateStack (((PSStackedViewController *)[(AppDelegate *)[[UIApplication sharedApplication] delegate] valueForKey:@"stackController"]))
#define SLFRelease(var) if (var) [var release], var = nil
#define SLF_HOURS_TO_SECONDS(var) (var * 60 * 60)
