// 
//  StafferObj.m
//  TexLege
//
//  Created by Gregory Combs on 1/22/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "StafferObj.h"
#import "LegislatorObj.h"

@implementation StafferObj 

@dynamic phone;
@dynamic title;
@dynamic email;
@dynamic name;
@dynamic stafferID;
@dynamic legislatorID;
@dynamic legislator;
@dynamic updated;

#pragma mark RKObjectMappable methods

+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"phone", @"phone",
			@"stafferID", @"stafferID",
			@"legislatorID", @"legislatorID",
			@"name", @"name",
			@"email", @"email",
			@"title", @"title",
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
	return @"stafferID";
}
/*
- (id)proxyForJson {
	NSDictionary *tempDict = [self dictionaryWithValuesForKeys:[[[self class] elementToPropertyMappings] allKeys]];	
	return tempDict;	
}
*/
@end
