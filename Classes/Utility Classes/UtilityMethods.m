//
//  UtilityMethods.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "UtilityMethods.h"
#import "TexLegeAppDelegate.h"
#import <MapKit/MapKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

BOOL IsEmpty(id thing) {
    return thing == nil
	|| ([[NSNull null] isEqual:thing])
	|| ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0)
	|| ([thing respondsToSelector:@selector(count)] && [(NSArray *)thing count] == 0);
}

static BOOL TypeCodeIsCharArray(const char *typeCode){
	int lastCharOffset = strlen(typeCode) - 1;
	int secondToLastCharOffset = lastCharOffset - 1 ;
	
	BOOL isCharArray = typeCode[0] == '[' &&
	typeCode[secondToLastCharOffset] == 'c' && typeCode[lastCharOffset] == ']';
	for(int i = 1; i < secondToLastCharOffset; i++)
		isCharArray = isCharArray && isdigit(typeCode[i]);
	return isCharArray;
}

//since BOOL is #defined as a signed char, we treat the value as
//a BOOL if it is exactly YES or NO, and a char otherwise.
static NSString* VTPGStringFromBoolOrCharValue(BOOL boolOrCharvalue) {
	if(boolOrCharvalue == YES)
		return @"YES";
	if(boolOrCharvalue == NO)
		return @"NO";
	return [NSString stringWithFormat:@"'%c'", boolOrCharvalue];
}

static NSString *VTPGStringFromFourCharCodeOrUnsignedInt32(FourCharCode fourcc) {
	return [NSString stringWithFormat:@"%u ('%c%c%c%c')",
			fourcc,
			(fourcc >> 24) & 0xFF,
			(fourcc >> 16) & 0xFF,
			(fourcc >> 8) & 0xFF,
			fourcc & 0xFF];
}

static NSString *StringFromNSDecimalWithCurrentLocal(NSDecimal dcm) {
	return NSDecimalString(&dcm, [NSLocale currentLocale]);						   
}

NSString * VTPG_DDToStringFromTypeAndValue(const char * typeCode, void * value) {
#define IF_TYPE_MATCHES_INTERPRET_WITH(typeToMatch,func) \
if (strcmp(typeCode, @encode(typeToMatch)) == 0) \
return (func)(*(typeToMatch*)value)
	
#if	TARGET_OS_IPHONE
	IF_TYPE_MATCHES_INTERPRET_WITH(CGPoint,NSStringFromCGPoint);
	IF_TYPE_MATCHES_INTERPRET_WITH(CGSize,NSStringFromCGSize);
	IF_TYPE_MATCHES_INTERPRET_WITH(CGRect,NSStringFromCGRect);
#else
	IF_TYPE_MATCHES_INTERPRET_WITH(NSPoint,NSStringFromPoint);
	IF_TYPE_MATCHES_INTERPRET_WITH(NSSize,NSStringFromSize);
	IF_TYPE_MATCHES_INTERPRET_WITH(NSRect,NSStringFromRect);
#endif
	IF_TYPE_MATCHES_INTERPRET_WITH(NSRange,NSStringFromRange);
	IF_TYPE_MATCHES_INTERPRET_WITH(Class,NSStringFromClass);
	IF_TYPE_MATCHES_INTERPRET_WITH(SEL,NSStringFromSelector);
	IF_TYPE_MATCHES_INTERPRET_WITH(BOOL,VTPGStringFromBoolOrCharValue);
	IF_TYPE_MATCHES_INTERPRET_WITH(NSDecimal,StringFromNSDecimalWithCurrentLocal);
	
#define IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(typeToMatch,formatString) \
if (strcmp(typeCode, @encode(typeToMatch)) == 0) \
return [NSString stringWithFormat:(formatString), (*(typeToMatch*)value)]
	
	
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(CFStringRef,@"%@"); //CFStringRef is toll-free bridged to NSString*
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(CFArrayRef,@"%@"); //CFArrayRef is toll-free bridged to NSArray*
	IF_TYPE_MATCHES_INTERPRET_WITH(FourCharCode, VTPGStringFromFourCharCodeOrUnsignedInt32);
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(long long,@"%lld");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(unsigned long long,@"%llu");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(float,@"%f");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(double,@"%f");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(id,@"%@");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(short,@"%hi");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(unsigned short,@"%hu");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(int,@"%i");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(unsigned, @"%u");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(long,@"%i");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(long double,@"%Lf"); //WARNING on older versions of OS X, @encode(long double) == @encode(double)
	
	//C-strings
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(char*, @"%s");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(const char*, @"%s");
	if(TypeCodeIsCharArray(typeCode))
		return [NSString stringWithFormat:@"%s", (char*)value];
	
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(void*,@"(void*)%p");
	
	//This is a hack to print out CLLocationCoordinate2D, without needing to #import <CoreLocation/CoreLocation.h>
	//A CLLocationCoordinate2D is a struct made up of 2 doubles.
	//We detect it by hard-coding the result of @encode(CLLocationCoordinate2D).
	//We get at the fields by treating it like an array of doubles, which it is identical to in memory.
	if(strcmp(typeCode, "{?=dd}")==0)//@encode(CLLocationCoordinate2D)
		return [NSString stringWithFormat:@"{latitude=%g,longitude=%g}",((double*)value)[0],((double*)value)[1]];
	
	//we don't know how to convert this typecode into an NSString
	return nil;
}

#pragma mark -
#pragma mark NSArray Categories

@implementation NSString (FlattenHtml)

- (NSString *)convertFromUTF8 {
	//unichar ellipsis = 0x2026;
	//NSString *theString = [NSString stringWithFormat:@"To be continued%C", ellipsis];
	
	NSData *asciiData = [self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	
	return [[NSString alloc] initWithData:asciiData encoding:NSASCIIStringEncoding];
}

- (NSString *)flattenHTML {
    NSScanner *theScanner;
    NSString *text = nil;

	NSMutableString *html = [NSMutableString stringWithString:[self convertFromUTF8]];
	
    theScanner = [NSScanner scannerWithString:html];
	
    while ([theScanner isAtEnd] == NO) {
		
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
		
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        //[html stringByReplacingOccurrencesOfString:
		//		[ NSString stringWithFormat:@"%@>", text]
		//									   withString:@""];
		
		[html replaceOccurrencesOfString:[ NSString stringWithFormat:@"%@>", text] 
							  withString:@"" options:0 range:NSMakeRange(0, [html length])];

		
    } // while //
    
//	[html replaceOccurrencesOfString:@"\u00a0" withString:@"" options:NSWidthInsensitiveSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSWidthInsensitiveSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"&nbsp;" withString:@" " options:NSWidthInsensitiveSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"\r\n " withString:@"\r\n" options:NSWidthInsensitiveSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"\r\n\r\n\r\n" withString:@"\r\n" options:NSWidthInsensitiveSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"\r\n\r\n\r\n" withString:@"\r\n" options:NSWidthInsensitiveSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"\r\n\r\n" withString:@"\r\n" options:NSWidthInsensitiveSearch range:NSMakeRange(0, [html length])];
    return html;
}

@end

@implementation NSString  (MoreStringUtils)
- (BOOL) hasSubstring:(NSString*)substring caseInsensitive:(BOOL)insensitive
{
	if(IsEmpty(substring))
		return NO;
	
	NSString *temp = self;
	if (insensitive) {
		temp = [temp lowercaseString];
		substring = [substring lowercaseString];
	}
		
	NSRange substringRange = [temp rangeOfString:substring];
	return substringRange.location != NSNotFound && substringRange.length > 0;
}

- (NSString*)firstLetterCaptialized {
//#ifdef __APPLE__
	NSRange startRange = NSMakeRange(0, 1);
	return [self stringByReplacingCharactersInRange:startRange withString:[[self substringWithRange:startRange] uppercaseString]];
/* #else		// I think this was a nasty hack to deal with a bug in Foundation classes.
	NSString* firstCharCapital = [[self substringWithRange:NSMakeRange(0, 1)] uppercaseString];
	NSString* lastPartOfString = [self substringWithRange:NSMakeRange(1, self.length-1)];
	return [firstCharCapital stringByAppendingString:lastPartOfString];
#endif */
}

- (NSString *)chopPrefix:(NSString *)prefix capitalizingFirst:(BOOL)capitalize {
	if (IsEmpty(prefix))
		return self;
	else if (IsEmpty(self))
		return @"";
	
	NSString *strVal = [NSString stringWithString:self];
	
	if ([strVal hasPrefix:prefix]){
		strVal = [strVal stringByReplacingOccurrencesOfString:prefix 
														   withString:@"" 
															  options:(NSCaseInsensitiveSearch | NSAnchoredSearch) 
																range:NSMakeRange(0, [prefix length])];
		
		if (capitalize)
			strVal = [strVal firstLetterCaptialized];
	}	
	return strVal;
}

@end

@implementation NSArray (Find)

// Implementation example
//NSArray *friendsWithDadsNamedBob = [friends findAllWhereKeyPath:@"father.name" equals:@"Bob"]

- (NSArray *)findAllWhereKeyPath:(NSString *)keyPath equals:(id)value {
	NSMutableArray *matches = [NSMutableArray array];
    for (id object in self) {
		id objectValue = [object valueForKeyPath:keyPath];
		if ([objectValue isEqual:value] || objectValue == value) [matches addObject:object];
    }
	
    return matches;
}

- (id)findWhereKeyPath:(NSString *)keyPath equals:(id)value {
	id match = nil;
    for (id object in self) {
		id objectValue = [object valueForKeyPath:keyPath];
		if ([objectValue isEqual:value] || objectValue == value) {
			match = object;
			return match;
		}
    }
    return match;
}

@end

#pragma mark -

@implementation UtilityMethods

+ (id) texLegeStringWithKeyPath:(NSString *)keyPath {
	NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"TexLegeStrings" ofType:@"plist"];
	NSDictionary *textDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
	return [textDict valueForKeyPath:keyPath];
}

+ (CGFloat) iOSVersion {
	return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (BOOL) iOSVersion4 {
	return ([UtilityMethods iOSVersion] >= 4.0f);
}

#pragma mark -
#pragma mark Device Checks and Screen Methods


+ (BOOL) isLandscapeOrientation {	
#if 0 // If we start experiencing problems with device orientation again, we might try using this instead...
	TexLegeAppDelegate *appDel = [UIApplication sharedApplication].delegate;
	UIInterfaceOrientation tabBarOrientation = appDel.tabBarController.interfaceOrientation;
	return UIInterfaceOrientationIsLandscape(tabBarOrientation);
#else
	//UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIDeviceOrientationIsValidInterfaceOrientation(orientation) && UIDeviceOrientationIsLandscape(orientation) && !UIInterfaceOrientationIsLandscape(statusBarOrientation)) {
/*		NSLog(@"ORIENTATION WAS WRONG ... WE'RE RESETTING ... IS THIS OKAY???");
		[[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
*/
		return UIInterfaceOrientationIsLandscape(orientation);	
	}
	else
		return UIInterfaceOrientationIsLandscape(statusBarOrientation);
#endif
}

+ (BOOL)isIPadDevice;
{
	static BOOL hasCheckediPadStatus = NO;
	static BOOL isRunningOniPad = NO;
	
	if (!hasCheckediPadStatus)
	{
		if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)])
		{
			if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
			{
				isRunningOniPad = YES;
				hasCheckediPadStatus = YES;
				return isRunningOniPad;
			}
		}
		hasCheckediPadStatus = YES;
	}
	return isRunningOniPad;
}

#pragma mark -
#pragma mark MapKit

+ (BOOL) locationServicesEnabled {
	BOOL locationEnabled = NO;
	if ([[CLLocationManager class] respondsToSelector:@selector(locationServicesEnabled)])
		locationEnabled = [CLLocationManager locationServicesEnabled];
	return locationEnabled;
}


#pragma mark -
#pragma mark File Handling
/*
	// This is so short, just use the real one instead of dropping a convenience method here.
- (BOOL)fileExistsAtPath:(NSString *)thePath {
	return [[NSFileManager defaultManager] fileExistsAtPath:thePath];
}
*/

/**
 Returns the path to the application's documents directory.
 */
+ (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (NSString *)applicationCachesDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachePath = [paths objectAtIndex:0];
	BOOL isDir = NO;
	NSError *error;
	if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
		[[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
	}
	return cachePath;
}

#pragma mark -
#pragma mark URL Handling
+ (NSURL *)urlToMainBundle {
	return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

+ (NSString *) titleFromURL:(NSURL *)url {
	debug_NSLog(@"%@", [url absoluteString]);
	NSArray *urlComponents = [[url absoluteString] componentsSeparatedByString:@"/"];
	NSString * title = nil;
	
	if ( [urlComponents count] > 0 )
	{
		NSString *str = [urlComponents objectAtIndex:([urlComponents count]-1)];
		NSRange dot = [str rangeOfString:@"."];
		if ( dot.length > 0 )
			title = [str substringToIndex:dot.location];
		else
			title = str;
	}
	else
		title = @"...";
	
	return title;
}

+ (NSURL *) safeWebUrlFromString:(NSString *)urlString {
	//NSString * tempString = [[NSString alloc] initWithString:urlString];
	return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

// Determine if we have network access, if not then throw up an alert.
+ (BOOL) openURLWithTrepidation:(NSURL *)url {
	BOOL canOpenURL = NO;
	
	if (![[TexLegeReachability sharedTexLegeReachability] isNetworkReachable]) {
		[TexLegeReachability noInternetAlert];
	}
	else if ([[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url];
		canOpenURL = YES;
	}
	else {
		debug_NSLog(@"Can't open this URL: %@", url.description);			
	}
	return canOpenURL;
}

// just open the url, don't bother checking for network access
+ (BOOL) openURLWithoutTrepidation:(NSURL *)url {
	BOOL canOpenURL = NO;
	
	if ([[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url];
		canOpenURL = YES;
	}
	else {
		debug_NSLog(@"Can't open this URL: %@", url.description);			
	}
	return canOpenURL;
}

+ (NSDictionary *)parametersOfQuery:(NSString *)queryString
{
	if ([queryString hasSubstring:@"?" caseInsensitive:NO]) {
		NSRange index = [queryString rangeOfString:@"?"];
		if (index.location != NSNotFound && index.length > 0 && [queryString length] > index.location)
			queryString = [queryString substringFromIndex:index.location+1];
	}
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    // Handle & or ; as separators, as per W3C recommendation
    NSCharacterSet *seperatorChars = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
	NSArray *keyValues = [queryString componentsSeparatedByCharactersInSet:seperatorChars];
	NSEnumerator *theEnum = [keyValues objectEnumerator];
	NSString *keyValuePair;
	
	while (nil != (keyValuePair = [theEnum nextObject]) )
	{
		NSRange whereEquals = [keyValuePair rangeOfString:@"="];
		if (NSNotFound != whereEquals.location)
		{
			NSString *key = [keyValuePair substringToIndex:whereEquals.location];
			NSString *value = [[keyValuePair substringFromIndex:whereEquals.location+1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[result setValue:value forKey:key];
		}
	}
	return result;
}

#pragma mark -
#pragma mark Maps and Map Files

+ (NSURL *) googleMapUrlFromStreetAddress:(NSString *)address {
	// if you want driving directions, daddr is the destination, saddr is the origin
	// @"http://maps.google.com/maps?daddr=San+Francisco,+CA&saddr=cupertino"
	// [NSString stringWithFormat: @"http://maps.google.com/maps?q=%f,%f", loc.latitude, loc.longitude];
	
	NSString *temp1 =  [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@",address];
	// We'll likely have carriage returns
	NSString *temp2 = [temp1 stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
	
	
	return [UtilityMethods safeWebUrlFromString:temp2];
}

#pragma mark -
#pragma mark EventKit

+ (BOOL)supportsEventKit {
	Class theClass = NSClassFromString(@"EKEventStore");
	return (theClass != nil);
}


#pragma mark -
#pragma mark Device Hardware Alerts and Reachability

+ (BOOL)canMakePhoneCalls
{
	static NSString *s_devName = nil;
	static BOOL s_iPhoneDevice = NO;
	
	UIDevice *device = [UIDevice currentDevice];
	if ( nil == s_devName )
	{
		s_devName = [[[NSString alloc] initWithString:device.model] autorelease];
		NSRange strRange;
		strRange.length = ([s_devName length] < 6) ? [s_devName length] : 6;
		strRange.location = 0;
		s_iPhoneDevice = (NSOrderedSame == [s_devName compare:@"iPhone" options:NSLiteralSearch range:strRange]);
	}
	
	return s_iPhoneDevice;
}

+ (void)alertNotAPhone {
	UIAlertView *noPhoneAlert = [[[ UIAlertView alloc ] 
								  initWithTitle:@"Not an iPhone" 
								  message:@"You attempted to dial a phone number.  However, unfortunately you cannot make phone calls without an iPhone." 
								  delegate:nil // we're static, so don't do "self"
								  cancelButtonTitle: @"Cancel" 
								  otherButtonTitles:nil, nil] autorelease];
	
	[ noPhoneAlert show ];		
}


+(NSString*)ordinalNumberFormat:(NSInteger)num{
    NSString *ending;
	
    int ones = num % 10;
    int tens = floor(num / 10);
    tens = tens % 10;
    if(tens == 1){
        ending = @"th";
    }else {
        switch (ones) {
            case 1:
                ending = @"st";
                break;
            case 2:
                ending = @"nd";
                break;
            case 3:
                ending = @"rd";
                break;
            default:
                ending = @"th";
                break;
        }
    }
    return [NSString stringWithFormat:@"%d%@", num, ending];
}

@end

@implementation NSArray (indexKeyedDictionaryExtension)

- (NSDictionary *) indexKeyedDictionaryWithKey:(NSString *)key 
{
	if (![self count] || !key)
		return nil;
	
	id objectInstance = nil;
	NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
	for (objectInstance in self) {
		[mutableDictionary setObject:objectInstance forKey:[objectInstance valueForKey:key]];
	}
	
	return (NSDictionary *)[mutableDictionary autorelease];
}


@end

