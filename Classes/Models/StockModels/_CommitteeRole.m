// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CommitteeRole.m instead.

#import "_CommitteeRole.h"

@implementation CommitteeRoleID
@end

@implementation _CommitteeRole

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CommitteeRole" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CommitteeRole";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CommitteeRole" inManagedObjectContext:moc_];
}

- (CommitteeRoleID*)objectID {
	return (CommitteeRoleID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic chamber;






@dynamic committeeID;






@dynamic committeeName;






@dynamic role;






@dynamic legislatorInverse;

	





@end
