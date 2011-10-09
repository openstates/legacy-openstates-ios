# System Configuration Network Reachability Kit

SCNetworkReachabilityKit provides Objective-C wrappers for the network reachability API found in Apple's System Configuration framework. You can find an iOS-based sample application at [GitHub](https://github.com/royratcliffe/SCNetworkReachability).

## Aims and Objectives

This project aims to provide a multi-platform thread-aware network reachability toolkit for Apple platforms. The basic problem: Apple's SystemConfiguration framework currently provides an entirely C-based synchronous API.

The project incorporates two targets: an OS X framework and an iOS static library. You can compile the project sources for iOS 4.3 and above, or for OS X 10.6 or above.

## Based on Open-Source Sample

The SCNetworkReachabilityKit is largely based on Apple's open-source sample project “Reachability.” Apple's sample does not however properly handle cross-platform compilation. It assumes an iOS platform. Consequently, compiling for OS X fails.

In addition, Apple's sample does not include any unit testing, nor _directly_ addresses the threading issue. Apple's SystemConfiguration.framework is entirely synchronous. That means asking for the network reachability flags blocks the current thread until reachability resolves. This may take a second or two—within range to trigger the iOS watchdog.

Much better if reachability notifies the application. The framework provides such an interface. However, the sample code does not let you use the notification-supplied reachability flags; you still need to invoke the blocking method.

This kit factors out the reachable status allowing applications to receive notifications fully loaded with the necessary reachability information and assess the reachable status without ever accessing the underlying synchronous API.

## Future Directions

This work might become redundant. Apple may provide their own Objective-C wrappers at some point in the future. That makes this project a little presumptuous, but useful in the meantime.
