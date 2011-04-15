//
//  DistrictOfficeObj+RestKit.m
//  TexLege
//
//  Created by Gregory Combs on 4/14/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "DistrictOfficeObj.h"

@implementation DistrictOfficeObj (RestKit)

#pragma mark RKObjectMappable methods

+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"districtOfficeID", @"districtOfficeID",
			@"district", @"district",
			@"chamber", @"chamber",
			@"pinColorIndex", @"pinColorIndex",
			@"spanLat", @"spanLat",
			@"spanLon", @"spanLon",
			@"longitude", @"longitude",
			@"latitude", @"latitude",
			@"formattedAddress", @"formattedAddress",
			@"stateCode", @"stateCode",
			@"address", @"address",
			@"city", @"city",
			@"county", @"county",
			@"phone", @"phone",
			@"fax", @"fax",
			@"zipCode", @"zipCode",
			@"legislatorID", @"legislatorID",
			@"updated", @"updated",
			nil];
}

+ (NSDictionary*)relationshipToPrimaryKeyPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"legislator", @"legislatorID",
			nil];
}

+ (NSString*)primaryKeyProperty {
	return @"districtOfficeID";
}

#pragma mark Property Accessor Issues
/* These methods are the exact same thing (or at least *should* be the same) as the default core data object methods
 However, for whatever reason, sometimes the default returns an NSNumber instead of an NSString ... this makes sure */
- (NSString *)updated {
	[self willAccessValueForKey:@"updated"];
	NSString *outValue = [self primitiveValueForKey:@"updated"];
	[self didAccessValueForKey:@"updated"];
	return outValue;
}

- (void)setUpdated:(NSString *)inValue {
	[self willChangeValueForKey:@"updated"];
	[self setPrimitiveValue:inValue forKey:@"updated"];
	[self didChangeValueForKey:@"updated"];
}

@end
