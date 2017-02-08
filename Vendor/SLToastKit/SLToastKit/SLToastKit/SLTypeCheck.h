//
//  SLTypeCheck.h
//  Sleestacks
//
//  Created by Gregory Combs on 7/9/16.
//  Copyright (C) 2016 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.
//

#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED // alternatively, TARGET_OS_IPHONE ?
    #import <UIKit/UIKit.h>
#endif

#define SLTrueIfClass(c,o...)          (o != NULL && [(NSObject *)o isKindOfClass:[c class]])

#define SLValueIfClass(c,o...)         ((c *)(SLTrueIfClass(c,o) ? o : nil))

#define SLTypeIsNull(o...)             ((o) == NULL || SLTrueIfClass(NSNull,o))

#define SLTypeNumberOrNil(o...)        (SLValueIfClass(NSNumber,o))
#define SLTypeDecimalNumberOrNil(o...) (SLValueIfClass(NSDecimalNumber,o))
#define SLTypeDateOrNil(o...)          (SLValueIfClass(NSDate,o))
#define SLTypeDictionaryOrNil(o...)    (SLValueIfClass(NSDictionary,o))
#define SLTypeArrayOrNil(o...)         (SLValueIfClass(NSArray,o))
#define SLTypeURLOrNil(o...)           (SLValueIfClass(NSURL,o))
#define SLTypeStringOrNil(o...)        (SLValueIfClass(NSString,o))

#define SLTypeNonEmptyStringOrNil(o...)  ((SLTrueIfClass(NSString,o) && \
                                           [((NSString *)o) length]) ? o : nil)

#define SLTypeNonEmptyArrayOrNil(o...)   ((SLTrueIfClass(NSArray,o) && \
                                           [((NSArray *)o) count]) ? o : nil)

#define SLTypeNonEmptySetOrNil(o...)     ((SLTrueIfClass(NSSet,o) && \
                                           [((NSSet *)o) count]) ? o : nil)
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
    #define SLTypeImageOrNil(o...)         (SLValueIfClass(UIImage,o))
#endif
