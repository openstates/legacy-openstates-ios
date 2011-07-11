//
//  DistrictOfficeObj+RestKit.m
//  Created by Gregory Combs on 4/14/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
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
