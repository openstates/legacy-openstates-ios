// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CommitteeRole.h instead.

#import <CoreData/CoreData.h>


@class SLFLegislator;






@interface CommitteeRoleID : NSManagedObjectID {}
@end

@interface _CommitteeRole : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CommitteeRoleID*)objectID;




@property (nonatomic, retain) NSString *chamber;


//- (BOOL)validateChamber:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *committeeID;


//- (BOOL)validateCommitteeID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *committeeName;


//- (BOOL)validateCommitteeName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *role;


//- (BOOL)validateRole:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) SLFLegislator* legislatorInverse;

//- (BOOL)validateLegislatorInverse:(id*)value_ error:(NSError**)error_;




@end

@interface _CommitteeRole (CoreDataGeneratedAccessors)

@end

@interface _CommitteeRole (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveChamber;
- (void)setPrimitiveChamber:(NSString*)value;




- (NSString*)primitiveCommitteeID;
- (void)setPrimitiveCommitteeID:(NSString*)value;




- (NSString*)primitiveCommitteeName;
- (void)setPrimitiveCommitteeName:(NSString*)value;




- (NSString*)primitiveRole;
- (void)setPrimitiveRole:(NSString*)value;





- (SLFLegislator*)primitiveLegislatorInverse;
- (void)setPrimitiveLegislatorInverse:(SLFLegislator*)value;


@end
