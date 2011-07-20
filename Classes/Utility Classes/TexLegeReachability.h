//
//  TexLegeReachability.h
//  Created by Gregory Combs on 9/27/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <Foundation/Foundation.h>
#import "Reachability.h"


@interface TexLegeReachability : NSObject
{
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

- (void) startCheckingReachability;
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
