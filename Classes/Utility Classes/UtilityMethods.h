//
//  UtilityMethods.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CapitolMap;
@interface UtilityMethods : NSObject {
}

+ (CGFloat) iOSVersion;
+ (BOOL) iOSVersion4;
	
+ (BOOL) supportsEventKit;

+ (BOOL) supportsMKPolyline;
+ (BOOL) locationServicesEnabled;

+ (BOOL) isLandscapeOrientation;
+ (BOOL) isIPadDevice;

+ (NSURL *)urlToMainBundle;
+ (NSString *) titleFromURL:(NSURL *)url;
+ (NSURL *) safeWebUrlFromString:(NSString *)urlString;
+ (CapitolMap *) capitolMapFromOfficeString:(NSString *)office;
+ (CapitolMap *) capitolMapFromChamber:(NSInteger)chamber;
+ (NSURL *) googleMapUrlFromStreetAddress:(NSString *)address;
+ (NSString *)applicationDocumentsDirectory;

+ (BOOL) openURLWithTrepidation:(NSURL *)url;
+ (BOOL) openURLWithoutTrepidation:(NSURL *)url;
+ (BOOL) canMakePhoneCalls;
+ (BOOL) isNetworkReachable;
+ (BOOL) canReachHostWithURL:(NSURL *)url alert:(BOOL)doAlert;
+ (BOOL) canReachHostWithURL:(NSURL *)url;
+ (void) alertNotAPhone;
+ (void) noInternetAlert;
+(NSString*)ordinalNumberFormat:(NSInteger)num;

@end


@interface NSArray (Find)
- (NSArray *)findAllWhereKeyPath:(NSString *)keyPath equals:(id)value;
- (id)findWhereKeyPath:(NSString *)keyPath equals:(id)value;

@end



