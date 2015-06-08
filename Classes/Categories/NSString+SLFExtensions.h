//
//  NSString+SLFExtensions.h
//  Created by Greg Combs on 11/20/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <Foundation/Foundation.h>

@interface NSString (SLFExtensions)
- (BOOL)isEqualToString:(NSString *)aString caseInsensitive:(BOOL)caseInsensitive;
- (BOOL)hasSubstring:(NSString *)search caseInsensitive:(BOOL)caseInsensitive;
- (BOOL)hasSubstring:(NSString *)search;
@end
