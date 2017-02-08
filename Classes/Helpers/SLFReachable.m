//
//  SLFReachable.m
//  Created by Greg Combs on 10/7/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFReachable.h"
#import "SLFLog.h"
#import <SLFRestKit/RestKit.h>
#import "SLFAlertView.h"
#import "SLToastManager+OpenStates.h"

NSString * const SLFReachableStatusChangedForHostKey = @"SLFReachableStatusChangedForHost";
NSString * const SLFReachableAnyNetworkHost = @"ANY_INTERNET_HOST";

@interface SLFReachable()
@property (nonatomic,strong) NSMutableDictionary *networkReachByKeys;
@property (nonatomic,strong) NSMutableDictionary *statusByHostKeys;
@property (nonatomic,strong) NSMutableDictionary *observersByURL;
- (void)beginCheckingHostReachability:(SCNetworkReachability *)hostReach;
- (void)notifyReachabilityChanged:(NSNotification *)notification;
- (void)changeReachability:(SCNetworkReachability *)netReach forFlags:(SCNetworkReachabilityFlags)flags;
@end

@implementation SLFReachable
@synthesize networkReachByKeys;
@synthesize statusByHostKeys;
@synthesize localNotification;
+ (SLFReachable *)sharedReachable
{
    static dispatch_once_t pred;
    static SLFReachable *foo = nil;
    dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
    return foo;
}

- (SLFReachable *)init {
    self = [super init];
    if (self) {
        _observersByURL = [[NSMutableDictionary alloc] initWithCapacity:10];
        localNotification = [[NSNotificationCenter alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyReachabilityChanged:) name:kSCNetworkReachabilityDidChangeNotification object:nil];
        self.statusByHostKeys = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:kSCNetworkNotReachable] forKey:SLFReachableAnyNetworkHost];
        SCNetworkReachability *anyNet = [SCNetworkReachability networkReachabilityForInternet];
        self.networkReachByKeys = [NSMutableDictionary dictionaryWithObject:anyNet forKey:SLFReachableAnyNetworkHost];
        [self beginCheckingHostReachability:anyNet];        
    }
    return self;
}

- (void)dealloc {
    for (SCNetworkReachability *reachability in self.networkReachByKeys)
        [reachability stopNotifier];
    NSNotificationCenter *center = self.localNotification;
    [self.observersByURL enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop) {
        [center removeObserver:obj];
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)watchHostsInSet:(NSSet *)hosts {
    NSParameterAssert(hosts);
    for (NSString *host in hosts)
        [self watchHostNamed:host];
}

- (BOOL)watchHostNamed:(NSString *)hostName {
    NSParameterAssert(hostName);
    if ([[self.networkReachByKeys allKeys] containsObject:hostName])
        return NO;
    SCNetworkReachability *hostReach = [SCNetworkReachability networkReachabilityForName:hostName];
    [self.networkReachByKeys setObject:hostReach forKey:hostName];
    [self.statusByHostKeys setObject:[NSNumber numberWithInt:kSCNetworkNotReachable] forKey:hostName];
    [self performSelectorInBackground:@selector(beginCheckingHostReachability:) withObject:hostReach];
    return YES;
}

- (void)beginCheckingHostReachability:(SCNetworkReachability *)hostReach {
    NSParameterAssert(hostReach);
    SCNetworkReachabilityFlags flags;
    @autoreleasepool {
        if ([hostReach getFlags:&flags]) // must use synchronous for initial messages only
            [self changeReachability:hostReach forFlags:flags];
        [hostReach startNotifier];
    }
}

- (void)notifyReachabilityChanged:(NSNotification *)notification
{
    SCNetworkReachability *netReach = [notification object];
    SCNetworkReachabilityFlags flags = [[[notification userInfo] objectForKey:kSCNetworkReachabilityFlagsKey] unsignedIntValue];
    [self changeReachability:netReach forFlags:flags];
}

- (void)changeReachability:(SCNetworkReachability *)netReach forFlags:(SCNetworkReachabilityFlags)flags
{    
    NSParameterAssert(netReach);
    __block NSString *foundKey = nil;
    [self.networkReachByKeys enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj == netReach) {
            foundKey = (NSString *)key;
            *stop = YES;
        }            
    }];
    SCNetworkReachable reach = [netReach networkReachableForFlags:flags];
    NSNumber *status = @(reach);
    if (foundKey)
    {
        [self.statusByHostKeys setObject:status forKey:foundKey];
        [self.localNotification postNotificationName:SLFReachableStatusChangedForHostKey object:foundKey];
    }
}

- (NSNumber *)statusForHostNamed:(NSString *)hostName {
    NSParameterAssert(hostName);
    return [self.statusByHostKeys objectForKey:hostName];
}

- (BOOL)isNetworkReachable {
    NSNumber *status = [self statusForHostNamed:SLFReachableAnyNetworkHost];
    return ( status != NULL && [status intValue] > kSCNetworkNotReachable);
}

- (BOOL)isHostReachable:(NSString *)hostName {
    NSParameterAssert(hostName);
    if (![self isNetworkReachable])
        return NO;
    NSNumber *status = [self statusForHostNamed:hostName];
    if (!status) {
        os_log_debug([SLFLog common], "Specific host reachability for %s{public} is unknown because it is not presently monitored", hostName);
        return YES;
    }
    return ([status intValue] > kSCNetworkNotReachable);
}

- (BOOL)isURLReachable:(NSURL *)url {
    if (!url)
        return NO;
    if ([url isFileURL])
        return YES;
    return [self isHostReachable:[url host]];
}

- (BOOL)isURLStringReachable:(NSString *)urlString {
    if (!urlString)
        return NO;
    return [self isURLReachable:[NSURL URLWithString:urlString]];
}

@end

BOOL SLFIsReachableAddressNoAlert(NSString * urlString) {
    return [[SLFReachable sharedReachable] isURLStringReachable:urlString];
}

BOOL SLFIsReachableAddress(NSString * urlString) {
    if (SLFIsReachableAddressNoAlert(urlString))
        return YES;
    [[SLToastManager opstSharedManager] addToastWithIdentifier:@"SLFReachable-Unreachable-Host"
                                                          type:SLToastTypeError
                                                         title:NSLocalizedString(@"Network Failure!",nil)
                                                      subtitle:NSLocalizedString(@"Check your internet connection and try again later.",nil)
                                                         image:nil duration:2];
    return NO;
}

void SLFIsReachableAddressAsync(NSURL * url, SLFReachabilityCompletionHandler completion) {
    if (!url || !completion)
        return;
    SLFReachable *reachability = [SLFReachable sharedReachable];
    if (![reachability isNetworkReachable])
    {
        completion(url,NO);
        return;
    }
    NSString *host = url.host;
    NSNumber *status = [reachability statusForHostNamed:host];
    if (!status)
    {
        NSNotificationCenter *center = reachability.localNotification;
        id observer = [center addObserverForName:SLFReachableStatusChangedForHostKey object:host queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * note) {
            SLFReachable *reachability = [SLFReachable sharedReachable];
            BOOL isReachable = [reachability isURLReachable:url];
            @try {
                NSNotificationCenter *center = reachability.localNotification;
                id observer = reachability.observersByURL[url];
                if (isReachable && observer)
                {
                    
                    [center removeObserver:observer];
                    [reachability.observersByURL removeObjectForKey:url];
                }
                completion(url,isReachable);
            } @catch (NSException *exception) {
            }
        }];

        reachability.observersByURL[url] = observer;
        [reachability watchHostNamed:host];
        return;
    }
    BOOL isReachable = [reachability isURLReachable:url];
    completion(url,isReachable);
}
