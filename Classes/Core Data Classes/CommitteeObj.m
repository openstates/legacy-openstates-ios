// 
//  CommitteeObj.m
//  TexLege
//
//  Created by Gregory Combs on 7/11/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "CommitteeObj.h"

#import "CommitteePositionObj.h"
#import "LegislatorObj.h"
#import "TexLegeCoreDataUtils.h"

@implementation CommitteeObj 

@dynamic clerk;
@dynamic clerk_email;
@dynamic phone;
@dynamic office;
@dynamic parentId;
@dynamic committeeId;
@dynamic url;
@dynamic committeeName;
@dynamic committeeType;
@dynamic committeeNameInitial;
@dynamic committeePositions;

@dynamic votesmartID;
@dynamic openstatesID;
@dynamic txlonline_id;
@dynamic updated;

#pragma mark RKObjectMappable methods

+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"committeeId", @"committeeId",
			@"clerk", @"clerk",
			@"clerk_email", @"clerk_email",
			@"committeeName", @"committeeName",
			@"committeeType", @"committeeType",
			@"office", @"office",
			@"openstatesID", @"openstatesID",
			@"parentId", @"parentId",
			@"phone", @"phone",
			@"txlonline_id", @"txlonline_id",
			@"url", @"url",
			@"votesmartID", @"votesmartID",
			@"updated", @"updated",
			nil];
}
/*
+ (NSDictionary*)elementToRelationshipMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"committeePositions", @"committeePositions.committeePosition",
			nil];
}
*/
+ (NSString*)primaryKeyProperty {
	return @"committeeId";
}

- (id)proxyForJson {
	NSDictionary *tempDict = [self dictionaryWithValuesForKeys:[[[self class] elementToPropertyMappings] allKeys]];	
	return tempDict;	
}

- (NSString *) committeeNameInitial {
	[self willAccessValueForKey:@"committeeNameInitial"];
	NSString * initial = [[self committeeName] substringToIndex:1];
	[self didAccessValueForKey:@"committeeNameInitial"];
	return initial;
}

- (NSString*)typeString {
	switch ([self.committeeType integerValue]) {
		case JOINT:
			return @"Joint";
			break;
		case HOUSE:
			return @"House";
			break;
		case SENATE:
			return @"Senate";
			break;
		default:
			return @"All";
			break;
	}
}

- (NSString*)description {
	NSString  *typeName = [NSString stringWithFormat: @"%@ (%@)", [self committeeName], [self typeString]];
	return typeName;
}

- (LegislatorObj *)chair
{
	for (CommitteePositionObj *position in [self committeePositions]) {
		if (position.legislator && [[position position] integerValue] == POS_CHAIR)
			return position.legislator;
	}
	 return nil;
}
				 
- (LegislatorObj *)vicechair
{
	for (CommitteePositionObj *position in [self committeePositions]) {
		if (position.legislator && [[position position] integerValue] == POS_VICE)
			return position.legislator;
	}
	return nil;
}

- (NSArray *)sortedMembers
{
	NSMutableArray *memberArray = [[[NSMutableArray alloc] init] autorelease];
	for (CommitteePositionObj *position in [self committeePositions]) {
		if (position.legislator && [[position position] integerValue] == POS_MEMBER)
			[memberArray addObject:position.legislator];
	}
	[memberArray sortUsingSelector:@selector(compareMembersByName:)];

	return memberArray;
}

@end
