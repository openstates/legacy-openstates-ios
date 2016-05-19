// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GenericNamedItem.h instead.

#import <CoreData/CoreData.h>






@interface GenericNamedItemID : NSManagedObjectID {}
@end

@interface _GenericNamedItem : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (GenericNamedItemID*)objectID;




@property (nonatomic, strong) NSString *name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *type;


//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@end

@interface _GenericNamedItem (CoreDataGeneratedAccessors)

@end

@interface _GenericNamedItem (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;




@end
