// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GenericWord.m instead.

#import "_GenericWord.h"

@implementation GenericWordID
@end

@implementation _GenericWord

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"GenericWord" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"GenericWord";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"GenericWord" inManagedObjectContext:moc_];
}

- (GenericWordID*)objectID {
	return (GenericWordID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic word;






@dynamic actionInverse;

	

@dynamic billSubjectInverse;

	

@dynamic billTitleInverse;

	

@dynamic billTypeInverse;

	





@end
