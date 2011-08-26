#import "SLFLegislator.h"
#import "SLFDistrictMap.h"
#import "SLFState.h"
#import "UtilityMethods.h"

@implementation SLFLegislator

- (void)setStateID:(NSString *)newID {
    [self willChangeValueForKey:@"stateID"];
    [self setPrimitiveStateID:newID];
    [self didChangeValueForKey:@"stateID"];
    
    if (!newID)
        return;
    
    SLFState *tempState = [SLFState findFirstByAttribute:@"abbreviation" withValue:newID];
    self.state = tempState;
}

- (void)setParty:(NSString *)newParty {
    
    if (newParty && [newParty hasSubstring:@"democrat" caseInsensitive:YES])
        newParty = @"Democrat";
    
    [self willChangeValueForKey:@"party"];
    [self setPrimitiveParty:newParty];
    [self didChangeValueForKey:@"party"];    
}

- (NSArray *)sortedPositions {
	
	/* hacky way to get this without having a real set of "positions" */
    //NSArray * results = [SLFCommitteePosition findByAttribute:@"legID" withValue:self.legID andOrderBy:@"committeeName" ascending:YES];	
	
    // alternatively, sort by "role"
	NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"committeeName" ascending:YES];
    
	NSArray *results = [[self.positions allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
	
	return results;
	
}

/*- (NSString *)districtMapResourcePath {
    return [NSString stringWithFormat:@"/districts/%@/%@/%@/", self.stateID, self.chamber, self.district];
}*/

- (SLFDistrictMap *)hydratedDistrictMap {
    SLFDistrictMap *tempMap = self.districtMap;
    
    if (tempMap)
        return tempMap;
    
    NSString *slug = self.districtMapSlug;
    if (!slug || [slug length] == 0)
        return nil;
    
    
    tempMap = [SLFDistrictMap findFirstByAttribute:@"boundaryID" withValue:slug];
    if (!tempMap)
        return nil;
    
    self.districtMap = tempMap;
    
    return tempMap;
}



- (NSString *)districtMapSlug {
    if (self.districtMap)
        return self.districtMap.boundaryID;
    
    NSString *districtMapID = nil;
    if ([self.chamber isEqualToString:@"upper"]) {
        districtMapID = [NSString stringWithFormat:@"sldu-%@-state-%@-district-%@", 
                         self.stateID, 
                         [self.state.upperChamberName lowercaseString],
                         self.district];
    }
    else {
        NSString *chamberName = [self.state.lowerChamberName lowercaseString];
        if ([chamberName hasPrefix:@"house"])
            chamberName = @"state-house";
        
        districtMapID = [NSString stringWithFormat:@"sldl-%@-%@-district-%@", 
                         self.stateID, 
                         chamberName,
                         self.district];
    }
    return districtMapID;
}



/////////////////////////////

- (NSComparisonResult)compareMembersByName:(SLFLegislator *)p
{	
	return [[self fullNameLastFirst] compare: [p fullNameLastFirst]];	
}

- (NSString *) lastnameInitial {
	NSString * initial = [self.lastName substringToIndex:1];
	return initial;
}

- (NSString *)partyShortName {
    return [self.party substringToIndex:1];
}

- (NSString *)chamberShortName {
    return abbreviateString(chamberStringFromOpenStates(self.chamber));
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
              [self chamberShortName], self.district];
	return string;
}

- (NSString *)title {
    NSString *aTitle = self.state.lowerChamberTitle;
    if ([self.chamber isEqualToString:@"upper"])
        aTitle = self.state.upperChamberTitle;
    return aTitle;
}

- (NSString *)term {
    NSNumber *years = self.state.lowerChamberTerm;
    if ([self.chamber isEqualToString:@"upper"])
        years = self.state.upperChamberTerm;
    return [NSString stringWithFormat:@"Term: %@ Years", years];
}

@end
