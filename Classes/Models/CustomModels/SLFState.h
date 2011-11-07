#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "_SLFState.h"


@interface SLFState : _SLFState {}
- (BOOL)isFeatureEnabled:(NSString *)feature;
- (NSString *)displayNameForSession:(NSString *)aSession;
@property (nonatomic, readonly) NSString *stateInitial;
@property (nonatomic, readonly) UIImage *stateFlag;
@property (nonatomic, readonly) NSString *newsAddress;
@property (nonatomic, readonly) NSArray *sessions;
@property (nonatomic, readonly) NSString *latestSession;
@property (nonatomic, readonly) NSDictionary *sessionIndexesByDisplayName;
@end

extern NSString * const SLFSelectedStateDidChangeNotification;
NSString* SLFSelectedStateID(void);
SLFState* SLFSelectedState(void);
void SLFSaveSelectedState(SLFState *);
void SLFSaveSelectedStateID(NSString *);

extern NSString * const SLFSelectedSessioneDidChangeNotification;
NSDictionary* SLFSelectedSessionsByStateID(void);
NSString* SLFSelectedSessionForState(SLFState *state);
NSString* SLFSelectedSession(void);
void SLFSaveSelectedSessionForState(NSString *session, SLFState *state);
void SLFSaveSelectedSession(NSString *session);
NSString* FindOrCreateSelectedSessionForState(SLFState *state);
