// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CommitteeMember.m instead.

#import "_CommitteeMember.h"

@implementation CommitteeMemberID
@end

@implementation _CommitteeMember

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CommitteeMember" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CommitteeMember";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CommitteeMember" inManagedObjectContext:moc_];
}

- (CommitteeMemberID*)objectID {
	return (CommitteeMemberID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic legID;






@dynamic legislatorName;






@dynamic role;






@dynamic committeeInverse;

	





@end
