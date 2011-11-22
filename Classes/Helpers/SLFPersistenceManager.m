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

NSString * const kPersistentSelectedStateKey = @"SelectedStateKey";
NSString * const kPersistentSelectedSessionKey = @"SelectedSessionByStateID";
NSString * const kPersistentScopeIndexKey = @"SelectedScopeIndexByKey";
NSString * const kPersistentActivityPathKey = @"SavedActivityPathKey";
NSString * const SLFSelectedStateDidChangeNotification = @"SLFSelectedStateDidChange";
NSString * const SLFSelectedSessioneDidChangeNotification = @"SLFSelectedSessionDidChange";

NSDictionary* SLFSelectedScopeIndexByKeyCatalog(void);

@interface SLFPersistenceManager()
@end

@implementation SLFPersistenceManager
@synthesize savedActivityPath = _savedActivityPath;

+ (id)sharedPersistence
{
    static dispatch_once_t pred;
    static SLFPersistenceManager *foo = nil;
    dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
    return foo;
}


- (void)dealloc {
    self.savedActivityPath = nil;
    [super dealloc];
}

- (void)savePersistence {
    if (!IsEmpty(self.savedActivityPath))
        [[NSUserDefaults standardUserDefaults] setObject:self.savedActivityPath forKey:kPersistentActivityPathKey];
    [[NSUserDefaults standardUserDefaults] synchronize];        
}

- (void)loadPersistence {
    self.savedActivityPath = [[NSUserDefaults standardUserDefaults] objectForKey:kPersistentActivityPathKey];
}

- (void)resetPersistence {
    self.savedActivityPath = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPersistentActivityPathKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPersistentScopeIndexKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Selected Search Bar Scope Index

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
    [[NSUserDefaults standardUserDefaults] setObject:stateID forKey:kPersistentSelectedStateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    [[NSUserDefaults standardUserDefaults] setObject:selectedSessions forKey:kPersistentSelectedSessionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:SLFSelectedSessioneDidChangeNotification object:state.stateID];
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



@end
