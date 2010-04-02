//
//  UtilityMethods.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "UtilityMethods.h"
#import "TexLegeAppDelegate.h"

@implementation UtilityMethods

+ (BOOL) isLandscapeOrientation {
	return (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation));
}

+ (NSURL *) safeWebUrlFromString:(NSString *)urlString {
	NSString * tempString = [[NSString alloc] initWithString:urlString];
	return [NSURL URLWithString:[tempString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSURL *) pdfMapUrlFromOfficeString:(NSString *)office {
	NSString *fileString = nil;
	if ([office hasPrefix:@"4"])
		fileString = [NSString stringWithFormat:@"Map.Floor4.pdf"];
	else if ([office hasPrefix:@"3"])
		fileString = [NSString stringWithFormat:@"Map.Floor3.pdf"];
	else if ([office hasPrefix:@"2"])
		fileString = [NSString stringWithFormat:@"Map.Floor2.pdf"];
	else if ([office hasPrefix:@"1"])
		fileString = [NSString stringWithFormat:@"Map.Floor1.pdf"];
	else if ([office hasPrefix:@"G"])
		fileString = [NSString stringWithFormat:@"Map.FloorG.pdf"];
	else if ([office hasPrefix:@"E1."])
		fileString = [NSString stringWithFormat:@"Map.FloorE1.pdf"];
	else if ([office hasPrefix:@"E2."])
		fileString = [NSString stringWithFormat:@"Map.FloorE2.pdf"];
	else if ([office hasPrefix:@"SHB"])
		fileString = [NSString stringWithFormat:@"Map.SamHoustonLoc.pdf"];
	
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
	NSString *pdfPath = [ NSString stringWithFormat:
						 @"%@/%@.app/%@",NSHomeDirectory(),appName, fileString ];
	
	return [ NSURL fileURLWithPath:pdfPath ];
}

+ (NSURL *) pdfMapUrlFromChamber:(NSInteger)chamber {
	NSString *fileString = nil;
	if (chamber == HOUSE)
		fileString = [NSString stringWithFormat:@"Map.HouseChamber.pdf"];
	else // (chamber == SENATE)
		fileString = [NSString stringWithFormat:@"Map.SenateChamber.pdf"];
	
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
	NSString *pdfPath = [ NSString stringWithFormat:
						 @"%@/%@.app/%@",NSHomeDirectory(),appName, fileString ];
	
	return [NSURL fileURLWithPath:pdfPath ];
}

+ (NSURL *) googleMapUrlFromStreetAddress:(NSString *)address {
	// if you want driving directions, daddr is the destination, saddr is the origin
	// @"http://maps.google.com/maps?daddr=San+Francisco,+CA&saddr=cupertino"
	// [NSString stringWithFormat: @"http://maps.google.com/maps?q=%f,%f", loc.latitude, loc.longitude];
	
	NSString *temp1 =  [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@",address];
	// We'll likely have carriage returns
	NSString *temp2 = [temp1 stringByReplacingOccurrencesOfString:@"\n" withString:@", "];

	
	return [UtilityMethods safeWebUrlFromString:temp2];
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

/**
 Returns the path to the application's documents directory.
 */
+ (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
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
								  message:@"This feature requires an Internet connection.  If your iPhone/iTouch is in Airplane Mode, you must disable it before utilizing this feature." 
								  delegate:nil // we're static, so don't do "self"
								  cancelButtonTitle: @"Cancel" 
								  otherButtonTitles:nil, nil] autorelease];
	
	[ noInternetAlert show ];		
	
}


+ (BOOL) isNetworkReachable {
	BOOL reachable = YES;
	
	TexLegeAppDelegate *appDelegate = (TexLegeAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate != nil) {
		reachable = (appDelegate.internetConnectionStatus != NotReachable);
	}
	
	return reachable;
}

// throw up some appropriate errors while you're at it...
+ (BOOL) canReachHostWithURL:(NSURL *)url {
	UIAlertView * alert = nil;	
	BOOL reachableHost = NO;
	
	if (![UtilityMethods isNetworkReachable]) {
		[UtilityMethods noInternetAlert];
	}
	else if (url == nil) { // problem with url string
		alert = [[[ UIAlertView alloc ] 
							   initWithTitle:@"Invalid URL" 
							   message:@"There was a problem with the URL, please double-check for typographical errors." 
							   delegate:nil // we're static, so don't do "self"
							   cancelButtonTitle: @"Cancel" 
							   otherButtonTitles:nil, nil] autorelease];
		[ alert show ];		
	}
	else if (![[Reachability sharedReachability] isHostReachable:[url host]]) {
		alert = [[[ UIAlertView alloc ] 
							   initWithTitle:@"Host Unreachable" 
							   message:@"There was a problem contacting the website host, please double-check the URL for typographical errors or try the connection again later." 
							   delegate:nil // we're static, so don't do "self"
							   cancelButtonTitle: @"Cancel" 
							   otherButtonTitles:nil, nil] autorelease];
		[ alert show ];			
	}
	else {
		reachableHost = YES;
	}
	
	return reachableHost;
}


// Look for app hacking/cracking/smacking
+ (BOOL) isThisCrantacular {
	char symCipher[] = { 'v', 'S', '#', 'd', 'X', '2', 'x', '+', 'h', '8', '&', 'L', 'i', '9', 't', '[', 'e', 'q', '>', '0', 'D', 'A', 'Y', '-', 'O', '%', '=', 'R', 'f', 'r', 'a', '|', 'K', '7', 'F', '}', '\\', 's', 'U', '*', 'G', 'E', 'g', 'j', 'H', '(', 'T', '4', '?', '$', '!', 'N', '_', '/', '`', ']', 'b', ',', 'Q', 'z', 'n', '.', '\'', '6', 'B', 'W', '"', ')', '5', 'c', 'y', 'J', '{', 'w', '3', ';', '^', 'u', 'Z', 'p', 'l', ':', 'V', 'k', 'P', 'M', '@', 'm', '1', 'C', 'I', '<', 'o' };
	char csignid[] = "!{yu5:G)5uk{k1";
	int i = 0;
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
	NSString* signIdentity = [[NSString alloc] initWithCString:csignid encoding:NSUTF8StringEncoding];
	//NSLog(signIdentity);
	
	BOOL checked = NO; // First assume "This app be hacked!"
	if([[[NSBundle mainBundle] infoDictionary] objectForKey:signIdentity] == nil || 
	   [[[NSBundle mainBundle] infoDictionary] objectForKey:signIdentity] != nil)
	{
		checked = YES;
	}
	
	[signIdentity release];
	return checked;
}

#pragma mark -
#pragma mark Memory Management

#if kUseLeakyControllers
+ (void) unregisterLeakyController:(id) controller  {
	TexLegeAppDelegate *appDelegate = (TexLegeAppDelegate *)[[UIApplication sharedApplication] delegate];
	if ((appDelegate != nil) && (controller != nil)) {
		if ([appDelegate.leakyControllerStack containsObject:controller])
			[appDelegate.leakyControllerStack removeObject:controller];
	}

}

+ (void) flushLeakyControllers {
	TexLegeAppDelegate *appDelegate = (TexLegeAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate == nil) {
		return;
	}
	
	for (id controller in appDelegate.leakyControllerStack) {
		[controller didReceiveMemoryWarning];
		[UtilityMethods unregisterLeakyController:controller];
	}	
}

+ (void) registerLeakyController:(id) controller {
	TexLegeAppDelegate *appDelegate = (TexLegeAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate == nil) {
		return;
	}
	
	NSUInteger count = [appDelegate.leakyControllerStack count];
	
	// maximum of 2 leaky controllers
	if (count >= kMaxLeakyControllers) {
		// find the oldest leaky controller and "pop" it off the stack by telling it we're out of memory
		id firstController = [appDelegate.leakyControllerStack objectAtIndex:0];
		[firstController didReceiveMemoryWarning];
		[UtilityMethods unregisterLeakyController:firstController];
	}
	
	[appDelegate.leakyControllerStack addObject:controller];
	
}
#endif
@end
