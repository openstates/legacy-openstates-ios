// 
//  CommitteePositionObj.m
//  Created by Gregory Combs on 7/10/09.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "CommitteePositionObj+RestKit.h"
#import "CommitteeObj.h"

@implementation CommitteePositionObj (RestKit)

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

+ (NSDictionary*)relationshipToPrimaryKeyPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"legislator", @"legislatorID",
			@"committee", @"committeeId",
			nil];
}

+ (NSString*)primaryKeyProperty {
	return @"committeePositionID";
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

- (NSString*)positionString {
	if ([[self position] integerValue] == POS_CHAIR) 
		return NSLocalizedStringFromTable(@"Chair", @"DataTableUI", @"Abbreviation / title for a person who is the committee chairperson");
	else if ([[self position] integerValue] == POS_VICE) 
		return NSLocalizedStringFromTable(@"Vice Chair", @"DataTableUI", @"Abbreviation / title for a person who is second to the committee chairperson");
	else
		return NSLocalizedStringFromTable(@"Member", @"DataTableUI", @"Title for a person who is a regular member of a committe (not chair/vice-chair)");
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
