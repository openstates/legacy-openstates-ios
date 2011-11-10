// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BillAction.h instead.

#import <CoreData/CoreData.h>


@class SLFBill;
@class SLFWord;







@interface BillActionID : NSManagedObjectID {}
@end

@interface _BillAction : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BillActionID*)objectID;




@property (nonatomic, retain) NSString *action;


//- (BOOL)validateAction:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *actionID;


//- (BOOL)validateActionID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *actor;


//- (BOOL)validateActor:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *comment;


//- (BOOL)validateComment:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDate *date;


//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) SLFBill* bill;

//- (BOOL)validateBill:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* type;

- (NSMutableSet*)typeSet;




@end

@interface _BillAction (CoreDataGeneratedAccessors)

- (void)addType:(NSSet*)value_;
- (void)removeType:(NSSet*)value_;
- (void)addTypeObject:(SLFWord*)value_;
- (void)removeTypeObject:(SLFWord*)value_;

@end

@interface _BillAction (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAction;
- (void)setPrimitiveAction:(NSString*)value;




- (NSString*)primitiveActionID;
- (void)setPrimitiveActionID:(NSString*)value;




- (NSString*)primitiveActor;
- (void)setPrimitiveActor:(NSString*)value;




- (NSString*)primitiveComment;
- (void)setPrimitiveComment:(NSString*)value;




- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;





- (SLFBill*)primitiveBill;
- (void)setPrimitiveBill:(SLFBill*)value;



- (NSMutableSet*)primitiveType;
- (void)setPrimitiveType:(NSMutableSet*)value;


@end
