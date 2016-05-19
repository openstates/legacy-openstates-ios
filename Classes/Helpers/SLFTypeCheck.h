//
//  SLFTypeCheck.h
//  Open States iOS
//
//  Created by Gregory Combs on 7/9/16.
//

@import Foundation;

#if __IPHONE_OS_VERSION_MIN_REQUIRED // alternatively, TARGET_OS_IPHONE ?
@import UIKit;
#endif

#define SLFTrueIfClass(c,o...)          (o != NULL && \
                                         [(NSObject *)o isKindOfClass:[c class]])

#define SLFValueIfClass(c,o...)         ((c *)(SLFTrueIfClass(c,o) ? o : nil))

#define SLFTypeIsNull(o...)             ((o) == NULL || \
                                         SLFTrueIfClass(NSNull,o))

#define SLFTypeNumberOrNil(o...)        (SLFValueIfClass(NSNumber,o))
#define SLFTypeDecimalNumberOrNil(o...) (SLFValueIfClass(NSDecimalNumber,o))
#define SLFTypeDateOrNil(o...)          (SLFValueIfClass(NSDate,o))
#define SLFTypeDictionaryOrNil(o...)    (SLFValueIfClass(NSDictionary,o))
#define SLFTypeArrayOrNil(o...)         (SLFValueIfClass(NSArray,o))
#define SLFTypeURLOrNil(o...)           (SLFValueIfClass(NSURL,o))
#define SLFTypeStringOrNil(o...)        (SLFValueIfClass(NSString,o))

#define SLFTypeNonEmptyStringOrNil(o...)  ((SLFTrueIfClass(NSString,o) && \
                                           [((NSString *)o) length]) ? o : nil)

#define SLFTypeNonEmptyArrayOrNil(o...)   ((SLFTrueIfClass(NSArray,o) && \
                                           [((NSArray *)o) count]) ? o : nil)

#define SLFTypeNonEmptySetOrNil(o...)     ((SLFTrueIfClass(NSSet,o) && \
                                           [((NSSet *)o) count]) ? o : nil)

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
#  define SLFTypeImageOrNil(o...)         (SLFValueIfClass(UIImage,o))
#endif
