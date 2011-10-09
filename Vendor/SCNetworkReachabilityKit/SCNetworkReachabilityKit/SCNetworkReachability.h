// SCNetworkReachabilityKit SCNetworkReachability.h
//
// Copyright © 2011, Roy Ratcliffe, Pioneering Software, United Kingdom
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the “Software”), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS,” WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

extern NSString *kSCNetworkReachabilityDidChangeNotification;
extern NSString *kSCNetworkReachabilityFlagsKey;

/*!
 * Reachable via WWAN only occurs on iOS platforms.
 */
enum
{
	kSCNetworkNotReachable,
	kSCNetworkReachableViaWiFi,
	kSCNetworkReachableViaWWAN,
};

typedef NSUInteger SCNetworkReachable;

@interface SCNetworkReachability : NSObject
{
@private
	SCNetworkReachabilityRef networkReachability;
	BOOL isLinkLocalInternetAddress;
}

/*!
 * Answers YES if the Network Reachability object wraps a link-local Internet
 * address, such as a local wi-fi network. This becomes YES whenever you
 * construct an SCNetworkReachability instance using an Internet address
 * belonging to the link-local subnet, a class B network equal to
 * IN_LINKLOCALNETNUM.
 *
 * The implementation has to store a boolean value to remember whether or not
 * the underlying SCNetworkReachabilityRef opaque object was instantiate with or
 * without an Internet link-local address. The answer to this question alters
 * the reachability response. This boolean would not be necessary if the System
 * Configuration API would give access to the underlying address. You could then
 * query the address on demand.
 */
@property(readonly) BOOL isLinkLocalInternetAddress;

- (id)initWithAddress:(const struct sockaddr *)address;
- (id)initWithLocalAddress:(const struct sockaddr *)localAddress remoteAddress:(const struct sockaddr *)remoteAddress;
- (id)initWithName:(NSString *)name;

+ (SCNetworkReachability *)networkReachabilityForAddress:(const struct sockaddr *)address;
+ (SCNetworkReachability *)networkReachabilityForInternetAddress:(in_addr_t)internetAddress;
+ (SCNetworkReachability *)networkReachabilityForInternet;
+ (SCNetworkReachability *)networkReachabilityForLinkLocal;
+ (SCNetworkReachability *)networkReachabilityForName:(NSString *)name;

/*!
 * Acquires the current network reachability flags, answering YES if
 * successfully acquired; answering NO otherwise.
 *
 * Beware! The System Configuration framework operates synchronously by
 * default. See Technical Q&A QA1693, Synchronous Networking On The Main
 * Thread. Asking for flags blocks the current thread and potentially kills your
 * iOS application if the reachability enquiry does not respond before the
 * watchdog times out.
 */
- (BOOL)getFlags:(SCNetworkReachabilityFlags *)outFlags;

- (BOOL)startNotifier;
- (BOOL)stopNotifier;

/*!
 * Interprets the given network reachability flags, answering one of three
 * reachable conclusions: not reachable, reachable via wi-fi or reachable via
 * wireless wide-area network.
 *
 * The method translates the given combination of reachability flags within the
 * context of this network reachability object. The flags originate from
 * -getFlags:outFlags or from a reachability notification, where you can extract
 * the up-to-date flags by sending -[NSNotification userInfo] and asking for the
 * kSCNetworkReachabilityFlagsKey. The key returns an NSNumber whose unsigned
 * integer value gives the flags.
 */
- (SCNetworkReachable)networkReachableForFlags:(SCNetworkReachabilityFlags)flags;

@end
