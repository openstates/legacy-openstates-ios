#import "_SLFState.h"
#import <SLFRestKit/CoreData.h>

@class RKManagedObjectMapping;
@interface SLFState : _SLFState {}
@property (weak, nonatomic, readonly) NSString *title;
@property (weak, nonatomic, readonly) NSString *subtitle;
@property (weak, nonatomic, readonly) NSString *stateInitial;
@property (weak, nonatomic, readonly) NSString *stateIDForDisplay;
@property (weak, nonatomic, readonly) NSString *newsAddress;
@property (weak, nonatomic, readonly) NSString *eventsFeedAddress;
@property (weak, nonatomic, readonly) NSArray *sessions;
@property (weak, nonatomic, readonly) NSString *latestSession;
@property (weak, nonatomic, readonly) NSDictionary *sessionIndexesByDisplayName;
@property (weak, nonatomic, readonly) NSArray *sessionDisplayNames;
@property (weak, nonatomic, readonly) NSArray *chambers;
@property (nonatomic, readonly) BOOL isUnicameral;
@property (weak, nonatomic, readonly) NSArray *sortedCapitolMaps;
- (BOOL)isFeatureEnabled:(NSString *)feature;
- (NSString *)displayNameForSession:(NSString *)aSession;
- (NSInteger)sessionIndexForDisplayName:(NSString *)displayName;
+ (RKManagedObjectMapping *)mapping;
+ (NSArray *)sortDescriptors;
+ (NSString *)resourcePathForStateID:(NSString *)stateID;
+ (NSString *)resourcePathForAll;
@end

@interface RKManagedObjectMapping(SLFState)
- (void)connectStateToKeyPath:(NSString *)keyPath withStateMapping:(RKManagedObjectMapping *)stateMapping;
@end
