//
//  UIDevice+VersionCheck.m
//  OpenStates
//
//  Created by Daniel Cloud on 3/3/14.
//
//
// This work is licensed under the BSD-3 License included with this source
// distribution.


#import "UIDevice+VersionCheck.h"

@implementation UIDevice (VersionCheck)

- (NSUInteger)systemMajorVersion {
    NSString *versionString;

    versionString = [self systemVersion];

    return (NSUInteger)[versionString doubleValue];
}

@end
