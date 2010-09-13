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
	debug_NSLog(@"Is landscape = %d .... orientation = %d", UIInterfaceOrientationIsLandscape(orientation), orientation);
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
	
	if (![UtilityMethods isNetworkReachable]) {
		[UtilityMethods noInternetAlert];
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
	NSArray *mapSectionsPlist = [[NSArray alloc] initWithContentsOfFile:thePath];	
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
			foundMap = [[[CapitolMap alloc] initWithDictionary:mapEntry] autorelease];
			continue;
		}
	}

	[mapSectionsPlist release];

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
			foundMap = [[[CapitolMap alloc] initWithDictionary:mapEntry] autorelease];
			continue;
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

+ (void)noInternetAlert {
	UIAlertView *noInternetAlert = [[[ UIAlertView alloc ] 
								  initWithTitle:@"Internet Unavailable" 
								  message:@"This feature requires an Internet connection.  Perhaps your iOS device is in Airplane mode or there is no WiFi service in this area." 
								  delegate:nil // we're static, so don't do "self"
								  cancelButtonTitle: @"Cancel" 
								  otherButtonTitles:nil, nil] autorelease];
	[ noInternetAlert show ];		
}


+ (BOOL) isNetworkReachable {
	BOOL reachable = YES;
	
	reachable = ([TexLegeAppDelegate appDelegate].internetConnectionStatus != NotReachable);
	
	return reachable;
}

+ (BOOL) canReachHostWithURL:(NSURL *)url alert:(BOOL)doAlert {
	UIAlertView * alert = nil;	
	BOOL reachableHost = NO;
	
	if ([url isFileURL])
		return YES;
		
	if (![UtilityMethods isNetworkReachable]) {
		if (doAlert)
			[UtilityMethods noInternetAlert];
	}
	else if (url == nil) { // problem with url string
		if (doAlert) {
			alert = [[[ UIAlertView alloc ] 
					  initWithTitle:@"Invalid URL" 
					  message:@"There was a problem with the URL, please double-check for typographical errors." 
					  delegate:nil // we're static, so don't do "self"
					  cancelButtonTitle: @"Cancel" 
					  otherButtonTitles:nil, nil] autorelease];
			[ alert show ];		
		}
	}
	else if (![[Reachability sharedReachability] isHostReachable:[url host]]) {
		if (doAlert) {
			alert = [[[ UIAlertView alloc ] 
				  initWithTitle:@"Host Unreachable" 
				  message:@"There was a problem contacting the website host, please double-check the URL for typographical errors or try the connection again later." 
				  delegate:nil // we're static, so don't do "self"
				  cancelButtonTitle: @"Cancel" 
				  otherButtonTitles:nil, nil] autorelease];
			[ alert show ];	
		}
	}
	else {
		reachableHost = YES;
	}
	
	return reachableHost;	
}

// throw up some appropriate errors while you're at it...
+ (BOOL) canReachHostWithURL:(NSURL *)url {
	
	return [UtilityMethods canReachHostWithURL:url alert:YES];
}

// "Thisisalongstringsowatchoutkid"
// http://www.iwillapps.com/tuts/symcipher.php?sub_str=Thisisalongstringsowatchoutkid
+ (NSString*)cipher32Byte {
	char symCipher[] = { ';', 'R', ',', 'S', 'y', '&', 'W', '^', '#', 'x', '\\', '"', 'G', 'i', '7', 'q', '{', 'v', '8', 'o', '_', 'E', 'z', '3', '5', 'c', 'g', 'l', 'm', 'D', 'K', 'F', '(', ':', 'n', 'Z', '-', 'a', 'U', '*', 'X', 'I', 'j', 'Y', 'O', 'A', '=', 'f', '.', '`', '\'', ']', 'M', '%', 'u', '/', '|', 't', 'L', '4', '@', 'd', '+', 'k', 'p', 'e', '?', '0', ')', '1', 'P', '6', '[', 'h', 'r', 'H', 'B', 's', '9', 'C', '2', 'w', 'T', '}', 'V', '$', 'N', 'b', 'J', '!', '<', '>', 'Q' }; 
	char csignid[] = "]6[T[TpH9sPT}w[sPT9Np}?69V}r[0";
	NSInteger i = 0;
	for(i=0;i<strlen(csignid);i++)
	{
		int j = 0;
		for(j=0;j<sizeof(symCipher);j++)
		{
			if(csignid[i] == symCipher[j])
			{
				csignid[i] = j+0x21;
				break;
			}
		}
	}
	return [NSString stringWithCString:csignid encoding:NSUTF8StringEncoding];
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

