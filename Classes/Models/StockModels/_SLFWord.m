// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFWord.m instead.

#import "_SLFWord.h"

@implementation SLFWordID
@end

@implementation _SLFWord

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SLFWord" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SLFWord";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SLFWord" inManagedObjectContext:moc_];
}

- (SLFWordID*)objectID {
	return (SLFWordID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic word;






@dynamic actionTypeInverse;

	

@dynamic billSubjectInverse;

	

@dynamic billTitleInverse;

	

@dynamic billTypeInverse;

	





@end
