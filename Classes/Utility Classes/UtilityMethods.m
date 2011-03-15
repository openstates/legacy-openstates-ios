//
//  UtilityMethods.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "UtilityMethods.h"
#import "TexLegeAppDelegate.h"
#import "CapitolMap.h"
#import <MapKit/MapKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#pragma mark -
#pragma mark NSArray Categories

@implementation NSString (FlattenHtml)

- (NSString *)flattenHTML {
    NSScanner *theScanner;
    NSString *text = nil;
	NSMutableString *html = [NSMutableString stringWithString:[self description]];
	
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
    
	[html replaceOccurrencesOfString:@"\u00a0" withString:@"" options:NSWidthInsensitiveSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSWidthInsensitiveSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"&nbsp;" withString:@" " options:NSWidthInsensitiveSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"\r\n " withString:@"\r\n" options:NSWidthInsensitiveSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"\r\n\r\n\r\n" withString:@"\r\n" options:NSWidthInsensitiveSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"\r\n\r\n\r\n" withString:@"\r\n" options:NSWidthInsensitiveSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"\r\n\r\n" withString:@"\r\n" options:NSWidthInsensitiveSearch range:NSMakeRange(0, [html length])];
    return html;
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
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	return UIInterfaceOrientationIsLandscape(orientation);	
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
	else {
		CLLocationManager *locMan = [[CLLocationManager alloc] init];
		if (locMan)
			locationEnabled = [locMan locationServicesEnabled];
		[locMan release];
	}
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

+ (CapitolMap *) capitolMapFromOfficeString:(NSString *)office {
	NSString *fileString = nil;
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"CapitolMaps" ofType:@"plist"];
	NSArray *mapSectionsPlist = [NSArray arrayWithContentsOfFile:thePath];	
	NSArray *searchArray = [mapSectionsPlist objectAtIndex:0];
	CapitolMap *foundMap = nil;
	
	if ([office hasPrefix:@"4"])
		fileString = @"Map.Floor4.pdf";
	else if ([office hasPrefix:@"3"])
		fileString = @"Map.Floor3.pdf";
	else if ([office hasPrefix:@"2"])
		fileString = @"Map.Floor2.pdf";
	else if ([office hasPrefix:@"1"])
		fileString = @"Map.Floor1.pdf";
	else if ([office hasPrefix:@"G"])
		fileString = @"Map.FloorG.pdf";
	else if ([office hasPrefix:@"E1."])
		fileString = @"Map.FloorE1.pdf";
	else if ([office hasPrefix:@"E2."])
		fileString = @"Map.FloorE2.pdf";
	else if ([office hasPrefix:@"SHB"]) {
		fileString = @"Map.SamHoustonLoc.pdf";
		searchArray = [mapSectionsPlist objectAtIndex:1];
	}
		
	for (NSDictionary * mapEntry in searchArray)
	{
		if ([fileString isEqualToString:[mapEntry valueForKey:@"file"]]) {
			foundMap = [[[CapitolMap alloc] init] autorelease];
			[foundMap importFromDictionary:mapEntry];
			break;
		}
	}

	return foundMap;
}

+ (CapitolMap *) capitolMapFromChamber:(NSInteger)chamber {
	NSString *fileString = nil;
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"CapitolMaps" ofType:@"plist"];
	NSArray *mapSectionsPlist = [[NSArray alloc] initWithContentsOfFile:thePath];	
	NSArray *searchArray = [mapSectionsPlist objectAtIndex:2];
	CapitolMap *foundMap = nil;

	if (chamber == HOUSE)
		fileString = @"Map.HouseChamber.pdf";
	else // (chamber == SENATE)
		fileString = @"Map.SenateChamber.pdf";
	
	for (NSDictionary * mapEntry in searchArray)
	{
		if ([fileString isEqualToString:[mapEntry valueForKey:@"file"]]) {
			foundMap = [[[CapitolMap alloc] init] autorelease];
			[foundMap importFromDictionary:mapEntry];
			break;
		}
	}
	[mapSectionsPlist release];
	
	return foundMap;
}
#pragma mark -
#pragma mark EventKit

+ (BOOL)supportsEventKit {
	Class theClass = NSClassFromString(@"EKEventStore");
	return (theClass != nil);
}


#pragma mark -
#pragma mark Device Hardware Alerts and Reachability

+ (BOOL)supportsMKPolyline {
	Class theClass = NSClassFromString(@"MKPolyline");
	return (theClass != nil);
}

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

