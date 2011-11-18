#import "SLFState.h"
#import "SLFSortDescriptor.h"
#import <RestKit/Network/NSObject+URLEncoding.h>

@implementation RKManagedObjectMapping(SLFState)
- (void)connectStateToKeyPath:(NSString *)keyPath withStateMapping:(RKManagedObjectMapping *)stateMapping {
    [self hasOne:keyPath withMapping:stateMapping];
    [self connectRelationship:keyPath withObjectForPrimaryKeyAttribute:@"stateID"];
}
@end

@implementation SLFState

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class]];
    mapping.primaryKeyAttribute = @"stateID";
    [mapping mapKeyPath:@"lower_chamber_name" toAttribute:@"lowerChamberName"];
    [mapping mapKeyPath:@"lower_chamber_title" toAttribute:@"lowerChamberTitle"];
    [mapping mapKeyPath:@"lower_chamber_term" toAttribute:@"lowerChamberTerm"];
    [mapping mapKeyPath:@"upper_chamber_name" toAttribute:@"upperChamberName"];
    [mapping mapKeyPath:@"upper_chamber_title" toAttribute:@"upperChamberTitle"];
    [mapping mapKeyPath:@"upper_chamber_term" toAttribute:@"upperChamberTerm"];
    [mapping mapKeyPath:@"session_details" toAttribute:@"sessionDetails"];
    [mapping mapKeyPath:@"legislature_name" toAttribute:@"legislatureName"];
    [mapping mapKeyPath:@"feature_flags" toAttribute:@"featureFlags"];
    [mapping mapKeyPath:@"latest_update" toAttribute:@"dateUpdated"];
    [mapping mapKeyPath:@"abbreviation" toAttribute:@"stateID"];
    [mapping mapAttributes:@"name", @"terms", @"level", nil];
    return mapping;
}

+ (NSArray *)sortDescriptors {
    NSStringCompareOptions options = NSNumericSearch | NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    NSSortDescriptor *nameDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"name" ascending:YES options:options];
    return [NSArray arrayWithObjects:nameDesc, nil];
}

- (NSString *)stateInitial {
	NSString * initial = [self.stateID substringToIndex:1];
	return initial;
}

- (UIImage *)stateFlag {
    NSString *iconPath = [NSString stringWithFormat:@"StateFlags.bundle/%@", self.stateID];
    return [UIImage imageNamed:iconPath];
}

- (NSString *)newsAddress {
    return [NSString stringWithFormat:@"http://stateline.org/live/states/%@", [self.name URLEncodedString]];
}

- (BOOL)isFeatureEnabled:(NSString *)feature {
    if ( feature && [feature length] && 
        (self.featureFlags && [self.featureFlags containsObject:feature]) ) {
        return YES;
    }
    return NO;
}

- (NSArray *)sessions {
    NSMutableArray *sessions = [NSMutableArray array];
    for (NSDictionary *term in self.terms) {
        for (NSString *session in [term objectForKey:@"sessions"]) {
            if (!IsEmpty(session))
                [sessions addObject:session];
        }
    }
    return sessions;
}

- (NSString *)latestSession {
    return [self.sessions lastObject];
}

- (NSString *)displayNameForSession:(NSString *)aSession {
    if ( [aSession length] == 0  || !self.sessionDetails )
        return aSession;
    
    NSString *value = aSession;
    NSDictionary * sessionDetail = [self.sessionDetails objectForKey:aSession];
    if (sessionDetail) {
        NSString * displayName = [sessionDetail objectForKey:@"display_name"];
        if (!IsEmpty(displayName))
            value = displayName;
    }
    return value;
}

- (NSDictionary *)sessionIndexesByDisplayName {
    if (IsEmpty(self.sessions))
        return nil;
    NSMutableDictionary *indexesByName = [NSMutableDictionary dictionary];
    NSInteger index = 0;
    for (NSString *aSession in self.sessions) {
        NSString *name = [self displayNameForSession:aSession];
        if (!IsEmpty(name))
            [indexesByName setObject:[NSNumber numberWithInt:index] forKey:name];            
        index++;
    }
    return indexesByName;
}

/*
- (NSInteger)sessionIndexForDisplayName:(NSString *)displayName {
    NSInteger index = [self.sessions count];
    if (!IsEmpty(displayName) && self.sessionIndexesByDisplayName) {
        NSNumber *value = [self.sessionIndexesByDisplayName objectForKey:displayName];
        if (value)
            index = [value integerValue];
    }
    return index;
}
*/

@end

NSString * const SLFSelectedStateDidChangeNotification = @"SLFSelectedStateDidChange";

#pragma mark - Selected State

NSString* SLFSelectedStateID(void) {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedState"];
}

SLFState* SLFSelectedState(void) {
    if (IsEmpty(SLFSelectedStateID()))
        return nil;
    return [SLFState findFirstByAttribute:@"stateID" withValue:SLFSelectedStateID()]; 
}

void SLFSaveSelectedState(SLFState *state) {
    NSCParameterAssert(state != NULL && state.stateID != NULL);
    SLFSaveSelectedStateID(state.stateID);
}

void SLFSaveSelectedStateID(NSString *stateID) {
    NSCParameterAssert(stateID != NULL);
    [[NSUserDefaults standardUserDefaults] setObject:stateID forKey:@"selectedState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:SLFSelectedStateDidChangeNotification object:stateID];
}

#pragma mark - Selected Session

NSString * const SLFSelectedSessioneDidChangeNotification = @"SLFSelectedSessioneDidChange";

NSDictionary* SLFSelectedSessionsByStateID(void) {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSessionsByStateID"];
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
    [[NSUserDefaults standardUserDefaults] setObject:selectedSessions forKey:@"selectedSessionsByStateID"];
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

