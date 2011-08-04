//
//  TexLegeReachability.m
//  Created by Gregory Combs on 9/27/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "TexLegeReachability.h"
#import "UtilityMethods.h"
#import "OpenLegislativeAPIs.h"
#import "SLFAlertView.h"

#define ALLOW_SLOW_DNS_LOOKUPS	0

@interface TexLegeReachability (Private)
- (void)updateStatusWithReachability:(Reachability*) curReach;
@end

@implementation TexLegeReachability

@synthesize remoteHostStatus, internetConnectionStatus, localWiFiConnectionStatus;
@synthesize texlegeConnectionStatus, tloConnectionStatus, openstatesConnectionStatus, googleConnectionStatus;

+ (id)sharedTexLegeReachability
{
	static dispatch_once_t pred;
	static TexLegeReachability *foo = nil;
	
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}

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
	nice_release(hostReach);
	nice_release(openstatesReach);
	nice_release(texlegeReach);
	nice_release(tloReach);
	nice_release(googleReach);
	nice_release(internetReach);
	nice_release(wifiReach);
	[super dealloc];
}

- (void)startCheckingReachability {
	
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
			if(connectionRequired) {
				RKLogWarning(@"Cellular data network is available.\n  Internet traffic will be routed through it after a connection is established.");
            }
			else {
				RKLogTrace(@"Cellular data network is active.\n  Internet traffic will be routed through it.");
            }
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
		
		id delegate = [[UIApplication sharedApplication] delegate];
		if (delegate && [delegate respondsToSelector:@selector(changingReachability:)])
			[delegate performSelector:@selector(changingReachability:) withObject:curReach];
				
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
		
	[SLFAlertView showWithTitle:NSLocalizedStringFromTable(@"Internet Unavailable", @"AppAlerts", @"Alert title, network access is unavailable.")
						message:NSLocalizedStringFromTable(@"This feature requires an Internet connection, and a connection is unavailable.  Your device may be in 'Airplane' mode or is suffering poor network coverage.", @"AppAlerts", @"") 
					buttonTitle:NSLocalizedStringFromTable(@"Cancel", @"StandardUI", @"Cancelling some activity")];
}

+ (void)noHostAlert {
		
	[SLFAlertView showWithTitle:NSLocalizedStringFromTable(@"Host Unreachable", @"AppAlerts", @"Internet host is down")
						message:NSLocalizedStringFromTable(@"There was a problem contacting the specified host, the URL may have changed or may contain typographical errors. Perhaps try the connection again later.", @"AppAlerts", @"")
					buttonTitle:NSLocalizedStringFromTable(@"Cancel", @"StandardUI", @"Cancelling some activity")]; 
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
#if ALLOW_SLOW_DNS_LOOKUPS
		Reachability *curReach = [Reachability reachabilityWithHostName:host];
		if (curReach) {
			NetworkStatus status = [curReach currentReachabilityStatus];
			reachable = status > NotReachable;
		}
#else
		reachable = [[TexLegeReachability sharedTexLegeReachability] isNetworkReachable];
#endif
	}
	return reachable;
}

+ (BOOL) canReachHostWithURL:(NSURL *)url alert:(BOOL)doAlert {
	BOOL reachableHost = NO;
	if (!url) {
		return NO;
	}
	if ([url isFileURL]) {
		return YES;
	}
	if (![[TexLegeReachability sharedTexLegeReachability] isNetworkReachable]) {
		if (doAlert) {
			[TexLegeReachability noInternetAlert];
		}
	}
	else if ([[url scheme] isEqualToString:@"twitter"] && 
			 [[UIApplication sharedApplication] canOpenURL:url]) {
		reachableHost = YES;
	}
	else if (![TexLegeReachability isHostReachable:[url host]]) {
		if (doAlert) {
			[TexLegeReachability noHostAlert];
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

