// 
//  WnomObj.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "WnomObj+RestKit.h"
#import "LegislatorObj.h"
#import "TexLegeCoreDataUtils.h"

@implementation WnomObj (RestKit)


#pragma mark RKObjectMappable methods

+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"wnomID", @"wnomID",
			@"legislatorID", @"legislatorID",
			@"wnomAdj", @"wnomAdj",
			@"session", @"session",
			@"wnomStderr", @"wnomStderr",
			@"adjMean", @"adjMean",
			@"updated", @"updated",
			nil];
}

+ (NSDictionary*)relationshipToPrimaryKeyPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"legislator", @"legislatorID",
			nil];
}

+ (NSString*)primaryKeyProperty {
	return @"wnomID";
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

#pragma mark Custom Accessors

- (NSNumber *) year {
	return [NSNumber numberWithInteger:1847+(2*[self.session integerValue])];
}

@end
