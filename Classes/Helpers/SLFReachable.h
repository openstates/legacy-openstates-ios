//
//  SLFReachable.h
//  Created by Greg Combs on 10/7/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

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
