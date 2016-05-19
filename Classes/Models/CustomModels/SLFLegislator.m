#import "SLFLegislator.h"
#import "SLFDataModels.h"
#import "SLFSortDescriptor.h"
#import <SLFRestKit/RestKit.h>
#import <SLFRestKit/CoreData.h>
#import "MultiRowCalloutCell.h"

@interface SLFLegislator()
- (NSArray *)pruneJunkFromRoles:(NSArray*)sortedRoles;
@end

@implementation SLFLegislator

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:[RKObjectManager sharedManager].objectStore];
    mapping.primaryKeyAttribute = @"legID";
    [mapping mapKeyPath:@"leg_id" toAttribute:@"legID"];
    [mapping mapKeyPath:@"state" toAttribute:@"stateID"];
    [mapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [mapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [mapping mapKeyPath:@"first_name" toAttribute:@"firstName"];
    [mapping mapKeyPath:@"full_name" toAttribute:@"fullName"];
    [mapping mapKeyPath:@"last_name" toAttribute:@"lastName"];
    [mapping mapKeyPath:@"middle_name" toAttribute:@"middleName"];
    [mapping mapKeyPath:@"nimsp_candidate_id" toAttribute:@"nimspCandidateID"];
    [mapping mapKeyPath:@"nimsp_id" toAttribute:@"nimspID"];
    [mapping mapKeyPath:@"photo_url" toAttribute:@"photoURL"];
    [mapping mapKeyPath:@"transparencydata_id" toAttribute:@"transparencyID"];
    [mapping mapKeyPath:@"votesmart_id" toAttribute:@"votesmartID"];
    [mapping mapAttributes:@"email", @"url", @"suffixes", @"party", @"level", @"district", @"country", @"chamber", @"active",nil];    
    return mapping;
}

+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping {
    RKManagedObjectMapping *mapping = [[self class] mapping];
    [mapping connectStateToKeyPath:@"stateObj" withStateMapping:stateMapping];
    return mapping;
}

+ (NSArray*)searchableAttributes {
    return [NSArray arrayWithObjects:@"lastName", @"firstName", @"fullName", @"district", nil];
}

    // This is here because the JSON data has a keyPath "state" that conflicts with our core data relationship.
- (SLFState *)state {
    return self.stateObj;
}

- (SLFChamber *)chamberObj {
    return [SLFChamber chamberWithType:self.chamber forState:self.stateObj];
}

- (SLFParty *)partyObj {
    return [SLFParty partyWithName:self.party];
}

// Necessary to normalize as "Democrat" from "Democratic"
- (void)setParty:(NSString *)newParty {
    if (newParty && [newParty hasPrefix:@"Democrat"])
        newParty = @"Democrat";
    [self willChangeValueForKey:@"party"];
    [self setPrimitiveParty:newParty];
    [self didChangeValueForKey:@"party"];    
}

+ (NSArray *)sortDescriptors {
    NSSortDescriptor *lastDesc = [SLFSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    NSSortDescriptor *firstDesc = [SLFSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *stateDesc = [NSSortDescriptor sortDescriptorWithKey:@"stateID" ascending:YES];
    return [NSArray arrayWithObjects:lastDesc, firstDesc, stateDesc, nil];
}

- (NSArray *)sortedRoles {
    if (!SLFTypeNonEmptySetOrNil(self.roles))
        return nil;
    NSArray *sortedRoles = [self.roles sortedArrayUsingDescriptors:[CommitteeRole sortDescriptors]];
    return [self pruneJunkFromRoles:sortedRoles];
}

- (NSArray *)pruneJunkFromRoles:(NSArray *)sortedRoles {
    NSMutableArray *prunedRoles = [NSMutableArray arrayWithArray:sortedRoles];
    NSMutableArray *junkRoles = [NSMutableArray array];
    for (CommitteeRole *role in sortedRoles) {
        if (SLFTypeNonEmptyStringOrNil(role.name))
            continue;
        [junkRoles addObject:role];
    }
    [prunedRoles removeObjectsInArray:junkRoles];
    while ([junkRoles count]) {
        CommitteeRole *junkRole = [junkRoles objectAtIndex:0];
        [junkRoles removeObject:junkRole];
        [junkRole deleteEntity];
    }
    [[[RKObjectManager sharedManager] objectStore] save];
    return prunedRoles;
}

- (SLFDistrict *)hydratedDistrict {
    SLFDistrict *hydratedMap = self.districtMap;
    if (!hydratedMap) {
        hydratedMap = [SLFDistrict findFirstByAttribute:@"boundaryID" withValue:self.districtID];
        if (hydratedMap)
            self.districtMap = hydratedMap;
    }
    return hydratedMap;
}

- (NSString *)districtID {
    if (self.districtMap)
        return self.districtMap.boundaryID;
    return [SLFDistrict estimatedBoundaryIDForDistrict:self.district chamber:self.chamberObj];
}

/////////////////////////////

- (NSString *)formalName {
    return [NSString stringWithFormat:@"%@ %@", self.chamberObj.titleAbbreviation, self.fullName];
}

- (NSString *)demoLongName {
    return [NSString stringWithFormat:@"%@ %@", self.fullName, [self districtPartyString]];
}

- (NSString *)lastnameInitial {
	return [self.lastName substringToIndex:1];
}

- (NSString *)chamberShortName {
    return self.chamberObj.shortName;
}

- (NSString *)districtPartyString {
	return [NSString stringWithFormat: @"(%@-%@)", self.partyObj.initial, self.district];
}

- (NSString *)fullNameLastFirst {
	NSMutableString *name = [NSMutableString stringWithCapacity:128];
	if ([self.lastName length] > 0)
		[name appendFormat:@"%@, ", self.lastName];
	if ([self.firstName length] > 0)
		[name appendString:self.firstName];
	if ([self.middleName length] > 0)
		[name appendFormat:@" %@", self.middleName];
	if ([self.suffixes length] > 0)
		[name appendFormat:@" %@", self.suffixes];
	return name;
}

- (NSString *)subtitle {
    return [NSString stringWithFormat:@"%@ - %@ %@", self.partyObj.name, self.chamberShortName, self.district];
}

- (NSString *)districtMapLabel {
    return [NSString stringWithFormat:@"%@ %@", self.state.name, self.districtLongName];
}

- (NSString *)districtLongName {
	return [NSString stringWithFormat:NSLocalizedString(@"%@ - District %@", @""), self.chamberShortName, self.district];
}

- (NSString *)districtShortName {
	return [NSString stringWithFormat:@"%@ - %@", [self.stateID uppercaseString], self.district];
}

- (NSString *)title {
    return self.chamberObj.title;
}

- (NSString *)term {
    return [NSString stringWithFormat:NSLocalizedString(@"Term: %@ Years",@"Term and years a legislator serves"), self.chamberObj.term];
}

- (MultiRowCalloutCell *)calloutCell
{
    NSString *legId = SLFTypeStringOrNil(self.legID);
    if (!legId)
        legId = @"";
    return [MultiRowCalloutCell cellWithImage:self.partyObj.image title:self.title subtitle:self.fullName userData:@{@"legID":legId}];
}

- (NSString *)normalizedPhotoURL {
    if (SLFTypeNonEmptyStringOrNil(self.legID))
        return [NSString stringWithFormat:@"http://static.openstates.org/photos/small/%@.jpg", self.legID];
    return nil;
}

+ (NSString *)resourcePathForCoordinate:(CLLocationCoordinate2D)coordinate {
    if (!CLLocationCoordinate2DIsValid(coordinate))
        return nil;
    NSString *resourcePath = [NSString stringWithFormat:@"/legislators/geo/?lat=%lf&long=%lf&apikey=%@", coordinate.latitude, coordinate.longitude, SUNLIGHT_APIKEY];
    return resourcePath;    
}

+ (NSString *)resourcePathForAllWithStateID:(NSString *)stateID {
    /* download just enough attributes to populate the cell.  
       keep last_name in addition to full_name because it's used for the section index */
    return [NSString stringWithFormat:@"/legislators?state=%@&active=true&apikey=%@&fields=state,chamber,leg_id,title,district,party,full_name,last_name,active", stateID, SUNLIGHT_APIKEY];
}

@end
