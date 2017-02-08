//
//  SLFPersistenceManager.m
//  Created by Gregory Combs on 7/26/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFPersistenceManager.h"
#import "SLFDataModels.h"
#import "SLFiCloudSync.h"
#import "SLFEventsManager.h"

NSString * const kPersistentSelectedStateKey = @"SelectedStateKey";
NSString * const kPersistentSelectedSessionKey = @"SelectedSessionByStateID";
NSString * const kPersistentScopeIndexKey = @"SelectedScopeIndexByKey";
NSString * const kPersistentActionPathKey = @"SavedActionPathKey";
NSString * const kPersistentWatchedBillsKey = @"WatchedBillsKey";
NSString * const kPersistentCalendarKey = @"SelectedCalendarKey";

NSString * const SLFSelectedStateDidChangeNotification = @"SLFSelectedStateDidChange";
NSString * const SLFSelectedSessioneDidChangeNotification = @"SLFSelectedSessionDidChange";
NSString * const SLFWatchedBillsDidChangeNotification = @"SLFWatchedBillsDidChange";
NSString * const SLFSelectedCalendarDidChangeNotification = @"SLFSelectedCalendarDidChange";

NSDictionary* SLFSelectedScopeIndexByKeyCatalog(void);

@interface SLFPersistenceManager()
- (void)notifySettingsWereUpdated:(NSNotification *)notification;
@property (nonatomic,strong) NSString *currentStateID;
@property (nonatomic,strong) NSString *currentSession;
@end

@implementation SLFPersistenceManager
@synthesize savedActionPath = _savedActionPath;
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
        [SLFiCloudSync start];
        [self loadPersistence:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)savePersistence {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if (SLFTypeNonEmptyStringOrNil(self.savedActionPath))
        [settings setObject:self.savedActionPath forKey:kPersistentActionPathKey];
    [settings synchronize];        
}

- (void)loadPersistence:(NSNotification *)notification {
    self.savedActionPath = [[NSUserDefaults standardUserDefaults] objectForKey:kPersistentActionPathKey];
    if (notification) {
        [self notifySettingsWereUpdated:notification];
    }
}

- (void)resetPersistence {
    self.savedActionPath = nil;
    self.currentSession = nil;
    self.currentStateID = nil;
    [NSUserDefaults resetStandardUserDefaults];
}

- (NSDictionary *)exportSettings
{
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];

    NSString *path = SLFTypeNonEmptyStringOrNil(SLFCurrentActionPath());
    if (path)
        settings[kPersistentActionPathKey] = path;

    NSDictionary *catalog = SLFSelectedScopeIndexByKeyCatalog();
    if (catalog)
        settings[kPersistentScopeIndexKey] = catalog;

    NSString *stateId = SLFTypeNonEmptyStringOrNil(SLFSelectedStateID());
    if (stateId)
        settings[kPersistentSelectedStateKey] = stateId;

    NSDictionary *sessions = SLFTypeDictionaryOrNil(SLFSelectedSessionsByStateID());
    if (sessions.count)
        settings[kPersistentSelectedSessionKey] = sessions;

    catalog = SLFWatchedBillsCatalog();
    if (catalog.count)
        settings[kPersistentWatchedBillsKey] = catalog;

    NSString *calendar = SLFSelectedCalendar();
    if (calendar)
        settings[kPersistentCalendarKey] = calendar;

    return settings;
}

- (void)importSettings:(NSDictionary *)settings
{
    if (!SLFTypeDictionaryOrNil(settings))
        return;
    if ([[self exportSettings] isEqualToDictionary:settings])
        return; // no changes
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *actionPath = [settings valueForKey:kPersistentActionPathKey];
    if (SLFTypeNonEmptyStringOrNil(actionPath))
        [defaults setObject:actionPath forKey:kPersistentActionPathKey];
    NSDictionary *selectedScopes = SLFTypeDictionaryOrNil([settings valueForKey:kPersistentScopeIndexKey]);
    if (selectedScopes.count)
        [defaults setObject:selectedScopes forKey:kPersistentScopeIndexKey];
    NSString *stateID = SLFTypeNonEmptyStringOrNil([settings valueForKey:kPersistentSelectedStateKey]);
    if (stateID)
        [defaults setObject:stateID forKey:kPersistentSelectedStateKey];
    NSDictionary *selectedSessions = SLFTypeDictionaryOrNil([settings valueForKey:kPersistentSelectedSessionKey]);
    if (selectedSessions)
        [defaults setObject:selectedSessions forKey:kPersistentSelectedSessionKey];
    NSDictionary *watchedBills = SLFTypeDictionaryOrNil([settings valueForKey:kPersistentWatchedBillsKey]);
    if (watchedBills)
        [defaults setObject:watchedBills forKey:kPersistentWatchedBillsKey];
    NSString *calendarID = SLFTypeNonEmptyStringOrNil([settings valueForKey:kPersistentCalendarKey]);
    if (calendarID)
        [defaults setObject:calendarID forKey:kPersistentCalendarKey];
    [[SLFEventsManager sharedManager] loadEventCalendarFromPersistence];
    [self loadPersistence:nil];
}


- (void)notifySettingsWereUpdated:(NSNotification *)notification {
    NSString *stateID = SLFSelectedStateID();
    if (stateID && ![stateID isEqualToString:self.currentStateID]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SLFSelectedStateDidChangeNotification object:stateID];
        self.currentStateID = stateID;
    }
    SLFState *state = SLFSelectedState();
    if (!state)
        return;
    NSString* session = SLFSelectedSessionForState(state);
    if (session && ![session isEqualToString:self.currentSession]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SLFSelectedSessioneDidChangeNotification object:session];
        self.currentSession = session;
    }
}

#pragma mark - Calendar / Events

NSString* SLFSelectedCalendar(void) {
    return SLFTypeNonEmptyStringOrNil([[NSUserDefaults standardUserDefaults] objectForKey:kPersistentCalendarKey]);
}

void SLFSaveSelectedCalendar(NSString *calenderID) {
    if (!SLFTypeNonEmptyStringOrNil(calenderID))
        return;
    [[NSUserDefaults standardUserDefaults] setObject:calenderID forKey:kPersistentCalendarKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:SLFSelectedCalendarDidChangeNotification object:[SLFPersistenceManager sharedPersistence] userInfo:[NSDictionary dictionaryWithObject:calenderID forKey:@"calendarID"]];
}

#pragma mark - Application Activity/Resource Path

NSString* SLFCurrentActionPath(void) {
    return [[SLFPersistenceManager sharedPersistence] savedActionPath];
}

void SLFSaveCurrentActionPath(NSString *path) {
    if (!SLFTypeNonEmptyStringOrNil(path))
        return;
    NSLog(@"---Persisting User Action: %@", path);
    [[SLFAnalytics sharedAnalytics] tagEvent:path attributes:nil];
    [[SLFPersistenceManager sharedPersistence] setSavedActionPath:path];
}

#pragma mark - Selected Search Bar Scope

NSDictionary* SLFSelectedScopeIndexByKeyCatalog(void) {
    return SLFTypeDictionaryOrNil([[NSUserDefaults standardUserDefaults] objectForKey:kPersistentScopeIndexKey]);
}

NSInteger SLFSelectedScopeIndexForKey(NSString *viewControllerKey) {
    NSDictionary *selectedScopeIndexByKey = SLFSelectedScopeIndexByKeyCatalog();
    if (!viewControllerKey || !selectedScopeIndexByKey)
        return 0;
    NSNumber *selectedIndex = selectedScopeIndexByKey[viewControllerKey];
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
    NSString *stateId = SLFSelectedStateID();
    if (!stateId)
        return nil;
    return [SLFState findFirstByAttribute:@"stateID" withValue:stateId];
}

void SLFSaveSelectedState(SLFState *state) {
    NSCParameterAssert(state != NULL && state.stateID != NULL);
    SLFSaveSelectedStateID(state.stateID);
}

NSString* SLFSelectedStateID(void) {
    return SLFTypeNonEmptyStringOrNil([[NSUserDefaults standardUserDefaults] objectForKey:kPersistentSelectedStateKey]);
}

void SLFSaveSelectedStateID(NSString *stateID) {
    NSCParameterAssert(stateID != NULL);
    stateID = SLFTypeNonEmptyStringOrNil(stateID);
    if (!stateID)
        return;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:stateID forKey:kPersistentSelectedStateKey];
    [settings synchronize];
    [[SLFPersistenceManager sharedPersistence] setCurrentStateID:stateID];
    [[NSNotificationCenter defaultCenter] postNotificationName:SLFSelectedStateDidChangeNotification object:stateID];
    NSLog(@"---Saving selected state ID: %@", stateID);
}

#pragma mark - Selected Session

NSDictionary* SLFSelectedSessionsByStateID(void) {
    return SLFTypeDictionaryOrNil([[NSUserDefaults standardUserDefaults] objectForKey:kPersistentSelectedSessionKey]);
}

NSString* SLFSelectedSessionForState(SLFState *state) {
    NSDictionary *selectedSessionsByStateID = SLFSelectedSessionsByStateID();
    if (!state || !state.stateID || !selectedSessionsByStateID)
        return nil;
    return SLFTypeNonEmptyStringOrNil(selectedSessionsByStateID[state.stateID]);
}

NSString* SLFSelectedSession(void) {
    return SLFSelectedSessionForState(SLFSelectedState());
}

void SLFSaveSelectedSessionForState(NSString *session, SLFState *state) {
    session = SLFTypeNonEmptyStringOrNil(session);
    NSCParameterAssert(state != NULL && state.stateID != NULL);

    NSDictionary *sessionsByState = SLFSelectedSessionsByStateID();
    if (!sessionsByState)
        sessionsByState = @{};
    NSMutableDictionary *selectedSessions = [sessionsByState mutableCopy];
    NSString *oldSelectedSession = SLFSelectedSessionForState(state);
    if (!session && oldSelectedSession)
        [selectedSessions removeObjectForKey:state.stateID];
    else if (session)
        selectedSessions[state.stateID] = session;
    NSLog(@"Selected Session has changed for %@: %@", state.stateID, session);
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
    if (!state || selected)
        return selected;
    selected = SLFTypeNonEmptyStringOrNil(state.latestSession);
    if (selected)
        SLFSaveSelectedSessionForState(selected, state);
    return selected;
}

#pragma mark - Bill Watch

NSDictionary* SLFWatchedBillsCatalog(void) {
    return SLFTypeDictionaryOrNil([[NSUserDefaults standardUserDefaults] dictionaryForKey:kPersistentWatchedBillsKey]);
}

BOOL SLFBillIsWatchedWithID(NSString *watchID) {
    if (!SLFTypeNonEmptyStringOrNil(watchID))
        return NO;
    NSDictionary *watchedBills = SLFWatchedBillsCatalog();
    return (watchedBills[watchID] != NULL);
}

BOOL SLFBillIsWatched(SLFBill *bill) {
    if (!bill)
        return NO;
    return SLFBillIsWatchedWithID(bill.watchID);
}

void SLFRemoveWatchedBillWithWatchID(NSString *watchID) {
    NSDictionary *watchedBills = SLFWatchedBillsCatalog();
    if (!SLFTypeNonEmptyStringOrNil(watchID))
        return;
    NSMutableDictionary *watchedBillsToWrite = [NSMutableDictionary dictionaryWithDictionary:watchedBills];
    [watchedBillsToWrite removeObjectForKey:watchID];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:watchedBillsToWrite forKey:kPersistentWatchedBillsKey];
    [settings synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:SLFWatchedBillsDidChangeNotification object:nil];
}

void SLFSaveBillWatchedStatus(SLFBill *bill, BOOL isWatched) {
    NSDictionary *watchedBills = SLFWatchedBillsCatalog();
    if (!bill)
        return;
    NSString *watchId = SLFTypeNonEmptyStringOrNil(bill.watchID);
    if (!watchId)
        return;

    NSMutableDictionary *watchedBillsToWrite = [NSMutableDictionary dictionaryWithDictionary:watchedBills];
    if (isWatched && bill.dateUpdated)
        watchedBillsToWrite[watchId] = bill.dateUpdated;
    else
        [watchedBillsToWrite removeObjectForKey:watchId];

    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:watchedBillsToWrite forKey:kPersistentWatchedBillsKey];
    [settings synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:SLFWatchedBillsDidChangeNotification object:bill];
}

void SLFTouchBillWatchedStatus(SLFBill *bill) {
    if (!bill)
        return;
    BOOL isWatched = SLFBillIsWatched(bill);
    SLFSaveBillWatchedStatus(bill, isWatched); // to reset the "last updated" date
}
@end
