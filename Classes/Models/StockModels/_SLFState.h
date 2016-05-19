// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFState.h instead.

#import <CoreData/CoreData.h>


@class GenericAsset;
@class SLFBill;
@class SLFCommittee;
@class SLFDistrict;
@class SLFEvent;
@class SLFLegislator;


@class NSArray;






@class NSDictionary;

@class NSArray;




@interface SLFStateID : NSManagedObjectID {}
@end

@interface _SLFState : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SLFStateID*)objectID;




@property (nonatomic, strong) NSDate *dateUpdated;


//- (BOOL)validateDateUpdated:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSArray *featureFlags;


//- (BOOL)validateFeatureFlags:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *legislatureName;


//- (BOOL)validateLegislatureName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *level;


//- (BOOL)validateLevel:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *lowerChamberName;


//- (BOOL)validateLowerChamberName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *lowerChamberTerm;


@property short lowerChamberTermValue;
- (short)lowerChamberTermValue;
- (void)setLowerChamberTermValue:(short)value_;

//- (BOOL)validateLowerChamberTerm:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *lowerChamberTitle;


//- (BOOL)validateLowerChamberTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDictionary *sessionDetails;


//- (BOOL)validateSessionDetails:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *stateID;


//- (BOOL)validateStateID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSArray *terms;


//- (BOOL)validateTerms:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *upperChamberName;


//- (BOOL)validateUpperChamberName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *upperChamberTerm;


@property short upperChamberTermValue;
- (short)upperChamberTermValue;
- (void)setUpperChamberTermValue:(short)value_;

//- (BOOL)validateUpperChamberTerm:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *upperChamberTitle;


//- (BOOL)validateUpperChamberTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* bills;

- (NSMutableSet*)billsSet;




@property (nonatomic, strong) NSSet* capitolMaps;

- (NSMutableSet*)capitolMapsSet;




@property (nonatomic, strong) NSSet* committees;

- (NSMutableSet*)committeesSet;




@property (nonatomic, strong) NSSet* districts;

- (NSMutableSet*)districtsSet;




@property (nonatomic, strong) NSSet* events;

- (NSMutableSet*)eventsSet;




@property (nonatomic, strong) NSSet* legislators;

- (NSMutableSet*)legislatorsSet;




@end

@interface _SLFState (CoreDataGeneratedAccessors)

- (void)addBills:(NSSet*)value_;
- (void)removeBills:(NSSet*)value_;
- (void)addBillsObject:(SLFBill*)value_;
- (void)removeBillsObject:(SLFBill*)value_;

- (void)addCapitolMaps:(NSSet*)value_;
- (void)removeCapitolMaps:(NSSet*)value_;
- (void)addCapitolMapsObject:(GenericAsset*)value_;
- (void)removeCapitolMapsObject:(GenericAsset*)value_;

- (void)addCommittees:(NSSet*)value_;
- (void)removeCommittees:(NSSet*)value_;
- (void)addCommitteesObject:(SLFCommittee*)value_;
- (void)removeCommitteesObject:(SLFCommittee*)value_;

- (void)addDistricts:(NSSet*)value_;
- (void)removeDistricts:(NSSet*)value_;
- (void)addDistrictsObject:(SLFDistrict*)value_;
- (void)removeDistrictsObject:(SLFDistrict*)value_;

- (void)addEvents:(NSSet*)value_;
- (void)removeEvents:(NSSet*)value_;
- (void)addEventsObject:(SLFEvent*)value_;
- (void)removeEventsObject:(SLFEvent*)value_;

- (void)addLegislators:(NSSet*)value_;
- (void)removeLegislators:(NSSet*)value_;
- (void)addLegislatorsObject:(SLFLegislator*)value_;
- (void)removeLegislatorsObject:(SLFLegislator*)value_;

@end

@interface _SLFState (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDateUpdated;
- (void)setPrimitiveDateUpdated:(NSDate*)value;




- (NSArray*)primitiveFeatureFlags;
- (void)setPrimitiveFeatureFlags:(NSArray*)value;




- (NSString*)primitiveLegislatureName;
- (void)setPrimitiveLegislatureName:(NSString*)value;




- (NSString*)primitiveLevel;
- (void)setPrimitiveLevel:(NSString*)value;




- (NSString*)primitiveLowerChamberName;
- (void)setPrimitiveLowerChamberName:(NSString*)value;




- (NSNumber*)primitiveLowerChamberTerm;
- (void)setPrimitiveLowerChamberTerm:(NSNumber*)value;

- (short)primitiveLowerChamberTermValue;
- (void)setPrimitiveLowerChamberTermValue:(short)value_;




- (NSString*)primitiveLowerChamberTitle;
- (void)setPrimitiveLowerChamberTitle:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSDictionary*)primitiveSessionDetails;
- (void)setPrimitiveSessionDetails:(NSDictionary*)value;




- (NSString*)primitiveStateID;
- (void)setPrimitiveStateID:(NSString*)value;




- (NSArray*)primitiveTerms;
- (void)setPrimitiveTerms:(NSArray*)value;




- (NSString*)primitiveUpperChamberName;
- (void)setPrimitiveUpperChamberName:(NSString*)value;




- (NSNumber*)primitiveUpperChamberTerm;
- (void)setPrimitiveUpperChamberTerm:(NSNumber*)value;

- (short)primitiveUpperChamberTermValue;
- (void)setPrimitiveUpperChamberTermValue:(short)value_;




- (NSString*)primitiveUpperChamberTitle;
- (void)setPrimitiveUpperChamberTitle:(NSString*)value;





- (NSMutableSet*)primitiveBills;
- (void)setPrimitiveBills:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCapitolMaps;
- (void)setPrimitiveCapitolMaps:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCommittees;
- (void)setPrimitiveCommittees:(NSMutableSet*)value;



- (NSMutableSet*)primitiveDistricts;
- (void)setPrimitiveDistricts:(NSMutableSet*)value;



- (NSMutableSet*)primitiveEvents;
- (void)setPrimitiveEvents:(NSMutableSet*)value;



- (NSMutableSet*)primitiveLegislators;
- (void)setPrimitiveLegislators:(NSMutableSet*)value;


@end
