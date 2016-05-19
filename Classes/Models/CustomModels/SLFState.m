#import "SLFState.h"
#import "SLFSortDescriptor.h"
#import "GenericAsset.h"
#import <SLFRestKit/NSObject+URLEncoding.h>
#import "SLFChamber.h"
#import "SLFPersistenceManager.h"
#import "SLFRestKitManager.h"
#import <SLFRestKit/RestKit.h>
#import <SLFRestKit/CoreData.h>

@implementation RKManagedObjectMapping(SLFState)

- (void)connectStateToKeyPath:(NSString *)keyPath withStateMapping:(RKManagedObjectMapping *)stateMapping
{
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

- (NSString *)title {
    return self.name;
}

- (NSString *)subtitle {
    return [NSString stringWithFormat:@"(%@)", self.stateIDForDisplay];
}

- (NSString *)stateIDForDisplay {
    return [self.stateID uppercaseString];
}

- (NSString *)newsAddress {
    if ([self.stateID isEqualToString:@"dc"]) // DC doesn't have a stateline page
        return @"http://dccouncil.washington.dc.us/news";
    if ([self.stateID isEqualToString:@"pr"]) // Nor does Puerto Rico
        return @"http://www.pr.gov";
    return [NSString stringWithFormat:@"http://stateline.org/live/states/%@", [self.name URLEncodedString]];
}

- (NSString *)eventsFeedAddress {
    NSString *baseURL = [kOPENSTATES_BASE_URL absoluteString];
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

- (NSArray *)sessions
{
    NSMutableArray *sessions = [NSMutableArray array];
    for (NSDictionary *term in self.terms)
    {
        for (NSString *session in SLFTypeArrayOrNil(term[@"sessions"]))
        {
            if (SLFTypeNonEmptyStringOrNil(session))
                [sessions addObject:session];
        }
    }
    return sessions;
}

- (NSString *)latestSession {
    return [self.sessions lastObject];
}

- (NSString *)displayNameForSession:(NSString *)aSession
{
    aSession = SLFTypeNonEmptyStringOrNil(aSession);
    if (!aSession || !self.sessionDetails)
        return nil;
    
    NSDictionary * sessionDetail = SLFTypeDictionaryOrNil(self.sessionDetails[aSession]);
    if (!sessionDetail)
        return aSession;

    NSString * displayName = SLFTypeNonEmptyStringOrNil(sessionDetail[@"display_name"]);
    if (!displayName)
        return aSession;

    return displayName;
}

- (NSDictionary *)sessionIndexesByDisplayName
{
    if (!self.sessions.count)
        return nil;
    NSMutableDictionary *indexesByName = [NSMutableDictionary dictionary];
    UInt32 index = 0;
    for (NSString *aSession in self.sessions)
    {
        NSString *name = [self displayNameForSession:aSession];
        if (name)
            indexesByName[name] = @(index);
        index++;
    }
    return indexesByName;
}

- (NSArray *)sessionDisplayNames
{
    NSDictionary *sessionIndexesByName = self.sessionIndexesByDisplayName;
    if (!sessionIndexesByName.count)
        return nil;
    return [sessionIndexesByName keysSortedByValueUsingSelector:@selector(compare:)];
}


- (NSInteger)sessionIndexForDisplayName:(NSString *)displayName
{
    displayName = SLFTypeNonEmptyStringOrNil(displayName);
    NSInteger index = 0;
    NSDictionary *sessionIndexesByDisplayName = self.sessionIndexesByDisplayName;
    if (displayName)
    {
        NSNumber *value = sessionIndexesByDisplayName[displayName];
        if (!SLFTypeIsNull(value))
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

- (BOOL)isUnicameral {
    if ([self.stateID isEqualToString:@"ne"] || [self.stateID isEqualToString:@"dc"])
        return YES;
    return NO;
}

- (NSArray *)sortedCapitolMaps {
    if (!SLFTypeNonEmptySetOrNil(self.capitolMaps))
        return nil;
    return [self.capitolMaps sortedArrayUsingDescriptors:[GenericAsset sortDescriptors]];
}

+ (NSString *)resourcePathForStateID:(NSString *)stateID {
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY,@"apikey", [stateID lowercaseString], @"stateID", nil];
    return RKMakePathWithObject(@"/metadata/:stateID?apikey=:apikey", queryParams);
}

+ (NSString *)resourcePathForAll {
    return [NSString stringWithFormat:@"/metadata?apikey=%@&fields=name,abbreviation,upper_chamber_name,lower_chamber_name,upper_chamber_title,lower_chamber_title,feature_flags", SUNLIGHT_APIKEY];
}
@end
