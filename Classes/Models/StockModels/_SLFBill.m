// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFBill.m instead.

#import "_SLFBill.h"

@implementation SLFBillID
@end

@implementation _SLFBill

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SLFBill" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SLFBill";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SLFBill" inManagedObjectContext:moc_];
}

- (SLFBillID*)objectID {
	return (SLFBillID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic actions;






@dynamic billID;






@dynamic chamber;






@dynamic dateCreated;






@dynamic dateUpdated;






@dynamic documents;






@dynamic session;






@dynamic sources;






@dynamic sponsors;


- (NSMutableSet*)sponsorsSet {
	[self willAccessValueForKey:@"sponsors"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"sponsors"];
	[self didAccessValueForKey:@"sponsors"];
	return result;
}






@dynamic stateID;






@dynamic subjects;






@dynamic title;






@dynamic type;






@dynamic versions;






@dynamic votes;






@dynamic stateObj;

	





@end
