//
//  SLFActionPathRegistry.h
//  Created by Greg Combs on 12/5/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <Foundation/Foundation.h>

@interface SLFActionPathRegistry : NSObject
+ (SLFActionPathRegistry *)sharedRegistry;
+ (NSString *)patternForClass:(Class)controllerClass;
+ (NSString *)interpolatePathForClass:(Class)controllerClass withResourceID:(NSString *)resourceID;
@end
