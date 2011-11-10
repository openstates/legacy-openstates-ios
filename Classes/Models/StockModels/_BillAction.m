// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BillAction.m instead.

#import "_BillAction.h"

@implementation BillActionID
@end

@implementation _BillAction

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"BillAction" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"BillAction";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"BillAction" inManagedObjectContext:moc_];
}

- (BillActionID*)objectID {
	return (BillActionID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic action;






@dynamic actionID;






@dynamic actor;






@dynamic comment;






@dynamic date;






@dynamic bill;

	

@dynamic types;

	
- (NSMutableSet*)typesSet {
	[self willAccessValueForKey:@"types"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"types"];
	[self didAccessValueForKey:@"types"];
	return result;
}
	





@end
