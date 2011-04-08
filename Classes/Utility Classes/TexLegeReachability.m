//
//  TexLegeReachability.m
//  TexLege
//
//  Created by Gregory Combs on 9/27/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TexLegeReachability.h"
#import "UtilityMethods.h"
#import "OpenLegislativeAPIs.h"

@interface TexLegeReachability (Private)
- (void)updateStatusWithReachability:(Reachability*) curReach;
@end

@implementation TexLegeReachability
SYNTHESIZE_SINGLETON_FOR_CLASS(TexLegeReachability);

@synthesize remoteHostStatus, internetConnectionStatus, localWiFiConnectionStatus;
@synthesize texlegeConnectionStatus, tloConnectionStatus, openstatesConnectionStatus, googleConnectionStatus;

#pragma mark - 
#pragma mark Reachability

/*
 Remote Host Reachable
 Not reachable | Reachable via EDGE | Reachable via WiFi
 
 Connection to Internet
 Not available | Available via EDGE | Available via WiFi
 
 Connection to Local Network.
 Not available | Available via WiFi
 */

- (void)dealloc {
	[hostReach release];
	[openstatesReach release];
	[texlegeReach release];
	[tloReach release];
	[googleReach release];
	[internetReach release];
	[wifiReach release];
	[super dealloc];
}

- (void)startCheckingReachability:(id)delegate {
	if (delegate)
		appDelegate = delegate;
	
	// Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	
	hostReach = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
	[hostReach startNotifier];
	[self updateStatusWithReachability: hostReach];
	
	openstatesReach = [[Reachability reachabilityWithHostName:osApiHost] retain];
	[openstatesReach startNotifier];
	[self updateStatusWithReachability: openstatesReach];
	
	googleReach = [[Reachability reachabilityWithHostName:@"maps.google.com"] retain];
	[googleReach startNotifier];
	[self updateStatusWithReachability: googleReach];
	
	texlegeReach = [[Reachability reachabilityWithHostName:RESTKIT_HOST] retain];
	[texlegeReach startNotifier];
	[self updateStatusWithReachability: texlegeReach];
	
	tloReach = [[Reachability reachabilityWithHostName:tloApiHost] retain];
	[tloReach startNotifier];
	[self updateStatusWithReachability: tloReach];
	
	internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifier];
	[self updateStatusWithReachability: internetReach];
	
    wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
	[wifiReach startNotifier];
	[self updateStatusWithReachability: wifiReach];
}

- (void)reachabilityChanged:(NSNotification *)note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateStatusWithReachability: curReach];
}

- (void)updateStatusWithReachability:(Reachability*) curReach
{
	NetworkStatus currentStatus = [curReach currentReachabilityStatus];
	
	if(curReach == hostReach)
	{
        self.remoteHostStatus = currentStatus;
        BOOL connectionRequired= [curReach connectionRequired];
		if (self.remoteHostStatus != ReachableViaWWAN) {
			if(connectionRequired)
				NSLog(@"Cellular data network is available.\n  Internet traffic will be routed through it after a connection is established.");
			else
				NSLog(@"Cellular data network is active.\n  Internet traffic will be routed through it.");
		}
	}
	else if(curReach == internetReach)
	{	
		self.internetConnectionStatus = currentStatus;
	}
	else if(curReach == wifiReach)
	{	
		self.localWiFiConnectionStatus = currentStatus;
	}
	else {
		if(curReach == googleReach)
			self.googleConnectionStatus = currentStatus;
		if(curReach == texlegeReach)
			self.texlegeConnectionStatus = currentStatus;
		if(curReach == openstatesReach)
			self.openstatesConnectionStatus = currentStatus;
		if(curReach == tloReach)
			self.tloConnectionStatus = currentStatus;
		
		if (appDelegate && [appDelegate respondsToSelector:@selector(changingReachability:)])
			[appDelegate performSelector:@selector(changingReachability:) withObject:curReach];
				
	}
}

#pragma mark -
#pragma mark Alerts and Convenience Methods

+ (BOOL)texlegeReachable {
	return [[TexLegeReachability sharedTexLegeReachability] texlegeConnectionStatus] > NotReachable;
}

+ (BOOL)openstatesReachable {
	return [[TexLegeReachability sharedTexLegeReachability] openstatesConnectionStatus] > NotReachable;
}

+ (void)noInternetAlert {
	UIAlertView *noInternetAlert = [[[ UIAlertView alloc ] 
									 initWithTitle:[UtilityMethods texLegeStringWithKeyPath:@"Reachability.NoInternetTitle"]
									 message:[UtilityMethods texLegeStringWithKeyPath:@"Reachability.NoInternetText"] 
									 delegate:nil // we're static, so don't do "self"
									 cancelButtonTitle: @"Cancel" 
									 otherButtonTitles:nil, nil] autorelease];
	[ noInternetAlert show ];		
}


- (BOOL) isNetworkReachable {
	BOOL reachable = YES;
	
	reachable = (self.internetConnectionStatus != NotReachable);
	
	return reachable;
}

- (BOOL) isNetworkReachableViaWiFi {
	BOOL reachable = (self.internetConnectionStatus == ReachableViaWiFi);

	return reachable;
}

+ (BOOL) isHostReachable:(NSString *)host {
	BOOL reachable = YES;
	
	if ([host isEqualToString:RESTKIT_HOST])
		reachable = [[TexLegeReachability sharedTexLegeReachability] texlegeConnectionStatus] > NotReachable;
	else if ([host isEqualToString:tloApiHost])
		reachable = [[TexLegeReachability sharedTexLegeReachability] tloConnectionStatus] > NotReachable;
	else if ([host isEqualToString:osApiHost])
		reachable = [[TexLegeReachability sharedTexLegeReachability] openstatesConnectionStatus] > NotReachable;
	else {
		Reachability *curReach = [Reachability reachabilityWithHostName:host];
		if (curReach) {
			NetworkStatus status = [curReach currentReachabilityStatus];
			reachable = status > NotReachable;
		}
	}
	return reachable;
}

+ (BOOL) canReachHostWithURL:(NSURL *)url alert:(BOOL)doAlert {
	UIAlertView * alert = nil;	
	BOOL reachableHost = NO;
	if (!url)
		return NO;
	
	if ([url isFileURL])
		return YES;
	
	if (![[TexLegeReachability sharedTexLegeReachability] isNetworkReachable]) {
		if (doAlert)
			[TexLegeReachability noInternetAlert];
	}
	else if ([[url scheme] isEqualToString:@"twitter"] && 
			 [[UIApplication sharedApplication] canOpenURL:url])
		reachableHost = YES;
	
	else if (![TexLegeReachability isHostReachable:[url host]]) {
		if (doAlert) {
			alert = [[[ UIAlertView alloc ] 
					  initWithTitle:[UtilityMethods texLegeStringWithKeyPath:@"Reachability.NoHostTitle"] 
					  message:[UtilityMethods texLegeStringWithKeyPath:@"Reachability.NoHostText"] 
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
	
	return [TexLegeReachability canReachHostWithURL:url alert:YES];
}

@end

