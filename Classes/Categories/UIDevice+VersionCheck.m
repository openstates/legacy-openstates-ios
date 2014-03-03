//
//  UIDevice+VersionCheck.m
//  OpenStates
//
//  Created by Daniel Cloud on 3/3/14.
//
//

#import "UIDevice+VersionCheck.h"

@implementation UIDevice (VersionCheck)

- (NSUInteger)systemMajorVersion {
    NSString *versionString;

    versionString = [self systemVersion];

    return (NSUInteger)[versionString doubleValue];
}

@end
