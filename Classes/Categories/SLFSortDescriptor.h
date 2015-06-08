//
//  SLFSortDescriptor.h
//  Created by Greg Combs on 11/16/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <Foundation/Foundation.h>

@interface SLFSortDescriptor : NSSortDescriptor
+ (NSSortDescriptor *)stringSortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending;
@end
