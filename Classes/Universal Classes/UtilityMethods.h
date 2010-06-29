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

+ (NSString *) titleFromURL:(NSURL *)url;

+ (NSURL *) safeWebUrlFromString:(NSString *)urlString;
+ (NSURL *) pdfMapUrlFromOfficeString:(NSString *)office;
+ (NSURL *) pdfMapUrlFromChamber:(NSInteger)chamber;
+ (NSURL *) googleMapUrlFromStreetAddress:(NSString *)address;
+ (NSString *)applicationDocumentsDirectory;

+ (BOOL) isLandscapeOrientation;

+ (UIImage *)poorMansImageNamed:(NSString *)fileName;

+ (BOOL) openURLWithTrepidation:(NSURL *)url;
+ (BOOL) openURLWithoutTrepidation:(NSURL *)url;
+ (BOOL) canMakePhoneCalls;
+ (BOOL) isNetworkReachable;
+ (BOOL) canReachHostWithURL:(NSURL *)url;
+ (void) alertNotAPhone;
+ (void) noInternetAlert;

+ (BOOL) isIPadDevice;
//+ (BOOL) isSplitViewClassAvailable;

@end
