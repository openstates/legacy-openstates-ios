// 
//  LegislatorObj.m
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "LegislatorObj.h"

#import "CommitteePositionObj.h"
#import "UIImage+Resize.h"

@implementation LegislatorObj 

@dynamic dist3_city;
@dynamic suffix;
@dynamic legtype;
@dynamic email;
@dynamic dist3_fax;
@dynamic dist2_phone;
@dynamic bio_url;
@dynamic dist4_zip;
@dynamic cap_phone2;
@dynamic dist4_phone1;
@dynamic tenure;
@dynamic dist2_city;
@dynamic dist2_fax;
@dynamic cap_phone;
@dynamic cap_phone2_name;
@dynamic dist4_street;
@dynamic lastname;
@dynamic dist1_fax;
@dynamic legislatorID;
@dynamic middlename;
@dynamic notes;
@dynamic dist3_street;
@dynamic dist2_zip;
@dynamic district;
@dynamic dist3_zip;
@dynamic cap_fax;
@dynamic dist3_phone1;
@dynamic party_id;
@dynamic chamber_desk;
@dynamic dist4_city;
@dynamic twitter;
@dynamic dist1_zip;
@dynamic party_name;
@dynamic dist4_fax;
@dynamic partisan_index;
@dynamic dist1_phone;
@dynamic dist2_street;
@dynamic dist1_street;
@dynamic photo_name;
@dynamic nickname;
@dynamic legtype_name;
@dynamic dist1_city;
@dynamic cap_office;
@dynamic firstname;
@dynamic staff;

@dynamic lastnameInitial;
@dynamic searchName;

@dynamic committeePositions;

- (NSComparisonResult)compareMembersByName:(LegislatorObj *)p
{	
	return [[self fullNameLastFirst] compare: [p fullNameLastFirst]];	
}



- (NSString *) lastnameInitial {
	[self willAccessValueForKey:@"lastnameInitial"];
	NSString * initial = [[self lastname] substringToIndex:1];
	[self didAccessValueForKey:@"lastnameInitial"];
	return initial;
}

- (NSString *)partyShortName {
	NSString *shortName;
	if ([self.party_id integerValue] == DEMOCRAT) // Democrat
		shortName = @"D";
	else if ([self.party_id integerValue] == REPUBLICAN) // Republican
		shortName = @"R";
	else // don't know the party?
		shortName = @"I";
	return shortName;
}

- (NSString *)legTypeShortName {
	NSString *shortName;
	if ([self.legtype integerValue] == HOUSE) // Representative
		shortName = @"Rep.";
	else if ([self.legtype integerValue] == SENATE) // Senator
		shortName = @"Sen.";
	else // don't know the party?
		shortName = @"";
	return shortName;
}

- (NSString *)legProperName {
	NSMutableString *name = [NSMutableString stringWithCapacity:128];
	if ([self.firstname length] > 0)
		[name appendString:self.firstname];
	else if ([self.middlename length] > 0)
		[name appendString:self.firstname];
	
	[name appendFormat:@" %@", self.lastname];
	
	if ([self.suffix length] > 0)
		[name appendFormat:@", %@", self.suffix];

	return name;
}

- (NSString *)districtPartyString {
	NSString *string;
	string = [NSString stringWithFormat: @"(%@-%d)", self.partyShortName, [self.district integerValue]];
	return string;
}

- (NSString *)fullName {
	NSMutableString *name = [NSMutableString stringWithCapacity:128];

	if ([self.firstname length] > 0)
		[name appendString:self.firstname];
	if ([self.middlename length] > 0)
		[name appendFormat:@" %@", self.middlename];
	if ([self.nickname length] > 0)
		[name appendFormat:@" \"%@\"", self.nickname];
	if ([self.lastname length] > 0)
		[name appendFormat:@" %@", self.lastname];
	if ([self.suffix length] > 0)
		[name appendFormat:@", %@", self.suffix];

	return name;
}

- (NSString *)fullNameLastFirst {
	NSMutableString *name = [NSMutableString stringWithCapacity:128];
	
	if ([self.lastname length] > 0)
		[name appendFormat:@"%@, ", self.lastname];
	if ([self.firstname length] > 0)
		[name appendString:self.firstname];
	if ([self.middlename length] > 0)
		[name appendFormat:@" %@", self.middlename];
	if ([self.suffix length] > 0)
		[name appendFormat:@" %@", self.suffix];
	
	return name;
}


- (NSString *)shortNameForButtons {
	NSString *string;
	string = [NSString stringWithFormat:@"%@ (%@)", [self legProperName], [self partyShortName]];
	return string;
}

- (NSString *)labelSubText {
	NSString *string;
	string = [NSString stringWithFormat: @"%@ - District %d", 
			self.legtype_name, [self.district integerValue]];
	return string;
}

- (NSString *)website {
	NSString *url = nil;

	if ([self.legtype integerValue] == HOUSE)
		url = [NSString stringWithFormat:@"http://www.house.state.tx.us/members/dist%d/welcome.htm",
			   [self.district integerValue]];
	else if ([self.legtype integerValue] == SENATE)
		url = [NSString stringWithFormat:@"http://www.senate.state.tx.us/75r/Senate/members/dist%d/dist%d.htm",
			   [self.district integerValue], [self.district integerValue]];

	return url;
}


- (NSString*)searchName {
	NSString * tempString;
	[self willAccessValueForKey:@"searchName"];
	tempString = [NSString stringWithFormat: @"%@ %@ %@", [self legTypeShortName], 
			[self legProperName], [self districtPartyString]];
	[self didAccessValueForKey:@"searchName"];
	return tempString;
}

- (NSInteger)numberOfDistrictOffices {
	NSInteger offices = 0;
	
	if ([self.dist4_street length] > 0)		// 4th office is good
		offices = 4;
	else if ([self.dist3_street length] > 0)	// 3rd office is good
		offices = 3;
	else if ([self.dist2_street length] > 0)	// 2nd office is good
		offices = 2;
	else if ([self.dist1_street length] > 0)	// 1st office is good
		offices = 1;
	
	return offices;
}

- (NSArray *)sortedCommitteePositions
{
	return [[self.committeePositions allObjects] 
							sortedArrayUsingSelector:@selector(comparePositionAndCommittee:)];
}


@end
