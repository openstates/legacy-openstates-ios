#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "_SLFState.h"

@interface SLFState : _SLFState {}

- (NSString *)nameForChamber:(NSInteger)chamber;
- (BOOL)isFeatureEnabled:(NSString *)feature;

- (NSString *)displayNameForSession:(NSString *)aSession;

@end
