//
//  PartisanIndexStats.m
//  TexLege
//
//  Created by Gregory Combs on 7/9/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "PartisanIndexStats.h"
#import "LegislatorObj.h"

@interface PartisanIndexStats (Private)

- (NSNumber *) averagePartisanIndexForChamber:(NSInteger)chamber andPartyID:(NSInteger)party;
- (NSArray *) allMembersByChamber:(NSInteger)chamber andPartyID:(NSInteger)party;



@end

@implementation PartisanIndexStats

@synthesize managedObjectContext;

SYNTHESIZE_SINGLETON_FOR_CLASS(PartisanIndexStats);

// setup the data collection
- init {
	if (self = [super init]) {

	}
	return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext {
	if ([self init]) {
		self.managedObjectContext = newContext;
		m_partisanIndexAggregates = nil;
		
		// initialize these
		[self partisanIndexAggregates];
	
	}
	return self;
}

- (void)dealloc {	
	self.managedObjectContext = nil;
	if (m_partisanIndexAggregates) [m_partisanIndexAggregates release], m_partisanIndexAggregates = nil;
	
    [super dealloc];
}

- (NSNumber *) currentSessionYear {
	return [NSNumber numberWithInteger:2009];
}

- (NSDictionary *)partisanIndexAggregates {
	
	if (m_partisanIndexAggregates == nil) {
		
		NSMutableDictionary *tempAggregates = [NSMutableDictionary dictionaryWithCapacity:4];
		NSInteger chamber, party;
		for (chamber = HOUSE; chamber <= SENATE; chamber++) {
			for (party = kUnknownParty; party <= REPUBLICAN; party++) {
				NSNumber *avgIndex = [self averagePartisanIndexForChamber:chamber andPartyID:party];
				if (avgIndex)
					[tempAggregates setObject:avgIndex forKey:[NSString stringWithFormat:@"C%d+P%d", chamber, party]];
			}
		}
		NSLog(@"Index Aggregates: %@", [tempAggregates description]);			
		m_partisanIndexAggregates = [[NSDictionary dictionaryWithDictionary:tempAggregates] retain];
	}

	return m_partisanIndexAggregates;
}

- (NSNumber *) overallPartisanIndexUsingLegislator:(LegislatorObj *)legislator {
	return [self.partisanIndexAggregates objectForKey:
			[NSString stringWithFormat:@"C%d+P0", [legislator.legtype integerValue]]];
};


- (NSNumber *) partyPartisanIndexUsingLegislator:(LegislatorObj *)legislator {
	return [self.partisanIndexAggregates objectForKey:
			[NSString stringWithFormat:@"C%d+P%d", [legislator.legtype integerValue], [legislator.party_id integerValue]]];
};


#pragma mark -
#pragma mark Partisan Indexing

- (NSNumber *) averagePartisanIndexForChamber:(NSInteger)chamber andPartyID:(NSInteger)party {
	
	if (chamber == BOTH_CHAMBERS) {
		NSLog(@"allMembersByChamber: ... cannot be BOTH chambers");
		return nil;
	}
	
	NSExpression *ex = [NSExpression expressionForFunction:@"average:" arguments:
						[NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"partisan_index"]]];
	NSString *predicateString = nil;
	if (party > kUnknownParty)
		predicateString = [NSString stringWithFormat:@"legtype == %d AND party_id == %d", chamber, party];
	else
		predicateString = [NSString stringWithFormat:@"legtype == %d", chamber];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString]; 
	
	NSExpressionDescription *ed = [[NSExpressionDescription alloc] init];
	[ed setName:@"averagePartisanIndex"];
	[ed setExpression:ex];
	[ed setExpressionResultType:NSFloatAttributeType];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setPredicate:predicate];
	[request setPropertiesToFetch:[NSArray arrayWithObject:ed]];
	[request setResultType:NSDictionaryResultType];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LegislatorObj" 
											  inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	NSError *error;
	NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (objects == nil) {
		// Handle the error.
		NSLog(@"Error");
	}
	else {
		if ([objects count] > 0) {
			NSNumber *avgPartisanIndex = [[objects objectAtIndex:0] valueForKey:@"averagePartisanIndex"];
			//return [avgPartisanIndex floatValue];
			return avgPartisanIndex;
		}
	}
	
	return nil;
	
}

- (NSString *) partisanRankForLegislator:(LegislatorObj *)legislator onlyParty:(BOOL)inParty {
	
	NSArray *legislators = nil;
	
	if (inParty)
		legislators = [self allMembersByChamber:[legislator.legtype integerValue] 
									 andPartyID:[legislator.party_id integerValue]];
	else
		legislators = [self allMembersByChamber:[legislator.legtype integerValue] 
									 andPartyID:kUnknownParty];
	
	if (legislators) {
		NSInteger rank = [legislators indexOfObject:legislator];
		NSInteger count = [legislators count];
		return [NSString stringWithFormat:@"%d out of %d", rank, count];	
	}
	else {
		return nil;
	}
}


- (NSArray *) allMembersByChamber:(NSInteger)chamber andPartyID:(NSInteger)party
{
	if (chamber == BOTH_CHAMBERS) {
		NSLog(@"allMembersByChamber: ... cannot be BOTH chambers");
		return nil;
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LegislatorObj" 
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSString *predicateString = nil;
	if (party > kUnknownParty)
		predicateString = [NSString stringWithFormat:@"legtype == %d AND party_id == %d", chamber, party];
	else
		predicateString = [NSString stringWithFormat:@"legtype == %d", chamber];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString]; 
	[fetchRequest setPredicate:predicate];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"partisan_index" ascending:(party != REPUBLICAN)];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSError *error;
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	//if (error)
	//	NSLog(@"allMembersByChamber:andParty: error in executeFetchRequest: %@, %@", error, [error userInfo]);
	
	return fetchedObjects;
	
}

@end
