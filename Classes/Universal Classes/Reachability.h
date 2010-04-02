/*
 
 File: Reachability.h
 Abstract: SystemConfiguration framework wrapper.
 
 Version: 1.5
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2008 Apple Inc. All Rights Reserved.
 
 */


/*
 Reachability
 
 ===========================================================================
 DESCRIPTION:
 
 The Reachability sample application demonstrates how to use the System
 Configuration 
 framework to determine the network state of an iPhone or iPod touch. In
 particular, 
 it demonstrates how to know when IP traffic might be routed through a carrier 
 data network interface (such as EDGE).
 
 The Reachability class provides methods to query the state of the network,
 which tells you
 which network interfaces are available on the device. They return
 one of the values in the NetworkStatus enumeration, which include NotReachable,
 
 ReachableViaCarrierDataNetwork, and ReachableViaWiFiNetwork. The availability
 of network
 interfaces does not tell you if a given host is reachable. For that, the
 Reachability class
 lets you query the reachability of a given host.
 
 The Reachability class operates in two modes: With and without network status
 changes enabled.
 In the default state, it returns the results of the queries you make
 synchronously, which tells
 you the state of the device's network interfaces at the time of the query. In
 the other state,
 Reachability runs asynchronously and will report back changes to the network
 state and to the
 reachability of remote hosts as those changes happen.
 
 ===========================================================================
 USING THE SAMPLE
 
 Build and run the sample using Xcode. When running the iPhone OS simulator, 
 you can exercise the application by disconnecting the Ethernet cable, turning
 off 
 AirPort, or by joining an ad-hoc local WiFi network. If running in asychronous
 mode,
 the application updates to reflect the new network state of the device. If
 running in
 the default, synchronous mode, you'll have to restart the application in the
 simulator
 to get it to reflect the new network state.
 
 By default, the application uses www.apple.com as the remote host to query to
 determine
 reachability. You can change the host it uses in ReachabilityAppDelegate.m, and
 you can also
 supply an IP address. To do that comment out the line that includes 
 "[[Reachability sharedReachability] setHostName:[self hostName]]" and uncomment
 the 
 line that includes "[[Reachability sharedReachability] setAddress:@"0.0.0.0"]",
 changing
 the IP address to a different one.
 
 To enable asynchronous network state change notifications, uncomment the line
 in
 ReachabilityAppDelegate.m that includes [[Reachability sharedReachability]
 setNetworkStatusNotificationsEnabled:YES];
 
 ===========================================================================
 BUILD REQUIREMENTS
 
 Mac OS X 10.5.3, Xcode 3.1, iPhone OS 2.0
 
 ===========================================================================
 RUNTIME REQUIREMENTS
 
 Mac OS X 10.5.3, iPhone OS 2.0
 
 ===========================================================================
 PACKAGING LIST
 
 Reachability.h
 Reachability.m
 SystemConfiguration framework wrapper.
 
 ReachabilityAppDelegate.h
 ReachabilityAppDelegate.m
 Class that is the application's controller.
 
 ReachabilityTableCell.h
 ReachabilityTableCell.m
 Custom table cell.
 
 ===========================================================================
 CHANGES FROM PREVIOUS VERSIONS
 
 Version 1.5
 - Updated for and tested with iPhone OS 2.0. First public release.
 
 Version 1.4
 - Updated for Beta 7.
 
 Version 1.3
 - Updated for Beta 6.
 - Added LSRequiresIPhoneOS key to Info.plist.
 
 Version 1.2
 - Updated for Beta 4. Added code signing.
 
 Version 1.1
 - Updated for Beta 3 to use a nib file.
 
 Copyright (C)2008 Apple Inc. All rights reserved.
 
 */

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>

@class Reachability;

@interface Reachability : NSObject {
    
@private
    BOOL _networkStatusNotificationsEnabled;
    
    NSString *_hostName;
    NSString *_address;
    
    NSMutableDictionary *_reachabilityQueries;
}

/*
 An enumeration that defines the return values of the network state
 of the device.
 */
typedef enum {
    NotReachable = 0,
    ReachableViaCarrierDataNetwork,
    ReachableViaWiFiNetwork
} NetworkStatus;


// Set to YES to register for changes in network status. Otherwise reachability queries
// will be handled synchronously.
@property BOOL networkStatusNotificationsEnabled;
// The remote host whose reachability will be queried.
// Either this or 'addressName' must be set.
@property (nonatomic, retain) NSString *hostName;
// The IP address of the remote host whose reachability will be queried.
// Either this or 'hostName' must be set.
@property (nonatomic, retain) NSString *address;
// A cache of ReachabilityQuery objects, which encapsulate a SCNetworkReachabilityRef, a host or address, and a run loop. The keys are host names or addresses.
@property (nonatomic, assign) NSMutableDictionary *reachabilityQueries;

// This class is intended to be used as a singleton.
+ (Reachability *)sharedReachability;

// Is self.hostName is not nil, determines its reachability.
// If self.hostName is nil and self.address is not nil, determines the reachability of self.address.
- (NetworkStatus)remoteHostStatus;
// Is the device able to communicate with Internet hosts? If so, through which network interface?
- (NetworkStatus)internetConnectionStatus;
// Is the device able to communicate with hosts on the local WiFi network? (Typically these are Bonjour hosts).
- (NetworkStatus)localWiFiConnectionStatus;

- (BOOL)isHostReachable:(NSString *)host;

/*
 When reachability change notifications are posted, the callback method 'ReachabilityCallback' is called
 and posts a notification that the client application can observe to learn about changes.
 */
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info);

@end

@interface ReachabilityQuery : NSObject
{
@private
    SCNetworkReachabilityRef _reachabilityRef;
    CFMutableArrayRef _runLoops;
    NSString *_hostNameOrAddress;
}
// Keep around each network reachability query object so that we can
// register for updates from those objects.
@property (nonatomic) SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic, retain) NSString *hostNameOrAddress;
@property (nonatomic) CFMutableArrayRef runLoops;

- (void)scheduleOnRunLoop:(NSRunLoop *)inRunLoop;

@end