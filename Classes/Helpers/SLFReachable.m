//
//  SLFReachable.m
//  Created by Greg Combs on 10/7/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFReachable.h"
#import <RestKit/RestKit.h>
#import "SLFAlertView.h"

NSString * const SLFReachableStatusChangedForHostKey = @"SLFReachableStatusChangedForHost";
NSString * const SLFReachableAnyNetworkHost = @"ANY_INTERNET_HOST";

BOOL SLFIsReachableAddressNoAlert(NSString * urlString) {
    return [[SLFReachable sharedReachable] isURLStringReachable:urlString];
}

BOOL SLFIsReachableAddress(NSString * urlString) {
    if (SLFIsReachableAddressNoAlert(urlString))
        return YES;
    [SLFAlertView showWithTitle:NSLocalizedString(@"Unreachable Host", @"")
                        message:NSLocalizedString(@"This feature requires an Internet connection, and a connection is unavailable.  Your device may be in 'Airplane' mode or is experiencing poor network coverage.",@"")
                    buttonTitle:NSLocalizedString(@"Cancel",@"")];
    return NO;
}


@interface SLFReachable()
@property (nonatomic,retain) NSMutableDictionary *networkReachByKeys;
@property (nonatomic,retain) NSMutableDictionary *statusByHostKeys;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.networkReachByKeys = nil;
    self.statusByHostKeys = nil;
    self.localNotification = nil;
    [super dealloc];
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
    //[self beginCheckingHostReachability:hostReach];
    return YES;
}

- (void)beginCheckingHostReachability:(SCNetworkReachability *)hostReach {
    NSParameterAssert(hostReach);
    SCNetworkReachabilityFlags flags;
    if ([hostReach getFlags:&flags]) // must use synchronous for initial messages only
        [self changeReachability:hostReach forFlags:flags];
    [hostReach startNotifier];
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
    NSNumber *status = [NSNumber numberWithInt:reach];
    if (foundKey) {
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
        RKLogError(@"Specific host reachability for %@ is unknown because it is not presently monitored.", hostName);
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
