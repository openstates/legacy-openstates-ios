#import "_SLFEvent.h"

@class EKEvent;
@class RKManagedObjectMapping;
@class SLFState;
@interface SLFEvent : _SLFEvent {}
@property (nonatomic,readonly) SLFState *state;
@property (nonatomic,readonly) NSString *dayForDisplay;
@property (nonatomic,readonly) NSString *dateStartForDisplay;
@property (nonatomic,readonly) NSTimeZone *eventTimeZone;
@property (nonatomic,readonly) NSString *title;
@property (nonatomic,readonly) EKEvent *ekEvent;
+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping;
+ (NSArray *)sortDescriptors;
@end
