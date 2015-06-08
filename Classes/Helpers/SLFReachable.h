//
//  SLFReachable.h
//  Created by Greg Combs on 10/7/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <Foundation/Foundation.h>
#import "SCNetworkReachabilityKit.h"


@interface SLFReachable : NSObject

+ (SLFReachable *)sharedReachable;
- (BOOL)watchHostNamed:(NSString *)hostName;
- (void)watchHostsInSet:(NSSet *)hosts;
- (BOOL)isHostReachable:(NSString *)hostName;
- (BOOL)isNetworkReachable;
- (NSNumber *)statusForHostNamed:(NSString *)hostName;
- (BOOL)isURLStringReachable:(NSString *)urlString;
- (BOOL)isURLReachable:(NSURL *)url;
@property (nonatomic,retain) NSNotificationCenter *localNotification;
@end

extern NSString * const SLFReachableStatusChangedForHostKey;
extern NSString * const SLFReachableAnyNetworkHost;
BOOL SLFIsReachableAddressNoAlert(NSString *);
BOOL SLFIsReachableAddress(NSString *);
