// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CommitteeRole.h instead.

#import <CoreData/CoreData.h>
#import "GenericNamedItem.h"

@class SLFLegislator;




@interface CommitteeRoleID : NSManagedObjectID {}
@end

@interface _CommitteeRole : GenericNamedItem {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CommitteeRoleID*)objectID;




@property (nonatomic, retain) NSString *chamber;


//- (BOOL)validateChamber:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *committeeID;


//- (BOOL)validateCommitteeID:(id*)value_ error:(NSError**)error_;





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





- (SLFLegislator*)primitiveLegislatorInverse;
- (void)setPrimitiveLegislatorInverse:(SLFLegislator*)value;


@end
