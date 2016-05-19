//
//  SLFObjectQueue.h
//  
//
//  Created by Gregory Combs on 7/8/16.
//
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface SLFObjectQueue<__covariant QueueItemType:NSObject<NSCopying> *> : NSObject <NSCopying, NSFastEnumeration>

- (instancetype)initWithName:(NSString *)name NS_DESIGNATED_INITIALIZER;
- (nullable QueueItemType)objectAtIndex:(NSUInteger)index;
- (nullable QueueItemType)pop;
- (void)push:(QueueItemType)object;
- (BOOL)removeObject:(QueueItemType)object;
- (BOOL)containsObject:(QueueItemType)object;

@property (readonly) NSUInteger count;
@property (copy,readonly) NSString *name;

@end

NS_ASSUME_NONNULL_END
