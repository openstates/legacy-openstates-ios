// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFLegislator.h instead.

#import <CoreData/CoreData.h>
#import <RestKit/CoreData/CoreData.h>


@class SLFDistrict;
@class CommitteeRole;
@class GenericAsset;
@class SLFState;






















@interface SLFLegislatorID : NSManagedObjectID {}
@end

@interface _SLFLegislator : RKSearchableManagedObject {}
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




@property (nonatomic, retain) NSString *url;


//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *email;


//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;




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




@property (nonatomic, retain) NSSet* roles;

- (NSMutableSet*)rolesSet;




@property (nonatomic, retain) NSSet* sources;

- (NSMutableSet*)sourcesSet;




@property (nonatomic, retain) SLFState* stateObj;

//- (BOOL)validateStateObj:(id*)value_ error:(NSError**)error_;




@end

@interface _SLFLegislator (CoreDataGeneratedAccessors)

- (void)addRoles:(NSSet*)value_;
- (void)removeRoles:(NSSet*)value_;
- (void)addRolesObject:(CommitteeRole*)value_;
- (void)removeRolesObject:(CommitteeRole*)value_;

- (void)addSources:(NSSet*)value_;
- (void)removeSources:(NSSet*)value_;
- (void)addSourcesObject:(GenericAsset*)value_;
- (void)removeSourcesObject:(GenericAsset*)value_;

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




- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;




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



- (NSMutableSet*)primitiveRoles;
- (void)setPrimitiveRoles:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSources;
- (void)setPrimitiveSources:(NSMutableSet*)value;



- (SLFState*)primitiveStateObj;
- (void)setPrimitiveStateObj:(SLFState*)value;


@end
