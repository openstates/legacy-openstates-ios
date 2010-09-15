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
#import "TexLegeCoreDataUtils.h"

@implementation CommitteePositionObj 

@dynamic position;
@dynamic legislator;
@dynamic committee;
@dynamic legislatorID;

- (void) importFromDictionary: (NSDictionary *)dictionary
{
	if (dictionary) {
		self.position = [dictionary objectForKey:@"position"];
		
		self.legislatorID = [dictionary objectForKey:@"legislatorID"];
		if (self.legislatorID)
			self.legislator = [TexLegeCoreDataUtils legislatorWithLegislatorID:self.legislatorID withContext:[self managedObjectContext]];

		NSNumber *committeeId = [dictionary objectForKey:@"committeeId"];
		if (committeeId)
			self.committee = [TexLegeCoreDataUtils committeeWithCommitteeID:committeeId withContext:[self managedObjectContext]];
		
	}
}


- (NSDictionary *)exportToDictionary {
	NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self.position, @"position",
							  self.committee.committeeId, @"committeeId",
							  self.legislator.legislatorID, @"legislatorID",
							  nil];
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
