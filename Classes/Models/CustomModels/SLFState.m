#import "SLFState.h"
#import "SLFSortDescriptor.h"
#import "GenericAsset.h"
#import <RestKit/Network/NSObject+URLEncoding.h>
#import "SLFChamber.h"
#import "SLFPersistenceManager.h"
#import "SLFRestKitManager.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@implementation RKManagedObjectMapping(SLFState)
- (void)connectStateToKeyPath:(NSString *)keyPath withStateMapping:(RKManagedObjectMapping *)stateMapping {
    [self hasOne:keyPath withMapping:stateMapping];
    [self connectRelationship:keyPath withObjectForPrimaryKeyAttribute:@"stateID"];
}
@end

@implementation SLFState

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:[RKObjectManager sharedManager].objectStore];
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
    NSSortDescriptor *nameDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"name" ascending:YES];
    return [NSArray arrayWithObjects:nameDesc, nil];
}

- (NSString *)stateInitial {
    NSString * initial = [self.stateID substringToIndex:1];
    return initial;
}

- (NSString *)stateIDForDisplay {
    return [self.stateID uppercaseString];
}

- (UIImage *)stateFlag {
    NSString *iconPath = [NSString stringWithFormat:@"StateFlags.bundle/%@", self.stateID];
    return [UIImage imageNamed:iconPath];
}

+ (NSString *)resourcePathForStateID:(NSString *)stateID {
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY,@"apikey", [stateID lowercaseString], @"stateID", nil];
    return RKMakePathWithObject(@"/metadata/:stateID?apikey=:apikey", queryParams);
}

- (NSString *)newsAddress {
    return [NSString stringWithFormat:@"http://stateline.org/live/states/%@", [self.name URLEncodedString]];
}

- (NSString *)eventsFeedAddress {
    NSString *baseURL = [[[SLFRestKitManager sharedRestKit] openStatesClient] baseURL];
    if (!baseURL)
        baseURL = @"webcal://openstates.org/api/v1";
    else
        baseURL = [baseURL stringByReplacingOccurrencesOfString:@"http:" withString:@"webcal:"];
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY,@"apikey", self.stateID,@"state", nil];
    NSString *path = RKMakePathWithObject(@"/events/?state=:state&apikey=:apikey&format=ics", queryParams);
    return [baseURL stringByAppendingString:path];
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

- (NSArray *)sessionDisplayNames {
    NSDictionary *sessionIndexesByName = self.sessionIndexesByDisplayName;
    if (IsEmpty(sessionIndexesByName))
        return nil;
    return [sessionIndexesByName keysSortedByValueUsingSelector:@selector(compare:)];
}


- (NSInteger)sessionIndexForDisplayName:(NSString *)displayName {
    NSInteger index = 0;
    NSDictionary *sessionIndexesByDisplayName = self.sessionIndexesByDisplayName;
    if (!IsEmpty(displayName) && sessionIndexesByDisplayName) {
        NSNumber *value = [sessionIndexesByDisplayName objectForKey:displayName];
        if (value)
            index = [value integerValue];
    }
    return index;
}


- (NSArray *)chambers {
    NSMutableArray *chambers = [NSMutableArray arrayWithObject:[UpperChamber upperForState:self]];
    LowerChamber *lower = [LowerChamber lowerForState:self];
    if (lower)
        [chambers addObject:lower];
    return chambers;
}

- (NSArray *)sortedCapitolMaps {
    if (IsEmpty(self.capitolMaps))
        return nil;
    return [self.capitolMaps sortedArrayUsingDescriptors:[GenericAsset sortDescriptors]];
}

@end
