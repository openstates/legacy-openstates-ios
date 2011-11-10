// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BillSponsor.m instead.

#import "_BillSponsor.h"

@implementation BillSponsorID
@end

@implementation _BillSponsor

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"BillSponsor" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"BillSponsor";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"BillSponsor" inManagedObjectContext:moc_];
}

- (BillSponsorID*)objectID {
	return (BillSponsorID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic billInverse;

	





@end
