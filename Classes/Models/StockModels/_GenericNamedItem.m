// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GenericNamedItem.m instead.

#import "_GenericNamedItem.h"

@implementation GenericNamedItemID
@end

@implementation _GenericNamedItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"GenericNamedItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"GenericNamedItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"GenericNamedItem" inManagedObjectContext:moc_];
}

- (GenericNamedItemID*)objectID {
	return (GenericNamedItemID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic type;










@end
