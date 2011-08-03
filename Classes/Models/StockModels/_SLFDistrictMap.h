// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFDistrictMap.h instead.

#import <CoreData/CoreData.h>


@class SLFLegislator;
@class SLFState;



@class NSArray;





@class NSDictionary;



@interface SLFDistrictMapID : NSManagedObjectID {}
@end

@interface _SLFDistrictMap : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SLFDistrictMapID*)objectID;




@property (nonatomic, retain) NSString *boundaryKind;


//- (BOOL)validateBoundaryKind:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *boundarySet;


//- (BOOL)validateBoundarySet:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSArray *centroidCoords;


//- (BOOL)validateCentroidCoords:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *chamber;


//- (BOOL)validateChamber:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *districtNumber;


@property short districtNumberValue;
- (short)districtNumberValue;
- (void)setDistrictNumberValue:(short)value_;

//- (BOOL)validateDistrictNumber:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *externalID;


@property int externalIDValue;
- (int)externalIDValue;
- (void)setExternalIDValue:(int)value_;

//- (BOOL)validateExternalID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *resourceURL;


//- (BOOL)validateResourceURL:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDictionary *shape;


//- (BOOL)validateShape:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *slug;


//- (BOOL)validateSlug:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *stateID;


//- (BOOL)validateStateID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet* legislators;

- (NSMutableSet*)legislatorsSet;




@property (nonatomic, retain) SLFState* state;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;




@end

@interface _SLFDistrictMap (CoreDataGeneratedAccessors)

- (void)addLegislators:(NSSet*)value_;
- (void)removeLegislators:(NSSet*)value_;
- (void)addLegislatorsObject:(SLFLegislator*)value_;
- (void)removeLegislatorsObject:(SLFLegislator*)value_;

@end

@interface _SLFDistrictMap (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBoundaryKind;
- (void)setPrimitiveBoundaryKind:(NSString*)value;




- (NSString*)primitiveBoundarySet;
- (void)setPrimitiveBoundarySet:(NSString*)value;




- (NSArray*)primitiveCentroidCoords;
- (void)setPrimitiveCentroidCoords:(NSArray*)value;




- (NSString*)primitiveChamber;
- (void)setPrimitiveChamber:(NSString*)value;




- (NSNumber*)primitiveDistrictNumber;
- (void)setPrimitiveDistrictNumber:(NSNumber*)value;

- (short)primitiveDistrictNumberValue;
- (void)setPrimitiveDistrictNumberValue:(short)value_;




- (NSNumber*)primitiveExternalID;
- (void)setPrimitiveExternalID:(NSNumber*)value;

- (int)primitiveExternalIDValue;
- (void)setPrimitiveExternalIDValue:(int)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveResourceURL;
- (void)setPrimitiveResourceURL:(NSString*)value;




- (NSDictionary*)primitiveShape;
- (void)setPrimitiveShape:(NSDictionary*)value;




- (NSString*)primitiveSlug;
- (void)setPrimitiveSlug:(NSString*)value;




- (NSString*)primitiveStateID;
- (void)setPrimitiveStateID:(NSString*)value;





- (NSMutableSet*)primitiveLegislators;
- (void)setPrimitiveLegislators:(NSMutableSet*)value;



- (SLFState*)primitiveState;
- (void)setPrimitiveState:(SLFState*)value;


@end
