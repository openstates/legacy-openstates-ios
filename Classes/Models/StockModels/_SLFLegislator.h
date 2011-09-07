// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFLegislator.h instead.

#import <CoreData/CoreData.h>


@class SLFDistrict;
@class SLFCommitteePosition;
@class SLFState;

















@class NSArray;





@interface SLFLegislatorID : NSManagedObjectID {}
@end

@interface _SLFLegislator : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SLFLegislatorID*)objectID;




@property (nonatomic, retain) NSNumber *active;


@property BOOL activeValue;
- (BOOL)activeValue;
- (void)setActiveValue:(BOOL)value_;

//- (BOOL)validateActive:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *chamber;


//- (BOOL)validateChamber:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *country;


//- (BOOL)validateCountry:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDate *dateCreated;


//- (BOOL)validateDateCreated:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDate *dateUpdated;


//- (BOOL)validateDateUpdated:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *district;


//- (BOOL)validateDistrict:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *firstName;


//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *fullName;


//- (BOOL)validateFullName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *lastName;


//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *legID;


//- (BOOL)validateLegID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *level;


//- (BOOL)validateLevel:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *middleName;


//- (BOOL)validateMiddleName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *nimspCandidateID;


//- (BOOL)validateNimspCandidateID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *nimspID;


//- (BOOL)validateNimspID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *party;


//- (BOOL)validateParty:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *photoURL;


//- (BOOL)validatePhotoURL:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSArray *sources;


//- (BOOL)validateSources:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *stateID;


//- (BOOL)validateStateID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *suffixes;


//- (BOOL)validateSuffixes:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *transparencyID;


//- (BOOL)validateTransparencyID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *votesmartID;


//- (BOOL)validateVotesmartID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) SLFDistrict* districtMap;

//- (BOOL)validateDistrictMap:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* positions;

- (NSMutableSet*)positionsSet;




@property (nonatomic, retain) SLFState* stateObj;

//- (BOOL)validateStateObj:(id*)value_ error:(NSError**)error_;




@end

@interface _SLFLegislator (CoreDataGeneratedAccessors)

- (void)addPositions:(NSSet*)value_;
- (void)removePositions:(NSSet*)value_;
- (void)addPositionsObject:(SLFCommitteePosition*)value_;
- (void)removePositionsObject:(SLFCommitteePosition*)value_;

@end

@interface _SLFLegislator (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveActive;
- (void)setPrimitiveActive:(NSNumber*)value;

- (BOOL)primitiveActiveValue;
- (void)setPrimitiveActiveValue:(BOOL)value_;




- (NSString*)primitiveChamber;
- (void)setPrimitiveChamber:(NSString*)value;




- (NSString*)primitiveCountry;
- (void)setPrimitiveCountry:(NSString*)value;




- (NSDate*)primitiveDateCreated;
- (void)setPrimitiveDateCreated:(NSDate*)value;




- (NSDate*)primitiveDateUpdated;
- (void)setPrimitiveDateUpdated:(NSDate*)value;




- (NSString*)primitiveDistrict;
- (void)setPrimitiveDistrict:(NSString*)value;




- (NSString*)primitiveFirstName;
- (void)setPrimitiveFirstName:(NSString*)value;




- (NSString*)primitiveFullName;
- (void)setPrimitiveFullName:(NSString*)value;




- (NSString*)primitiveLastName;
- (void)setPrimitiveLastName:(NSString*)value;




- (NSString*)primitiveLegID;
- (void)setPrimitiveLegID:(NSString*)value;




- (NSString*)primitiveLevel;
- (void)setPrimitiveLevel:(NSString*)value;




- (NSString*)primitiveMiddleName;
- (void)setPrimitiveMiddleName:(NSString*)value;




- (NSString*)primitiveNimspCandidateID;
- (void)setPrimitiveNimspCandidateID:(NSString*)value;




- (NSString*)primitiveNimspID;
- (void)setPrimitiveNimspID:(NSString*)value;




- (NSString*)primitiveParty;
- (void)setPrimitiveParty:(NSString*)value;




- (NSString*)primitivePhotoURL;
- (void)setPrimitivePhotoURL:(NSString*)value;




- (NSArray*)primitiveSources;
- (void)setPrimitiveSources:(NSArray*)value;




- (NSString*)primitiveStateID;
- (void)setPrimitiveStateID:(NSString*)value;




- (NSString*)primitiveSuffixes;
- (void)setPrimitiveSuffixes:(NSString*)value;




- (NSString*)primitiveTransparencyID;
- (void)setPrimitiveTransparencyID:(NSString*)value;




- (NSString*)primitiveVotesmartID;
- (void)setPrimitiveVotesmartID:(NSString*)value;





- (SLFDistrict*)primitiveDistrictMap;
- (void)setPrimitiveDistrictMap:(SLFDistrict*)value;



- (NSMutableSet*)primitivePositions;
- (void)setPrimitivePositions:(NSMutableSet*)value;



- (SLFState*)primitiveStateObj;
- (void)setPrimitiveStateObj:(SLFState*)value;


@end
