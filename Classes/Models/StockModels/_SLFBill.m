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




@dynamic billID;






@dynamic chamber;






@dynamic dateCreated;






@dynamic dateUpdated;






@dynamic documents;






@dynamic session;






@dynamic sources;






@dynamic stateID;






@dynamic title;






@dynamic versions;






@dynamic actions;

	
- (NSMutableSet*)actionsSet {
	[self willAccessValueForKey:@"actions"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"actions"];
	[self didAccessValueForKey:@"actions"];
	return result;
}
	

@dynamic alternateTitles;

	
- (NSMutableSet*)alternateTitlesSet {
	[self willAccessValueForKey:@"alternateTitles"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"alternateTitles"];
	[self didAccessValueForKey:@"alternateTitles"];
	return result;
}
	

@dynamic sponsors;

	
- (NSMutableSet*)sponsorsSet {
	[self willAccessValueForKey:@"sponsors"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"sponsors"];
	[self didAccessValueForKey:@"sponsors"];
	return result;
}
	

@dynamic stateObj;

	

@dynamic subjects;

	
- (NSMutableSet*)subjectsSet {
	[self willAccessValueForKey:@"subjects"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"subjects"];
	[self didAccessValueForKey:@"subjects"];
	return result;
}
	

@dynamic type;

	
- (NSMutableSet*)typeSet {
	[self willAccessValueForKey:@"type"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"type"];
	[self didAccessValueForKey:@"type"];
	return result;
}
	

@dynamic votes;

	
- (NSMutableSet*)votesSet {
	[self willAccessValueForKey:@"votes"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"votes"];
	[self didAccessValueForKey:@"votes"];
	return result;
}
	





@end
