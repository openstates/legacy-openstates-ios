#import "_SLFEvent.h"

@class EKEvent;
@class RKManagedObjectMapping;
@class SLFState;
@interface SLFEvent : _SLFEvent {}
@property (weak, nonatomic,readonly) SLFState *state;
@property (weak, nonatomic,readonly) NSString *dayForDisplay;
@property (weak, nonatomic,readonly) NSString *dateStartForDisplay;
@property (weak, nonatomic,readonly) NSString *timeStartForDisplay;
@property (weak, nonatomic,readonly) NSTimeZone *eventTimeZone;
@property (weak, nonatomic,readonly) NSString *title;
@property (weak, nonatomic,readonly) EKEvent *ekEvent;
+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping;
+ (NSArray *)sortDescriptors;
@end
