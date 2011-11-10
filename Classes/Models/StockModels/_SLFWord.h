// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFWord.h instead.

#import <CoreData/CoreData.h>


@class BillAction;
@class SLFBill;
@class SLFBill;
@class SLFBill;



@interface SLFWordID : NSManagedObjectID {}
@end

@interface _SLFWord : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SLFWordID*)objectID;




@property (nonatomic, retain) NSString *word;


//- (BOOL)validateWord:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) BillAction* actionTypeInverse;

//- (BOOL)validateActionTypeInverse:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) SLFBill* billSubjectInverse;

//- (BOOL)validateBillSubjectInverse:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) SLFBill* billTitleInverse;

//- (BOOL)validateBillTitleInverse:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) SLFBill* billTypeInverse;

//- (BOOL)validateBillTypeInverse:(id*)value_ error:(NSError**)error_;




@end

@interface _SLFWord (CoreDataGeneratedAccessors)

@end

@interface _SLFWord (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveWord;
- (void)setPrimitiveWord:(NSString*)value;





- (BillAction*)primitiveActionTypeInverse;
- (void)setPrimitiveActionTypeInverse:(BillAction*)value;



- (SLFBill*)primitiveBillSubjectInverse;
- (void)setPrimitiveBillSubjectInverse:(SLFBill*)value;



- (SLFBill*)primitiveBillTitleInverse;
- (void)setPrimitiveBillTitleInverse:(SLFBill*)value;



- (SLFBill*)primitiveBillTypeInverse;
- (void)setPrimitiveBillTypeInverse:(SLFBill*)value;


@end
