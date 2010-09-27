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
	Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;	
}
@property NetworkStatus remoteHostStatus;
@property NetworkStatus internetConnectionStatus;
@property NetworkStatus localWiFiConnectionStatus;

- (void)startCheckingReachability;
- (BOOL) isNetworkReachable;

+ (TexLegeReachability *)sharedTexLegeReachability;

+ (BOOL) canReachHostWithURL:(NSURL *)url alert:(BOOL)doAlert;
+ (BOOL) canReachHostWithURL:(NSURL *)url;
+ (void) noInternetAlert;

@end
