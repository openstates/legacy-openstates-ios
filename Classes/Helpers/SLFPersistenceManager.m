//
//  SLFPersistenceManager.m
//  Created by Gregory Combs on 7/26/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

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
@property (nonatomic,retain) NSString *currentStateID;
@property (nonatomic,retain) NSString *currentSession;
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
    self.savedActionPath = nil;
    self.currentSession = nil;
    self.currentStateID = nil;
    [super dealloc];
}

- (void)savePersistence {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if (!IsEmpty(self.savedActionPath))
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

- (NSDictionary *)exportSettings {
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    if (!IsEmpty(SLFCurrentActionPath()))
        [settings setObject:SLFCurrentActionPath() forKey:kPersistentActionPathKey];
    if (!IsEmpty(SLFSelectedScopeIndexByKeyCatalog()))
        [settings setObject:SLFSelectedScopeIndexByKeyCatalog() forKey:kPersistentScopeIndexKey];
    if (!IsEmpty(SLFSelectedStateID()))
        [settings setObject:SLFSelectedStateID() forKey:kPersistentSelectedStateKey];
    if (!IsEmpty(SLFSelectedSessionsByStateID()))
        [settings setObject:SLFSelectedSessionsByStateID() forKey:kPersistentSelectedSessionKey];
    if (!IsEmpty(SLFWatchedBillsCatalog()))
        [settings setObject:SLFWatchedBillsCatalog() forKey:kPersistentWatchedBillsKey];
    if (!IsEmpty(SLFSelectedCalendar()))
        [settings setObject:SLFSelectedCalendar() forKey:kPersistentCalendarKey];
    return settings;
}

- (void)importSettings:(NSDictionary *)settings {
    if (IsEmpty(settings))
        return;
    if ([[self exportSettings] isEqualToDictionary:settings])
        return; // no changes
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *actionPath = [settings valueForKey:kPersistentActionPathKey];
    if (!IsEmpty(actionPath))
        [defaults setObject:actionPath forKey:kPersistentActionPathKey];
    NSDictionary *selectedScopes = [settings valueForKey:kPersistentScopeIndexKey];
    if (!IsEmpty(selectedScopes))
        [defaults setObject:selectedScopes forKey:kPersistentScopeIndexKey];
    NSString *stateID = [settings valueForKey:kPersistentSelectedStateKey];
    if (!IsEmpty(stateID))
        [defaults setObject:stateID forKey:kPersistentSelectedStateKey];
    NSDictionary *selectedSessions = [settings valueForKey:kPersistentSelectedSessionKey];
    if (!IsEmpty(selectedSessions))
        [defaults setObject:selectedSessions forKey:kPersistentSelectedSessionKey];
    NSDictionary *watchedBills = [settings valueForKey:kPersistentWatchedBillsKey];
    if (!IsEmpty(watchedBills))
        [defaults setObject:watchedBills forKey:kPersistentWatchedBillsKey];
    NSString *calendarID = [settings valueForKey:kPersistentCalendarKey];
    if (!IsEmpty(calendarID))
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
    NSString* session = SLFSelectedSessionForState(state);
    if (session && ![session isEqualToString:self.currentSession]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SLFSelectedSessioneDidChangeNotification object:session];
        self.currentSession = session;
    }
}

#pragma mark - Calendar / Events

NSString* SLFSelectedCalendar(void) {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kPersistentCalendarKey];
}

void SLFSaveSelectedCalendar(NSString *calenderID) {
    if (IsEmpty(calenderID))
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
    if (IsEmpty(path))
        return;
    RKLogDebug(@"---Persisting User Action: %@", path);
    [[SLFAnalytics sharedAnalytics] tagEvent:path attributes:nil];
    [[SLFPersistenceManager sharedPersistence] setSavedActionPath:path];
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
    RKLogDebug(@"---Saving selected state ID: %@", stateID);
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
    NSDictionary *watchedBills = SLFWatchedBillsCatalog();
    if (!bill || IsEmpty(watchedBills))
        return NO;
    return [[watchedBills allKeys] containsObject:bill.watchID];
}

void SLFSaveBillWatchedStatus(SLFBill *bill, BOOL isWatched) {
    NSDictionary *watchedBills = SLFWatchedBillsCatalog();
    if (!bill || IsEmpty(bill.watchID))
        return;
    NSMutableDictionary *watchedBillsToWrite = [NSMutableDictionary dictionaryWithDictionary:watchedBills];
    if (isWatched)
        [watchedBillsToWrite setObject:bill.dateUpdated forKey:bill.watchID];
    else
        [watchedBillsToWrite removeObjectForKey:bill.watchID];
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
