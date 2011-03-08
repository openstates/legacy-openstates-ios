// 
//  CommitteePositionObj.m
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "CommitteePositionObj.h"
#import "CommitteeObj.h"
#import "LegislatorObj.h"
//#import "TexLegeCoreDataUtils.h"

@implementation CommitteePositionObj 

@dynamic committeePositionID;
@dynamic position;
@dynamic legislator;
@dynamic committee;
@dynamic legislatorID;
@dynamic committeeId;
@dynamic updated;

#pragma mark RKObjectMappable methods

+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"committeePositionID", @"committeePositionID",
			@"legislatorID", @"legislatorID",
			@"committeeId", @"committeeId",
			@"position", @"position",
			@"updated", @"updated",
			nil];
}
/*
+ (NSDictionary*)elementToRelationshipMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"legislator", @"legislator",
			@"committee", @"committee",
			nil];
}
*/
+ (NSDictionary*)relationshipToPrimaryKeyPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"legislator", @"legislatorID",
			@"committee", @"committeeId",
			nil];
}

+ (NSString*)primaryKeyProperty {
	return @"committeePositionID";
}
/*
- (void)setCommitteeId:(NSNumber *)newID {
	NSString *key = @"committeeId";
	[self willChangeValueForKey:key];
	[self setPrimitiveValue:newID forKey:key];
	
	CommitteeObj *newComm = [CommitteeObj objectWithPrimaryKeyValue:newID];
	self.committee = newComm;
	
	[self didChangeValueForKey:key];
}

- (void)setLegislatorID:(NSNumber *)newID {
	NSString *key = @"legislatorID";
	[self willChangeValueForKey:key];
	[self setPrimitiveValue:newID forKey:key];
	
	LegislatorObj *newObj = [LegislatorObj objectWithPrimaryKeyValue:newID];
	self.legislator = newComm;
	
	[self didChangeValueForKey:key];
}
*/
- (id)proxyForJson {
	NSDictionary *tempDict = [self dictionaryWithValuesForKeys:[[[self class] elementToPropertyMappings] allKeys]];	
	return tempDict;	
}

- (NSString*)positionString {
	if ([[self position] integerValue] == POS_CHAIR) 
		return @"Chair";
	else if ([[self position] integerValue] == POS_VICE) 
		return @"Vice Chair";
	else
		return @"Member";
}

- (NSComparisonResult)comparePositionAndCommittee:(CommitteePositionObj *)p
{
	NSInteger selfOrder = [[self position] integerValue];
	NSInteger comparedToOrder = [[p position] integerValue];
	NSComparisonResult result = NSOrderedSame;
	
	if (selfOrder < comparedToOrder) // reversed order, lower position id is higher
		result = NSOrderedDescending;
	else if (selfOrder > comparedToOrder)
		result = NSOrderedAscending;
	else { // they're both the same position (i.e. just a regular committee member)
		result = [[[self committee] committeeName] compare: [[p committee] committeeName]];
	}
	
	return result;	
}

@end
