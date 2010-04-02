//
//  UtilityMethods.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface UtilityMethods : NSObject {
}

+ (BOOL) isThisCrantacular;

+ (NSURL *) safeWebUrlFromString:(NSString *)urlString;
+ (NSURL *) pdfMapUrlFromOfficeString:(NSString *)office;
+ (NSURL *) pdfMapUrlFromChamber:(NSInteger)chamber;
+ (NSURL *) googleMapUrlFromStreetAddress:(NSString *)address;
+ (NSString *)applicationDocumentsDirectory;

+ (BOOL) isLandscapeOrientation;

+ (BOOL) openURLWithTrepidation:(NSURL *)url;
+ (BOOL) openURLWithoutTrepidation:(NSURL *)url;
+ (BOOL) canMakePhoneCalls;
+ (BOOL) isNetworkReachable;
+ (BOOL) canReachHostWithURL:(NSURL *)url;
+ (void) alertNotAPhone;
+ (void) noInternetAlert;

#define kUseLeakyControllers 0
#if kUseLeakyControllers
// used to limit the total number of internal browsers, for memory management
//#define kMaxLeakyControllers 2	
+ (void) registerLeakyController:(id) controller;
+ (void) unregisterLeakyController:(id) controller;
+ (void) flushLeakyControllers;
#endif

@end
