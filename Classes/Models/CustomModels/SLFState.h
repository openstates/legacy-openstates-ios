#import "_SLFState.h"
#import <RestKit/CoreData/CoreData.h>

@class RKManagedObjectMapping;
@interface SLFState : _SLFState {}
@property (nonatomic, readonly) NSString *stateInitial;
@property (nonatomic, readonly) UIImage *stateFlag;
@property (nonatomic, readonly) NSString *newsAddress;
@property (nonatomic, readonly) NSString *eventsFeedAddress;
@property (nonatomic, readonly) NSArray *sessions;
@property (nonatomic, readonly) NSString *latestSession;
@property (nonatomic, readonly) NSDictionary *sessionIndexesByDisplayName;
@property (nonatomic, readonly) NSArray *sessionDisplayNames;
@property (nonatomic, readonly) NSArray *chambers;
- (BOOL)isFeatureEnabled:(NSString *)feature;
- (NSString *)displayNameForSession:(NSString *)aSession;
- (NSInteger)sessionIndexForDisplayName:(NSString *)displayName;
+ (RKManagedObjectMapping *)mapping;
+ (NSArray *)sortDescriptors;
+ (NSString *)resourcePathForStateID:(NSString *)stateID;
@end

@interface RKManagedObjectMapping(SLFState)
- (void)connectStateToKeyPath:(NSString *)keyPath withStateMapping:(RKManagedObjectMapping *)stateMapping;
@end
