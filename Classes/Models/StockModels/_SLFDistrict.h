// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFDistrictMap.h instead.

#import <CoreData/CoreData.h>


@class SLFLegislator;
@class SLFState;


@class NSArray;



@class NSDictionary;


@interface SLFDistrictID : NSManagedObjectID {}
@end

@interface _SLFDistrict : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SLFDistrictID*)objectID;




@property (nonatomic, retain) NSString *boundaryID;


//- (BOOL)validateBoundaryID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDictionary *regionDictionary;


//- (BOOL)validateRegionDictionary:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *chamber;


//- (BOOL)validateChamber:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *numSeats;


@property short numSeatsValue;
- (short)numSeatsValue;
- (void)setNumSeatsValue:(short)value_;

//- (BOOL)validateNumSeats:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSArray *shape;


//- (BOOL)validateShape:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *stateID;


//- (BOOL)validateStateID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet* legislators;

- (NSMutableSet*)legislatorsSet;




@property (nonatomic, retain) SLFState* state;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;




@end

@interface _SLFDistrict (CoreDataGeneratedAccessors)

- (void)addLegislators:(NSSet*)value_;
- (void)removeLegislators:(NSSet*)value_;
- (void)addLegislatorsObject:(SLFLegislator*)value_;
- (void)removeLegislatorsObject:(SLFLegislator*)value_;

@end

@interface _SLFDistrict (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBoundaryID;
- (void)setPrimitiveBoundaryID:(NSString*)value;




- (NSDictionary*)primitiveRegionDictionary;
- (void)setPrimitiveRegionDictionary:(NSDictionary*)value;




- (NSString*)primitiveChamber;
- (void)setPrimitiveChamber:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveNumSeats;
- (void)setPrimitiveNumSeats:(NSNumber*)value;

- (short)primitiveNumSeatsValue;
- (void)setPrimitiveNumSeatsValue:(short)value_;




- (NSDictionary*)primitiveShape;
- (void)setPrimitiveShape:(NSDictionary*)value;




- (NSString*)primitiveStateID;
- (void)setPrimitiveStateID:(NSString*)value;





- (NSMutableSet*)primitiveLegislators;
- (void)setPrimitiveLegislators:(NSMutableSet*)value;



- (SLFState*)primitiveState;
- (void)setPrimitiveState:(SLFState*)value;


@end
