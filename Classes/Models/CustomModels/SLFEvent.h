#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "_SLFEvent.h"

@class SLFState;
@interface SLFEvent : _SLFEvent {}
@property (nonatomic,readonly) SLFState *state;
+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping;
+ (NSArray *)sortDescriptors;
@end
