//
//  UtilityMethods.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "TexLegeReachability.h"

BOOL IsEmpty(id thing);

NSString * VTPG_DDToStringFromTypeAndValue(const char * typeCode, void * value);

// WARNING: if NO_LOG_MACROS is #defined, then THE ARGUMENT WILL NOT BE EVALUATED
#ifndef NO_LOG_MACROS
	#define LOG_EXPR(_X_) do{\
		__typeof__(_X_) _Y_ = (_X_);\
		const char * _TYPE_CODE_ = @encode(__typeof__(_X_));\
		NSString *_STR_ = VTPG_DDToStringFromTypeAndValue(_TYPE_CODE_, &_Y_);\
		if(_STR_)\
			NSLog(@"%s = %@", #_X_, _STR_);\
		else\
			NSLog(@"Unknown _TYPE_CODE_: %s for expression %s in function %s, file %s, line %d", _TYPE_CODE_, #_X_, __func__, __FILE__, __LINE__);\
		}while(0)

	#define LOG_NS(...) NSLog(__VA_ARGS__)
	#define LOG_FUNCTION()	NSLog(@"%s", __func__)
#else /* NO_LOG_MACROS */
	#define LOG_EXPR(_X_)
	#define LOG_NS(...)
	#define LOG_FUNCTION()
#endif /* NO_LOG_MACROS */

@class CapitolMap;
@interface UtilityMethods : NSObject {
}

+ (id) texLegeStringWithKeyPath:(NSString *)keyPath;

+ (CGFloat) iOSVersion;
+ (BOOL) iOSVersion4;
	
+ (BOOL) supportsEventKit;

+ (BOOL) locationServicesEnabled;

+ (BOOL) isLandscapeOrientation;
+ (BOOL) isIPadDevice;

//+ (BOOL) fileExistsAtPath:(NSString *)path;

+ (NSURL *)urlToMainBundle;
+ (NSString *) titleFromURL:(NSURL *)url;
+ (NSDictionary *)parametersOfQuery:(NSString *)queryString;

+ (NSURL *) safeWebUrlFromString:(NSString *)urlString;
+ (NSURL *) googleMapUrlFromStreetAddress:(NSString *)address;
+ (NSString *)applicationDocumentsDirectory;
+ (NSString *)applicationCachesDirectory;

+ (BOOL) openURLWithTrepidation:(NSURL *)url;
+ (BOOL) openURLWithoutTrepidation:(NSURL *)url;
+ (BOOL) canMakePhoneCalls;
+ (void) alertNotAPhone;
+ (NSString*)ordinalNumberFormat:(NSInteger)num;

@end


@interface NSArray (Find)
- (NSArray *)findAllWhereKeyPath:(NSString *)keyPath equals:(id)value;
- (id)findWhereKeyPath:(NSString *)keyPath equals:(id)value;

@end

@interface NSString (FlattenHtml)
- (NSString *)flattenHTML;
- (NSString *)convertFromUTF8;

@end

@interface NSString  (MoreStringUtils)
- (BOOL) hasSubstring:(NSString*)substring caseInsensitive:(BOOL)insensitive;
- (NSString*)firstLetterCaptialized;
- (NSString *)chopPrefix:(NSString *)prefix capitalizingFirst:(BOOL)capitalize;
@end

@interface NSArray (indexKeyedDictionaryExtension)
- (NSDictionary *)indexKeyedDictionaryWithKey:(NSString *)key;
@end




