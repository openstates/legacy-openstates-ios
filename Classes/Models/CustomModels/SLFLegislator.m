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

- (void)setParty:(NSString *)newParty {
    if (newParty && [newParty hasPrefix:@"Democrat"])
        newParty = @"Democrat";
    [self willChangeValueForKey:@"party"];
    [self setPrimitiveParty:newParty];
    [self didChangeValueForKey:@"party"];    
}

- (NSArray *)sortedRoles {
    if (IsEmpty(self.roles))
        return nil;
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"committeeName" ascending:YES];    
    NSMutableArray * roles = [NSMutableArray arrayWithArray:[self.roles sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]]];
    CommitteeRole *dirtyObject = [roles objectAtIndex:0];
    if (IsEmpty(dirtyObject.committeeName)) {
        [roles removeObject:dirtyObject];
        [dirtyObject deleteEntity];
        [[[RKObjectManager sharedManager] objectStore] save];
    }
    return roles;
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

- (NSString *)demoLongName {
    return [NSString stringWithFormat:@"%@ (%@-%@)", self.fullName, [self.party substringToIndex:1], self.district];
}

- (NSString *)districtMapLabel {
    return [NSString stringWithFormat:@"%@ %@ District %@", self.state.name, self.chamberShortName, self.district];
}

- (NSComparisonResult)compareMembersByName:(SLFLegislator *)p
{	
	return [[self fullNameLastFirst] compare: [p fullNameLastFirst]];	
}

- (NSString *)lastnameInitial {
	NSString * initial = [self.lastName substringToIndex:1];
	return initial;
}

- (NSString *)partyShortName {
    return [self.party substringToIndex:1];
}

- (NSString *)chamberShortName {
    return self.chamberObj.shortName;
}

- (NSString *)districtPartyString {
	NSString *string = [NSString stringWithFormat: @"(%@-%@)", [self partyShortName], self.district];
	return string;
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

- (NSString *)shortNameForButtons {
	NSString *string;
	string = [NSString stringWithFormat:@"%@ (%@)", self.fullName, [self partyShortName]];
	return string;
}

- (NSString *)labelSubText {
	NSString *string;
	string = [NSString stringWithFormat: NSLocalizedStringFromTable(@"%@ - District %@", @"DataTableUI", @"The person and their district number"),
              self.chamberShortName, self.district];
	return string;
}

- (NSString *)title {
    return self.chamberObj.title;
}

- (NSString *)term {
    return [NSString stringWithFormat:@"Term: %@ Years", self.chamberObj.term];
}

@end
