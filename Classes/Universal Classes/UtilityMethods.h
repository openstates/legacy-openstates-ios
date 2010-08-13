//
//  UtilityMethods.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@class CapitolMap;
@interface UtilityMethods : NSObject {
}

+ (NSString*)cipher32Byte;

+ (NSString *) titleFromURL:(NSURL *)url;

+ (NSURL *) safeWebUrlFromString:(NSString *)urlString;
+ (CapitolMap *) capitolMapFromOfficeString:(NSString *)office;
+ (CapitolMap *) capitolMapFromChamber:(NSInteger)chamber;
+ (NSURL *) googleMapUrlFromStreetAddress:(NSString *)address;
+ (NSString *)applicationDocumentsDirectory;

+ (BOOL) isLandscapeOrientation;

+ (BOOL) openURLWithTrepidation:(NSURL *)url;
+ (BOOL) openURLWithoutTrepidation:(NSURL *)url;
+ (BOOL) canMakePhoneCalls;
+ (BOOL) isNetworkReachable;
+ (BOOL) canReachHostWithURL:(NSURL *)url alert:(BOOL)doAlert;
+ (BOOL) canReachHostWithURL:(NSURL *)url;
+ (void) alertNotAPhone;
+ (void) noInternetAlert;

+ (BOOL) isIPadDevice;
//+ (BOOL) isSplitViewClassAvailable;

@end


@interface NSArray (Find)
- (NSArray *)findAllWhereKeyPath:(NSString *)keyPath equals:(id)value;
- (id)findWhereKeyPath:(NSString *)keyPath equals:(id)value;

@end

