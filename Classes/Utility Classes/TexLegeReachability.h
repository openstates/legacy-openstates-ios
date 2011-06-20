//
//  TexLegeReachability.h
//  TexLege
//
//  Created by Gregory Combs on 9/27/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "Reachability.h"


@interface TexLegeReachability : NSObject
{
	id appDelegate;
	Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;	
	
	Reachability* openstatesReach;
	Reachability* texlegeReach;
	Reachability* tloReach;
	Reachability* googleReach;

}
@property NetworkStatus remoteHostStatus;
@property NetworkStatus internetConnectionStatus;
@property NetworkStatus localWiFiConnectionStatus;
@property NetworkStatus texlegeConnectionStatus;
@property NetworkStatus openstatesConnectionStatus;
@property NetworkStatus tloConnectionStatus;
@property NetworkStatus googleConnectionStatus;

- (void) startCheckingReachability:(id)delegate;
- (BOOL) isNetworkReachable;
- (BOOL) isNetworkReachableViaWiFi;

+ (TexLegeReachability *)sharedTexLegeReachability;
+ (BOOL)texlegeReachable;
+ (BOOL)openstatesReachable;

+ (BOOL) canReachHostWithURL:(NSURL *)url alert:(BOOL)doAlert;
+ (BOOL) canReachHostWithURL:(NSURL *)url;
+ (void) noInternetAlert;
+ (void) noHostAlert;
@end
