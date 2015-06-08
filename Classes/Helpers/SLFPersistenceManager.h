//
//  SLFPersistenceManager.h
//  Created by Gregory Combs on 7/26/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <Foundation/Foundation.h>

typedef void (^SLFPersistentActionsSaveBlock)(NSString *actionPath);

@protocol SLFPerstentActionsProtocol <NSObject>
@required
@property (nonatomic,readonly) NSString *actionPath;
+ (NSString *)actionPathForObject:(id)object;
@property (nonatomic,copy) SLFPersistentActionsSaveBlock onSavePersistentActionPath;
@end

@interface SLFPersistenceManager : NSObject
@property (nonatomic, copy) NSString *savedActionPath;

// Common methods for persistence manager
+ (id)sharedPersistence;
- (void)loadPersistence:(NSNotification *)notification;
- (void)savePersistence;
- (void)resetPersistence;
- (NSDictionary *)exportSettings;
- (void)importSettings:(NSDictionary *)settings;
@end

@class SLFState;
@class SLFBill;

NSString* SLFCurrentActionPath(void);
void SLFSaveCurrentActionPath(NSString *path);

NSInteger SLFSelectedScopeIndexForKey(NSString *viewControllerKey);
void SLFSaveSelectedScopeIndexForKey(NSInteger index, NSString *viewControllerKey);

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

extern NSString * const SLFWatchedBillsDidChangeNotification;
NSDictionary* SLFWatchedBillsCatalog(void);
BOOL SLFBillIsWatchedWithID(NSString *watchID);
BOOL SLFBillIsWatched(SLFBill *bill);
void SLFRemoveWatchedBillWithWatchID(NSString *watchID);
void SLFSaveBillWatchedStatus(SLFBill *bill, BOOL isWatched);
void SLFTouchBillWatchedStatus(SLFBill *bill);

extern NSString * const SLFSelectedCalendarDidChangeNotification;
NSString* SLFSelectedCalendar(void);
void SLFSaveSelectedCalendar(NSString *calenderID);
