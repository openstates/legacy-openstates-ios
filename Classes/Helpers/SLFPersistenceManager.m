//
//  SLFPersistenceManager.m
//  Created by Gregory Combs on 7/26/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFPersistenceManager.h"
#import "SLFDataModels.h"
#import "MKiCloudSync.h"

NSString * const kPersistentSelectedStateKey = @"SelectedStateKey";
NSString * const kPersistentSelectedSessionKey = @"SelectedSessionByStateID";
NSString * const kPersistentScopeIndexKey = @"SelectedScopeIndexByKey";
NSString * const kPersistentActivityPathKey = @"SavedActivityPathKey";
NSString * const kPersistentWatchedBillsKey = @"WatchedBillsKey";

NSString * const SLFSelectedStateDidChangeNotification = @"SLFSelectedStateDidChange";
NSString * const SLFSelectedSessioneDidChangeNotification = @"SLFSelectedSessionDidChange";
NSString * const SLFWatchedBillsDidChangeNotification = @"SLFWatchedBillsDidChange";

NSDictionary* SLFSelectedScopeIndexByKeyCatalog(void);

@interface SLFPersistenceManager()
- (void)notifySettingsWereUpdated:(NSNotification *)notification;
@property (nonatomic,retain) NSString *currentStateID;
@property (nonatomic,retain) NSString *currentSession;
@end

@implementation SLFPersistenceManager
@synthesize savedActivityPath = _savedActivityPath;
@synthesize currentStateID = _currentStateID;
@synthesize currentSession = _currentSession;

+ (id)sharedPersistence
{
    static dispatch_once_t pred;
    static SLFPersistenceManager *foo = nil;
    dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
    return foo;
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPersistence:) name:kMKiCloudSyncNotification object:nil];
            //[MKiCloudSync start];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.savedActivityPath = nil;
    self.currentSession = nil;
    self.currentStateID = nil;
    [super dealloc];
}

- (void)savePersistence {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if (!IsEmpty(self.savedActivityPath))
        [settings setObject:self.savedActivityPath forKey:kPersistentActivityPathKey];
    [settings synchronize];        
}

- (void)loadPersistence:(NSNotification *)notification {
    self.savedActivityPath = [[NSUserDefaults standardUserDefaults] objectForKey:kPersistentActivityPathKey];
    if (notification) {
        [self notifySettingsWereUpdated:notification];
    }
}

- (void)resetPersistence {
    self.savedActivityPath = nil;
    self.currentSession = nil;
    self.currentStateID = nil;
    [NSUserDefaults resetStandardUserDefaults];
}

- (void)notifySettingsWereUpdated:(NSNotification *)notification {
    NSString *stateID = SLFSelectedStateID();
    if (stateID && ![stateID isEqualToString:self.currentStateID]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SLFSelectedStateDidChangeNotification object:stateID];
        self.currentStateID = stateID;
    }
    SLFState *state = SLFSelectedState();
    NSString* session = SLFSelectedSessionForState(state);
    if (session && ![session isEqualToString:self.currentSession]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SLFSelectedSessioneDidChangeNotification object:session];
        self.currentSession = session;
    }
}

#pragma mark - Application Activity/Resource Path
NSString* SLFCurrentActivityPath(void) {
    return [[SLFPersistenceManager sharedPersistence] savedActivityPath];
}

void SLFSaveCurrentActivityPath(NSString *path) {
    NSCParameterAssert(path != NULL);
    [[SLFPersistenceManager sharedPersistence] setSavedActivityPath:path];
}

#pragma mark - Selected Search Bar Scope

NSDictionary* SLFSelectedScopeIndexByKeyCatalog(void) {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kPersistentScopeIndexKey];
}

NSInteger SLFSelectedScopeIndexForKey(NSString *viewControllerKey) {
    NSDictionary *selectedScopeIndexByKey = SLFSelectedScopeIndexByKeyCatalog();
    if (!viewControllerKey || IsEmpty(selectedScopeIndexByKey))
        return 0;
    NSNumber *selectedIndex = [selectedScopeIndexByKey objectForKey:viewControllerKey];
    if (selectedIndex)
        return [selectedIndex integerValue];
    return 0;
}

void SLFSaveSelectedScopeIndexForKey(NSInteger index, NSString *viewControllerKey) {
    NSCParameterAssert(viewControllerKey != NULL);
    NSMutableDictionary *selectedScopes = [NSMutableDictionary dictionaryWithDictionary:SLFSelectedScopeIndexByKeyCatalog()];
    NSNumber *newIndex = [NSNumber numberWithInteger:index];
    [selectedScopes setObject:newIndex forKey:viewControllerKey];
    [[NSUserDefaults standardUserDefaults] setObject:selectedScopes forKey:kPersistentScopeIndexKey];
    //[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Selected State

SLFState* SLFSelectedState(void) {
    if (IsEmpty(SLFSelectedStateID()))
        return nil;
    return [SLFState findFirstByAttribute:@"stateID" withValue:SLFSelectedStateID()]; 
}

void SLFSaveSelectedState(SLFState *state) {
    NSCParameterAssert(state != NULL && state.stateID != NULL);
    SLFSaveSelectedStateID(state.stateID);
}

NSString* SLFSelectedStateID(void) {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kPersistentSelectedStateKey];
}

void SLFSaveSelectedStateID(NSString *stateID) {
    NSCParameterAssert(stateID != NULL);
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:stateID forKey:kPersistentSelectedStateKey];
    [settings synchronize];
    [[SLFPersistenceManager sharedPersistence] setCurrentStateID:stateID];
    [[NSNotificationCenter defaultCenter] postNotificationName:SLFSelectedStateDidChangeNotification object:stateID];
}

#pragma mark - Selected Session

NSDictionary* SLFSelectedSessionsByStateID(void) {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kPersistentSelectedSessionKey];
}

NSString* SLFSelectedSessionForState(SLFState *state) {
    NSDictionary *selectedSessionsByStateID = SLFSelectedSessionsByStateID();
    if (!state || IsEmpty(selectedSessionsByStateID))
        return nil;
    return [selectedSessionsByStateID objectForKey:state.stateID];
}

NSString* SLFSelectedSession(void) {
    return SLFSelectedSessionForState(SLFSelectedState());
}

void SLFSaveSelectedSessionForState(NSString *session, SLFState *state) {
    NSCParameterAssert(state != NULL && state.stateID != NULL);
    NSMutableDictionary *selectedSessions = [NSMutableDictionary dictionaryWithDictionary:SLFSelectedSessionsByStateID()];
    NSString *oldSelectedSession = SLFSelectedSessionForState(state);
    if (IsEmpty(session) && !IsEmpty(oldSelectedSession))
        [selectedSessions removeObjectForKey:state.stateID];
    else
        [selectedSessions setObject:session forKey:state.stateID];
    RKLogDebug(@"Selected Session has changed for %@: %@", state.stateID, session);
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:selectedSessions forKey:kPersistentSelectedSessionKey];
    [settings synchronize];
    [[SLFPersistenceManager sharedPersistence] setCurrentSession:session];
    [[NSNotificationCenter defaultCenter] postNotificationName:SLFSelectedSessioneDidChangeNotification object:session];
}

void SLFSaveSelectedSession(NSString *session) {
    SLFState *state = SLFSelectedState();
    if (!state)
        return;
    SLFSaveSelectedSessionForState(session, state);
}

NSString* FindOrCreateSelectedSessionForState(SLFState *state) {
    NSString *selected = SLFSelectedSessionForState(state);
    if (!state || !IsEmpty(selected))
        return selected;
    selected = state.latestSession;
    SLFSaveSelectedSessionForState(selected, state);
    return selected;
}

#pragma mark - Bill Watch

NSDictionary* SLFWatchedBillsCatalog(void) {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kPersistentWatchedBillsKey];
}

BOOL SLFBillIsWatched(SLFBill *bill) {
    NSDictionary *watchedBills = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kPersistentWatchedBillsKey];
    if (!bill || IsEmpty(watchedBills))
        return NO;
    return [[watchedBills allKeys] containsObject:bill.watchID];
}

void SLFSaveBillWatchedStatus(SLFBill *bill, BOOL isWatched) {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSDictionary *watchedBills = [settings dictionaryForKey:kPersistentWatchedBillsKey];
    if (!bill || IsEmpty(bill.watchID))
        return;
    NSMutableDictionary *watchedBillsToWrite = [NSMutableDictionary dictionaryWithDictionary:watchedBills];
    if (isWatched)
        [watchedBillsToWrite setObject:bill.dateUpdated forKey:bill.watchID];
    else
        [watchedBillsToWrite removeObjectForKey:bill.watchID];
    [settings setObject:watchedBillsToWrite forKey:kPersistentWatchedBillsKey];
    [settings synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:SLFWatchedBillsDidChangeNotification object:bill];
}
@end
