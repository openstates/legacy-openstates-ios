// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BillRecordVote.m instead.

#import "_BillRecordVote.h"

@implementation BillRecordVoteID
@end

@implementation _BillRecordVote

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"BillRecordVote" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"BillRecordVote";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"BillRecordVote" inManagedObjectContext:moc_];
}

- (BillRecordVoteID*)objectID {
	return (BillRecordVoteID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"noCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"noCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"otherCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"otherCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"passedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"passed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"yesCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"yesCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic billChamber;






@dynamic chamber;






@dynamic date;






@dynamic method;






@dynamic motion;






@dynamic noCount;



- (short)noCountValue {
	NSNumber *result = [self noCount];
	return [result shortValue];
}

- (void)setNoCountValue:(short)value_ {
	[self setNoCount:[NSNumber numberWithShort:value_]];
}

- (short)primitiveNoCountValue {
	NSNumber *result = [self primitiveNoCount];
	return [result shortValue];
}

- (void)setPrimitiveNoCountValue:(short)value_ {
	[self setPrimitiveNoCount:[NSNumber numberWithShort:value_]];
}





@dynamic otherCount;



- (short)otherCountValue {
	NSNumber *result = [self otherCount];
	return [result shortValue];
}

- (void)setOtherCountValue:(short)value_ {
	[self setOtherCount:[NSNumber numberWithShort:value_]];
}

- (short)primitiveOtherCountValue {
	NSNumber *result = [self primitiveOtherCount];
	return [result shortValue];
}

- (void)setPrimitiveOtherCountValue:(short)value_ {
	[self setPrimitiveOtherCount:[NSNumber numberWithShort:value_]];
}





@dynamic passed;



- (BOOL)passedValue {
	NSNumber *result = [self passed];
	return [result boolValue];
}

- (void)setPassedValue:(BOOL)value_ {
	[self setPassed:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitivePassedValue {
	NSNumber *result = [self primitivePassed];
	return [result boolValue];
}

- (void)setPrimitivePassedValue:(BOOL)value_ {
	[self setPrimitivePassed:[NSNumber numberWithBool:value_]];
}





@dynamic record;






@dynamic session;






@dynamic sources;






@dynamic stateID;






@dynamic type;






@dynamic voteID;






@dynamic yesCount;



- (short)yesCountValue {
	NSNumber *result = [self yesCount];
	return [result shortValue];
}

- (void)setYesCountValue:(short)value_ {
	[self setYesCount:[NSNumber numberWithShort:value_]];
}

- (short)primitiveYesCountValue {
	NSNumber *result = [self primitiveYesCount];
	return [result shortValue];
}

- (void)setPrimitiveYesCountValue:(short)value_ {
	[self setPrimitiveYesCount:[NSNumber numberWithShort:value_]];
}





@dynamic bill;

	

@dynamic noVotes;

	
- (NSMutableSet*)noVotesSet {
	[self willAccessValueForKey:@"noVotes"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"noVotes"];
	[self didAccessValueForKey:@"noVotes"];
	return result;
}
	

@dynamic otherVotes;

	
- (NSMutableSet*)otherVotesSet {
	[self willAccessValueForKey:@"otherVotes"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"otherVotes"];
	[self didAccessValueForKey:@"otherVotes"];
	return result;
}
	

@dynamic yesVotes;

	
- (NSMutableSet*)yesVotesSet {
	[self willAccessValueForKey:@"yesVotes"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"yesVotes"];
	[self didAccessValueForKey:@"yesVotes"];
	return result;
}
	





@end
