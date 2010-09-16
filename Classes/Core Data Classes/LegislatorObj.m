// 
//  LegislatorObj.m
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "LegislatorObj.h"
#import "CommitteePositionObj.h"
#import "TexLegeCoreDataUtils.h"

@implementation LegislatorObj 

@dynamic legislatorID;
@dynamic transDataContributorID;

@dynamic firstname;
@dynamic middlename;
@dynamic lastname;
@dynamic nickname;
@dynamic suffix;
@dynamic lastnameInitial;
@dynamic searchName;

@dynamic legtype;
@dynamic legtype_name;
@dynamic district;
@dynamic party_id;
@dynamic party_name;
@dynamic partisan_index;

@dynamic photo_name;
@dynamic bio_url;
@dynamic tenure;
@dynamic email;
@dynamic twitter;

@dynamic staff;
@dynamic cap_office;
@dynamic cap_phone;
@dynamic cap_phone2;
@dynamic cap_phone2_name;
@dynamic cap_fax;

@dynamic districtMap;
@dynamic notes;

@dynamic committeePositions;
@dynamic wnomScores;
@dynamic districtOffices;

- (void) importFromDictionary: (NSDictionary *)dictionary
{
	if (dictionary) {
		self.legislatorID = [dictionary objectForKey:@"legislatorID"];
		self.transDataContributorID = [dictionary objectForKey:@"transDataContributorID"];
		
		self.firstname = [dictionary objectForKey:@"firstname"];
		self.middlename = [dictionary objectForKey:@"middlename"];
		self.lastname = [dictionary objectForKey:@"lastname"];
		self.nickname = [dictionary objectForKey:@"nickname"];
		self.suffix = [dictionary objectForKey:@"suffix"];
		
		self.legtype = [dictionary objectForKey:@"legtype"];
		self.legtype_name = [dictionary objectForKey:@"legtype_name"];
		self.district = [dictionary objectForKey:@"district"];
		self.party_id = [dictionary objectForKey:@"party_id"];
		self.party_name = [dictionary objectForKey:@"party_name"];
		self.partisan_index = [dictionary objectForKey:@"partisan_index"];
		
		self.photo_name = [dictionary objectForKey:@"photo_name"];
		self.bio_url = [dictionary objectForKey:@"bio_url"];
		self.tenure = [dictionary objectForKey:@"tenure"];
		self.email = [dictionary objectForKey:@"email"];
		self.twitter = [dictionary objectForKey:@"twitter"];
		
		self.staff = [dictionary objectForKey:@"staff"];
		self.cap_office = [dictionary objectForKey:@"cap_office"];
		self.cap_phone = [dictionary objectForKey:@"cap_phone"];
		self.cap_phone2 = [dictionary objectForKey:@"cap_phone2"];
		self.cap_phone2_name = [dictionary objectForKey:@"cap_phone2_name"];
		self.cap_fax = [dictionary objectForKey:@"cap_fax"];
		self.notes = [dictionary objectForKey:@"notes"];		

	}
}


- (NSDictionary *)exportToDictionary {
	NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self.legislatorID, @"legislatorID",
							  self.transDataContributorID, @"transDataContributorID",
							  self.firstname, @"firstname",
							  self.middlename, @"middlename",
							  self.lastname, @"lastname",
							  self.nickname, @"nickname",
							  self.suffix, @"suffix",
							  
							  self.legtype, @"legtype",
							  self.legtype_name, @"legtype_name",
							  self.district, @"district",
							  self.party_id, @"party_id",
							  self.party_name, @"party_name",
							  self.partisan_index, @"partisan_index",
							  
							  self.photo_name, @"photo_name",
							  self.bio_url, @"bio_url",
							  self.tenure, @"tenure",
							  self.email, @"email",
							  self.twitter, @"twitter",
							  
							  self.staff, @"staff",
							  self.cap_office, @"cap_office",
							  self.cap_phone2, @"cap_phone2",
							  self.cap_phone2_name, @"cap_phone2_name",
							  self.cap_fax, @"cap_fax",
							  self.notes, @"notes",
							  
							  nil];
	return tempDict;
}


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
	NSString *string = [NSString stringWithFormat: @"(%@-%d)", self.partyShortName, [self.district integerValue]];
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
	return [self.districtOffices count];
}

- (NSString *)tenureString {
	NSString *stringVal = nil;
	NSInteger years = self.tenure.integerValue;
	
	switch (years) {
		case 0:
			stringVal = @"Freshman";
			break;
		case 1:
			stringVal = [NSString stringWithFormat:@"%d Year",  years];
			break;
		default:
			stringVal = [NSString stringWithFormat:@"%d Years",  years];
			break;
	}
	return stringVal;
}

- (NSArray *)sortedCommitteePositions
{
	return [[self.committeePositions allObjects] 
							sortedArrayUsingSelector:@selector(comparePositionAndCommittee:)];
}

- (NSString *)districtMapURL
{
	NSString *url = nil;
	
	if ([self.legtype integerValue] == HOUSE)
		url = [NSString stringWithFormat:@"http://www.house.state.tx.us/members/pdf/districts/%d.pdf",
			   [self.district integerValue]];
	else if ([self.legtype integerValue] == SENATE)
		url = [NSString stringWithFormat:@"http://www.senate.state.tx.us/Icons/Dist_Maps/Dist%d_Map.pdf",
			   [self.district integerValue], [self.district integerValue]];
	
	return url;	
}

- (NSString *)chamberName {
	NSString *chamberString = nil;
	if ([self.legtype integerValue] == SENATE) // Democrat
		chamberString = @"Senate";
	else //if ([self.legislator.legtype integerValue] == HOUSE) // Republican
		chamberString = @"House";
	
	return  chamberString;
}

@end
