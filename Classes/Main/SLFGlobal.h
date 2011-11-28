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

BOOL IsEmpty(NSObject * thing);

#define SLFIsIpad() ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define SLFAppStatusBarOrientation ([[UIApplication sharedApplication] statusBarOrientation])
#define SLFIsPortrait()  UIInterfaceOrientationIsPortrait(SLFAppStatusBarOrientation)
#define SLFIsLandscape() UIInterfaceOrientationIsLandscape(SLFAppStatusBarOrientation)
#define SLFAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define SLFRelease(var) if (var) [var release], var = nil
