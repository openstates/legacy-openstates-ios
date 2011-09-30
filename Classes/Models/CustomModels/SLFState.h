#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "_SLFState.h"


@interface SLFState : _SLFState {}
- (BOOL)isFeatureEnabled:(NSString *)feature;
- (NSString *)displayNameForSession:(NSString *)aSession;
@property (nonatomic, readonly) NSString *stateInitial;
@property (nonatomic, readonly) UIImage *stateFlag;
@end

extern NSString * const SLFSelectedStateDidChangeNotification;

/* Convenience functions for pulling user's state settings  from NSUserDefaults efficiently */
NSString* SLFSelectedStateID(void);
SLFState* SLFSelectedState(void);
void SLFSaveSelectedState(SLFState *);
void SLFSaveSelectedStateID(NSString *);
