//
//  LegislatorObj.h
//  Created by Gregory Combs on 1/22/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@class CommitteePositionObj;
@class DistrictMapObj;
@class DistrictOfficeObj;
@class StafferObj;
@class WnomObj;

@interface LegislatorObj :  RKManagedObject  
{
}

@property (nonatomic, retain) NSString * transDataContributorID;
@property (nonatomic, retain) NSNumber * legislatorID;
@property (nonatomic, retain) NSString * lastnameInitial;
@property (nonatomic, retain) NSString * cap_office;
@property (nonatomic, retain) NSNumber * votesmartDistrictID;
@property (nonatomic, retain) NSNumber * tenure;
@property (nonatomic, retain) NSString * stateID;
@property (nonatomic, retain) NSString * cap_fax;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSNumber * party_id;
@property (nonatomic, retain) NSNumber * nimsp_id;
@property (nonatomic, retain) NSString * updated;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSNumber * district;
@property (nonatomic, retain) NSString * cap_phone2;
@property (nonatomic, retain) NSString * searchName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * party_name;
@property (nonatomic, retain) NSString * legtype_name;
@property (nonatomic, retain) NSString * txlonline_id;
@property (nonatomic, retain) NSString * suffix;
@property (nonatomic, retain) NSString * bio_url;
@property (nonatomic, retain) NSString * cap_phone2_name;
@property (nonatomic, retain) NSString * middlename;
@property (nonatomic, retain) NSString * cap_phone;
@property (nonatomic, retain) NSString * photo_name;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * photo_url;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * openstatesID;
@property (nonatomic, retain) NSString * preferredname;
@property (nonatomic, retain) NSNumber * votesmartOfficeID;
@property (nonatomic, retain) NSNumber * partisan_index;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * nextElection;
@property (nonatomic, retain) NSNumber * legtype;
@property (nonatomic, retain) NSNumber * votesmartID;
@property (nonatomic, retain) NSSet* districtOffices;
@property (nonatomic, retain) DistrictMapObj * districtMap;
@property (nonatomic, retain) NSSet* wnomScores;
@property (nonatomic, retain) NSSet* staffers;
@property (nonatomic, retain) NSSet* committeePositions;

@end


@interface LegislatorObj (CoreDataGeneratedAccessors)
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

- (void)addCommitteePositionsObject:(CommitteePositionObj *)value;
- (void)removeCommitteePositionsObject:(CommitteePositionObj *)value;
- (void)addCommitteePositions:(NSSet *)value;
- (void)removeCommitteePositions:(NSSet *)value;

@end

