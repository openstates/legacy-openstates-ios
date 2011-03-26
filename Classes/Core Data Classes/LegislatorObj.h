//
//  LegislatorObj.h
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@class CommitteePositionObj, WnomObj, DistrictOfficeObj, DistrictMapObj, StafferObj;

@interface LegislatorObj :  RKManagedObject
{
	NSString * suffix;
	NSNumber * legtype;
	NSString * email;
	NSString * bio_url;
	NSString * cap_phone2;
	NSNumber * tenure;
	NSString * cap_phone;
	NSString * cap_phone2_name;
	NSString * lastname;
	NSNumber * legislatorID;
	NSString * middlename;
	NSString * notes;
	NSNumber * district;
	NSString * cap_fax;
	NSNumber * party_id;
	NSString * twitter;
	NSString * party_name;
	NSNumber * partisan_index;
	NSString * photo_name;
	NSString * nickname;
	NSString * legtype_name;
	NSString * cap_office;
	NSString * firstname;
	NSString * lastnameInitial;
	NSString * searchName;
	NSString * transDataContributorID;
	NSNumber * nimsp_id;
	NSString * openstatesID;
	NSString * photo_url;
	NSString * preferredname;
	NSString * stateID;
	NSString * txlonline_id;
	NSNumber * votesmartDistrictID;
	NSNumber * votesmartID;
	NSNumber * votesmartOfficeID;
	NSNumber * nextElection;
	NSString * updated;	
	DistrictMapObj *districtMap;
	NSSet* committeePositions;
	NSSet* wnomScores;
	NSSet* districtOffices;
	NSSet* staffers;
}

@property (nonatomic, retain) NSString * suffix;
@property (nonatomic, retain) NSNumber * legtype;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * bio_url;
@property (nonatomic, retain) NSString * cap_phone2;
@property (nonatomic, retain) NSNumber * tenure;
@property (nonatomic, retain) NSString * cap_phone;
@property (nonatomic, retain) NSString * cap_phone2_name;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSNumber * legislatorID;
@property (nonatomic, retain) NSString * middlename;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * district;
@property (nonatomic, retain) NSString * cap_fax;
@property (nonatomic, retain) NSNumber * party_id;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSString * party_name;
@property (nonatomic, retain) NSNumber * partisan_index;
@property (nonatomic, retain) NSString * photo_name;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * legtype_name;
@property (nonatomic, retain) NSString * cap_office;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastnameInitial;
@property (nonatomic, retain) NSString * searchName;
@property (nonatomic, retain) NSString * transDataContributorID;

@property (nonatomic, retain) NSNumber * nimsp_id;
@property (nonatomic, retain) NSString * openstatesID;
@property (nonatomic, retain) NSString * photo_url;
@property (nonatomic, retain) NSString * preferredname;
@property (nonatomic, retain) NSString * stateID;
@property (nonatomic, retain) NSString * txlonline_id;
@property (nonatomic, retain) NSNumber * votesmartDistrictID;
@property (nonatomic, retain) NSNumber * votesmartID;
@property (nonatomic, retain) NSNumber * votesmartOfficeID;
@property (nonatomic, retain) NSNumber * nextElection;
@property (nonatomic, retain) NSString * updated;

@property (nonatomic, retain) NSSet* staffers;
@property (nonatomic, retain) NSSet* committeePositions;
@property (nonatomic, retain) NSSet* wnomScores;
@property (nonatomic, retain) NSSet* districtOffices;
@property (nonatomic, retain) DistrictMapObj *districtMap;

@property (nonatomic, readonly) NSString * districtMapURL;
@property (nonatomic, readonly) WnomObj *latestWnomScore;
@property (nonatomic, readonly) CGFloat latestWnomFloat;


- (NSComparisonResult)compareMembersByName:(LegislatorObj *)p;
- (NSString *)partyShortName;
- (NSString *)legTypeShortName;
- (NSString *)chamberName;
- (NSString *)legProperName;
- (NSString *)districtPartyString;
- (NSString *)fullName;
- (NSString *)fullNameLastFirst;
- (NSString *)website;
- (NSString *)shortNameForButtons;
- (NSString *)labelSubText;
- (NSInteger) numberOfDistrictOffices;
- (NSInteger)numberOfStaffers;
- (NSString *)tenureString;
- (NSArray *) sortedCommitteePositions;
- (NSArray *)sortedStaffers;
@end


@interface LegislatorObj (CoreDataGeneratedAccessors)
- (void)addCommitteePositionsObject:(CommitteePositionObj *)value;
- (void)removeCommitteePositionsObject:(CommitteePositionObj *)value;
- (void)addCommitteePositions:(NSSet *)value;
- (void)removeCommitteePositions:(NSSet *)value;

- (void)addDistrictOfficesObject:(DistrictOfficeObj *)value;
- (void)removeDistrictOfficesObject:(DistrictOfficeObj *)value;
- (void)addDistrictOffices:(NSSet *)value;
- (void)removeDistrictOffices:(NSSet *)value;

- (void)addWnomScoresObject:(WnomObj *)value;
- (void)removeWnomScoresObject:(WnomObj *)value;
- (void)addWnomScores:(NSSet *)value;
- (void)removeWnomScores:(NSSet *)value;

- (void)addStaffersObject:(StafferObj *)value;
- (void)removeStaffersObject:(StafferObj *)value;
- (void)addStaffers:(NSSet *)value;
- (void)removeStaffers:(NSSet *)value;

@end

