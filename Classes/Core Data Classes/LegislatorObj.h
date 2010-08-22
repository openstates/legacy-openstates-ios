//
//  LegislatorObj.h
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CommitteePositionObj, WnomObj, DistrictOfficeObj, DistrictMapObj;

@interface LegislatorObj :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * dist3_city;
@property (nonatomic, retain) NSString * suffix;
@property (nonatomic, retain) NSNumber * legtype;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * dist3_fax;
@property (nonatomic, retain) NSString * dist2_phone;
@property (nonatomic, retain) NSString * bio_url;
@property (nonatomic, retain) NSString * dist4_zip;
@property (nonatomic, retain) NSString * cap_phone2;
@property (nonatomic, retain) NSString * dist4_phone1;
@property (nonatomic, retain) NSNumber * tenure;
@property (nonatomic, retain) NSString * dist2_city;
@property (nonatomic, retain) NSString * dist2_fax;
@property (nonatomic, retain) NSString * cap_phone;
@property (nonatomic, retain) NSString * cap_phone2_name;
@property (nonatomic, retain) NSString * dist4_street;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * dist1_fax;
@property (nonatomic, retain) NSNumber * legislatorID;
@property (nonatomic, retain) NSString * middlename;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * dist3_street;
@property (nonatomic, retain) NSString * dist2_zip;
@property (nonatomic, retain) NSNumber * district;
@property (nonatomic, retain) NSString * dist3_zip;
@property (nonatomic, retain) NSString * cap_fax;
@property (nonatomic, retain) NSString * dist3_phone1;
@property (nonatomic, retain) NSNumber * party_id;
@property (nonatomic, retain) NSString * chamber_desk;
@property (nonatomic, retain) NSString * dist4_city;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSString * dist1_zip;
@property (nonatomic, retain) NSString * party_name;
@property (nonatomic, retain) NSString * dist4_fax;
@property (nonatomic, retain) NSNumber * partisan_index;
@property (nonatomic, retain) NSString * dist1_phone;
@property (nonatomic, retain) NSString * dist2_street;
@property (nonatomic, retain) NSString * dist1_street;
@property (nonatomic, retain) NSString * photo_name;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * legtype_name;
@property (nonatomic, retain) NSString * dist1_city;
@property (nonatomic, retain) NSString * cap_office;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * staff;
@property (nonatomic, retain) NSString * lastnameInitial;
@property (nonatomic, retain) NSString * searchName;
@property (nonatomic, retain) DistrictMapObj *districtMap;
@property (nonatomic, retain) NSSet* committeePositions;
@property (nonatomic, retain) NSSet* wnomScores;
@property (nonatomic, retain) NSSet* districtOffices;
@property (nonatomic, readonly) NSString * districtMapURL;

- (NSComparisonResult)compareMembersByName:(LegislatorObj *)p;
- (NSString *)partyShortName;
- (NSString *)legTypeShortName;
- (NSString *)legProperName;
- (NSString *)districtPartyString;
- (NSString *)fullName;
- (NSString *)fullNameLastFirst;
- (NSString *)website;
- (NSString *)shortNameForButtons;
- (NSString *)labelSubText;
- (NSInteger) numberOfDistrictOffices;
- (NSString *)tenureString;
- (NSArray *) sortedCommitteePositions;
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
@end

