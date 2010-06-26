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

@implementation CommitteePositionObj 

@dynamic position;
@dynamic legislator;
@dynamic committee;
@dynamic legislatorID;

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
