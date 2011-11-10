// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GenericAsset.m instead.

#import "_GenericAsset.h"

@implementation GenericAssetID
@end

@implementation _GenericAsset

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"GenericAsset" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"GenericAsset";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"GenericAsset" inManagedObjectContext:moc_];
}

- (GenericAssetID*)objectID {
	return (GenericAssetID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic url;






@dynamic billDocumentsInverse;

	

@dynamic billSourcesInverse;

	

@dynamic billVersionsInverse;

	

@dynamic committeeInverse;

	

@dynamic eventInverse;

	

@dynamic legislatorInverse;

	

@dynamic voteInverse;

	





@end
