// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BillVoter.m instead.

#import "_BillVoter.h"

@implementation BillVoterID
@end

@implementation _BillVoter

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"BillVoter" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"BillVoter";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"BillVoter" inManagedObjectContext:moc_];
}

- (BillVoterID*)objectID {
	return (BillVoterID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic noVoteInverse;

	

@dynamic otherVoteInverse;

	

@dynamic yesVoteInverse;

	





@end
