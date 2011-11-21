#import "SLFLegislator.h"
#import "SLFDataModels.h"
#import "SLFSortDescriptor.h"

@interface SLFLegislator()
- (NSArray *)pruneJunkFromRoles:(NSArray*)sortedRoles;
@end

@implementation SLFLegislator

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class]];
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
    [mapping mapAttributes:@"suffixes", @"party", @"level", @"district", @"country", @"chamber", @"active",nil];    
    return mapping;
}

+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping {
    RKManagedObjectMapping *mapping = [[self class] mapping];
    [mapping connectStateToKeyPath:@"stateObj" withStateMapping:stateMapping];
    return mapping;
}

    // This is here because the JSON data has a keyPath "state" that conflicts with our core data relationship.
- (SLFState *)state {
    return self.stateObj;
}

- (SLFChamber *)chamberObj {
    return [SLFChamber chamberWithType:self.chamber forState:self.state];
}

- (SLFParty *)partyObj {
    return [SLFParty partyWithName:self.party];
}

- (void)setParty:(NSString *)newParty {
    if (newParty && [newParty hasPrefix:@"Democrat"])
        newParty = @"Democrat";
    [self willChangeValueForKey:@"party"];
    [self setPrimitiveParty:newParty];
    [self didChangeValueForKey:@"party"];    
}

+ (NSArray *)sortDescriptors {
    NSStringCompareOptions options = NSNumericSearch | NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    NSSortDescriptor *lastDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"lastName" ascending:YES options:options];
    NSSortDescriptor *firstDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"firstName" ascending:YES options:options];
    NSSortDescriptor *stateDesc = [NSSortDescriptor sortDescriptorWithKey:@"stateID" ascending:YES];
    return [NSArray arrayWithObjects:lastDesc, firstDesc, stateDesc, nil];
}

- (NSArray *)sortedRoles {
    if (IsEmpty(self.roles))
        return nil;
    NSArray *sortedRoles = [self.roles sortedArrayUsingDescriptors:[CommitteeRole sortDescriptors]];
    return [self pruneJunkFromRoles:sortedRoles];
}

- (NSArray *)pruneJunkFromRoles:(NSArray *)sortedRoles {
    NSMutableArray *prunedRoles = [NSMutableArray arrayWithArray:sortedRoles];
    NSMutableArray *junkRoles = [NSMutableArray array];
    for (CommitteeRole *role in sortedRoles) {
        if (!IsEmpty(role.name))
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
    
    NSString *boundaryCode = ([self.chamber isEqualToString:@"upper"]) ? @"sldu" : @"sldl";
    NSString *chamberName = [self.chamberShortName lowercaseString];
    if ([chamberName isEqualToString:@"senate"] || [chamberName isEqualToString:@"house"])
        chamberName = [NSString stringWithFormat:@"state-%@", chamberName];
    
    NSDictionary *boundaryIDComponents = [NSDictionary dictionaryWithObjectsAndKeys:
                                          boundaryCode, @"boundaryCode",
                                          self.stateID, @"stateID",
                                          chamberName, @"chamberName",
                                          self.district, @"districtID", nil];
    
    return RKMakePathWithObject(@":boundaryCode-:stateID-:chamberName-district-:districtID", boundaryIDComponents);    
}

/////////////////////////////

- (NSString *)formalName {
    return [NSString stringWithFormat:@"%@ %@", self.chamberObj.titleAbbreviation, self.fullName];
}

- (NSString *)demoLongName {
    return [NSString stringWithFormat:@"%@ (%@-%@)", self.fullName, self.partyObj.initial, self.district];
}

- (NSString *)districtMapLabel {
    return [NSString stringWithFormat:@"%@ %@ District %@", self.state.name, self.chamberShortName, self.district];
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

- (NSString *)labelSubText {
	return [NSString stringWithFormat:NSLocalizedString(@"%@ - District %@", @""), self.chamberShortName, self.district];
}

- (NSString *)title {
    return self.chamberObj.title;
}

- (NSString *)term {
    return [NSString stringWithFormat:@"%@ Years", self.chamberObj.term];
}

@end
