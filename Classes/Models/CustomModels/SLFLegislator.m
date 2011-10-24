#import "SLFLegislator.h"
#import "SLFDataModels.h"

@implementation SLFLegislator

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

- (NSArray *)pruneJunkFromRoles:(NSArray*)sortedRoles {
    CommitteeRole *junkRole = [sortedRoles objectAtIndex:0];
    if (!IsEmpty(junkRole.committeeName))
        return sortedRoles;
    NSMutableArray *prunedRoles = [NSMutableArray arrayWithArray:sortedRoles];
    [prunedRoles removeObject:junkRole];
    [junkRole deleteEntity];
    [[[RKObjectManager sharedManager] objectStore] save];
    return prunedRoles;
}

- (NSArray *)sortedRoles {
    if (IsEmpty(self.roles))
        return nil;
    NSArray *sortedRoles = [self.roles sortedArrayUsingDescriptors:[SLFCommittee sortDescriptors]];
    return [self pruneJunkFromRoles:sortedRoles];
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

- (NSComparisonResult)compareMembersByName:(SLFLegislator *)p
{	
	return [[self fullNameLastFirst] compare: [p fullNameLastFirst]];	
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
