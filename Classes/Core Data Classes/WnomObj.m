// 
//  WnomObj.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "WnomObj.h"
#import "LegislatorObj.h"
#import "TexLegeCoreDataUtils.h"

@implementation WnomObj 

@dynamic wnomID;
@dynamic legislatorID;
@dynamic wnomAdj;
@dynamic session;
@dynamic wnomStderr;
@dynamic legislator;
@dynamic adjMean;
@dynamic updated;

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
/*
+ (NSDictionary*)elementToRelationshipMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"legislator", @"legislator",
			nil];
}
*/
+ (NSDictionary*)relationshipToPrimaryKeyPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"legislator", @"legislatorID",
			nil];
}


+ (NSString*)primaryKeyProperty {
	return @"wnomID";
}

- (id)proxyForJson {
	NSDictionary *tempDict = [self dictionaryWithValuesForKeys:[[[self class] elementToPropertyMappings] allKeys]];	
	return tempDict;	
}

- (NSNumber *) year {
	return [NSNumber numberWithInteger:1847+(2*[self.session integerValue])];
}


@end
