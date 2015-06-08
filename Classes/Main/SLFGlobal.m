//
//  SLFGlobal.m
//  Created by Greg Combs on 11/28/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFGlobal.h"

BOOL IsEmpty(NSObject * thing) {
    return thing == nil
	|| ([[NSNull null] isEqual:thing])
	|| ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0)
	|| ([thing respondsToSelector:@selector(count)] && [(NSArray *)thing count] == 0);
}

