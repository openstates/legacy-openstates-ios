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






@dynamic session;






@dynamic stateID;






@dynamic title;






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
	

@dynamic documents;

	
- (NSMutableSet*)documentsSet {
	[self willAccessValueForKey:@"documents"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"documents"];
	[self didAccessValueForKey:@"documents"];
	return result;
}
	

@dynamic sources;

	
- (NSMutableSet*)sourcesSet {
	[self willAccessValueForKey:@"sources"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"sources"];
	[self didAccessValueForKey:@"sources"];
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
	

@dynamic types;

	
- (NSMutableSet*)typesSet {
	[self willAccessValueForKey:@"types"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"types"];
	[self didAccessValueForKey:@"types"];
	return result;
}
	

@dynamic versions;

	
- (NSMutableSet*)versionsSet {
	[self willAccessValueForKey:@"versions"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"versions"];
	[self didAccessValueForKey:@"versions"];
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
