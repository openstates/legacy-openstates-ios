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
#import "DistrictMapObj.h"
#import "StafferObj.h"
#import "DistrictOfficeObj.h"
#import "WnomObj.h"
#import "UtilityMethods.h"

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

@dynamic cap_office;
@dynamic cap_phone;
@dynamic cap_phone2;
@dynamic cap_phone2_name;
@dynamic cap_fax;

@dynamic notes;

@dynamic committeePositions;
@dynamic wnomScores;
@dynamic districtOffices;

@dynamic nextElection;
@dynamic nimsp_id;
@dynamic openstatesID;
@dynamic photo_url;
@dynamic preferredname;
@dynamic stateID;
@dynamic txlonline_id;
@dynamic votesmartDistrictID;
@dynamic votesmartID;
@dynamic votesmartOfficeID;
@dynamic staffers;
@dynamic updated;

@dynamic districtMap;

#pragma mark RKObjectMappable methods

+ (NSDictionary*)elementToPropertyMappings {	
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"partisan_index", @"partisan_index",
			@"bio_url", @"bio_url",
			@"cap_fax", @"cap_fax",
			@"cap_office", @"cap_office",
			@"cap_phone", @"cap_phone",
			@"cap_phone2", @"cap_phone2",
			@"cap_phone2_name", @"cap_phone2_name",
			@"district", @"district",
			@"email", @"email",
			@"firstname", @"firstname",
			@"lastname", @"lastname",
			@"legislatorID", @"legislatorID",
			@"legtype", @"legtype",
			@"legtype_name", @"legtype_name",
			@"middlename", @"middlename",
			@"nextElection", @"nextElection",
			@"nickname", @"nickname",
			@"nimsp_id", @"nimsp_id",
			@"notes", @"notes",
			@"openstatesID", @"openstatesID",
			@"party_id", @"party_id",
			@"party_name", @"party_name",
			@"photo_name", @"photo_name",
			@"photo_url", @"photo_url",
			@"preferredname", @"preferredname",
			@"stateID", @"stateID",
			@"suffix", @"suffix",
			@"tenure", @"tenure",
			@"transDataContributorID", @"transDataContributorID",
			@"twitter", @"twitter",
			@"txlonline_id", @"txlonline_id",
			@"votesmartDistrictID", @"votesmartDistrictID",
			@"votesmartID", @"votesmartID",
			@"votesmartOfficeID", @"votesmartOfficeID",
			@"updated",@"updated",
			nil];
}
/*
+ (NSDictionary*)elementToRelationshipMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"committeePositions", @"committeePositions.committeePosition",
			@"districtOffices", @"districtOffices.districtOffice",
			@"wnomScores", @"wnomScores.wnomScore",
			@"staffers", @"staffers.staffer",
			nil];
}
*/
+ (NSString*)primaryKeyProperty {
	return @"legislatorID";
}


- (id)proxyForJson {					 
	NSDictionary *tempDict = [self dictionaryWithValuesForKeys:[[[self class] elementToPropertyMappings] allKeys]];	
	return tempDict;	
}

- (NSComparisonResult)compareMembersByName:(LegislatorObj *)p
{	
	return [[self fullNameLastFirst] compare: [p fullNameLastFirst]];	
}
/*
- (DistrictMapObj *)districtMap {
	DistrictMapObj *aDistrict = nil;
	if (self.district && self.legtype) {
		aDistrict = [TexLegeCoreDataUtils districtMapForDistrict:self.district andChamber:self.legtype lightProperties:YES];
		//aDistrict.legislator = self;		// should we do this, since we already do it in the map object?
	}
	return aDistrict;
}*/

- (NSString *) lastnameInitial {
	[self willAccessValueForKey:@"lastnameInitial"];
	NSString * initial = [[self lastname] substringToIndex:1];
	[self didAccessValueForKey:@"lastnameInitial"];
	return initial;
}

- (void) setLastnameInitial:(NSString *)newName {
	// ignore this
}

- (NSString *)partyShortName {
	return stringForParty([self.party_id integerValue], TLReturnInitial);
}

- (NSString *)legTypeShortName {
	return stringForChamber([self.legtype integerValue], TLReturnAbbrev);
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

	NSString *formatString = nil;
	if ([self.legtype integerValue] == HOUSE)
		formatString = [UtilityMethods texLegeStringWithKeyPath:@"OfficialURLs.houseWeb"];	// contains format placeholders
	else
		formatString = [UtilityMethods texLegeStringWithKeyPath:@"OfficialURLs.senateWeb"];	// contains format placeholders
	
	if (formatString)
		return [formatString stringByReplacingOccurrencesOfString:@"%@" withString:[self.district stringValue]];
	return nil;
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
	if (!self.districtOffices || [[NSNull null] isEqual:self.districtOffices])
		return 0;
	else
		return [self.districtOffices count];
}

- (NSInteger)numberOfStaffers {
	if (!self.staffers || [[NSNull null] isEqual:self.staffers])
		return 0;
	else
		return [self.staffers count];
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

- (NSArray *)sortedStaffers {
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES] autorelease];
	return [[self.staffers allObjects] 
			sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (NSString *)districtMapURL
{
	NSString *chamber = stringForChamber([self.legtype integerValue], TLReturnFull);
	NSString *formatString = [UtilityMethods texLegeStringWithKeyPath:@"OfficialURLs.mapPdfUrl"];	// contains format placeholders
	if (chamber && formatString && self.district)
		return [NSString stringWithFormat:formatString, chamber, self.district];
	return nil;	
}

- (NSString *)chamberName {	
	return  stringForChamber([self.legtype integerValue], TLReturnFull);
}

@end
