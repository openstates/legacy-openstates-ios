//
//  PartisanIndexStats.m
//  TexLege
//
//  Created by Gregory Combs on 7/9/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "PartisanIndexStats.h"
#import "LegislatorObj.h"
#import "WnomObj.h"
#import "UtilityMethods.h"
#import "TexLegeCoreDataUtils.h"
#import "NSDate+Helper.h"
#import "DataModelUpdateManager.h"
#import <RestKit/Support/JSON/JSONKit/JSONKit.h>
#import "TexLegeAppDelegate.h"

@interface PartisanIndexStats (Private)
- (NSArray *) aggregatePartisanIndexForChamber:(NSInteger)chamber andPartyID:(NSInteger)party;
@end

@implementation PartisanIndexStats

SYNTHESIZE_SINGLETON_FOR_CLASS(PartisanIndexStats);

- (id)init {
	if (self = [super init]) {
		m_partisanIndexAggregates = nil;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(resetData:) name:@"RESTKIT_LOADED_LEGISLATOROBJ" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(resetData:) name:@"RESTKIT_LOADED_WNOMOBJ" object:nil];
//		[[NSNotificationCenter defaultCenter] addObserver:self
//												 selector:@selector(resetData:) name:@"RESTKIT_LOADED_WNOMAGGREGATEOBJ" object:nil];

		// initialize these
		[self partisanIndexAggregates];
		
	}
	return self;
}



- (void)dealloc {	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	if (m_partisanIndexAggregates) [m_partisanIndexAggregates release], m_partisanIndexAggregates = nil;
	
    [super dealloc];
}

- (void)resetData:(NSNotification *)notification {
	if (m_partisanIndexAggregates) [m_partisanIndexAggregates release], m_partisanIndexAggregates = nil;
	[self partisanIndexAggregates];
}

#pragma mark -
#pragma mark Statistics for Partisan Sliders

/* This collects the calculations of partisanship across members in each chamber and party, then caches the results*/
- (NSDictionary *)partisanIndexAggregates {
	if (m_partisanIndexAggregates == nil) {
		NSMutableDictionary *tempAggregates = [NSMutableDictionary dictionaryWithCapacity:4];
		NSInteger chamber, party;
		for (chamber = HOUSE; chamber <= SENATE; chamber++) {
			for (party = kUnknownParty; party <= REPUBLICAN; party++) {
				NSArray *aggregatesArray = [self aggregatePartisanIndexForChamber:chamber andPartyID:party];
				if (aggregatesArray && [aggregatesArray count]) {
					NSNumber *avgIndex = [aggregatesArray objectAtIndex:0];
					if (avgIndex)
						[tempAggregates setObject:avgIndex forKey:[NSString stringWithFormat:@"AvgC%d+P%d", chamber, party]];
					
					NSNumber *maxIndex = [aggregatesArray objectAtIndex:1];
					if (maxIndex)
						[tempAggregates setObject:maxIndex forKey:[NSString stringWithFormat:@"MaxC%d+P%d", chamber, party]];
					
					NSNumber *minIndex = [aggregatesArray objectAtIndex:2];
					if (minIndex)
						[tempAggregates setObject:minIndex forKey:[NSString stringWithFormat:@"MinC%d+P%d", chamber, party]];
				}
				else
					NSLog(@"PartisanIndexStates: Error pulling aggregate dictionary.");
			}
		}
		//debug_NSLog(@"Index Aggregates: %@", [tempAggregates description]);			
		m_partisanIndexAggregates = [[NSDictionary dictionaryWithDictionary:tempAggregates] retain];
	}
	
	return m_partisanIndexAggregates;
}

/* These are convenience methods for accessing our aggregate calculations from cache */
- (CGFloat) minPartisanIndexUsingChamber:(NSInteger)chamber {
	return [[self.partisanIndexAggregates objectForKey:
			[NSString stringWithFormat:@"MinC%d+P0", chamber]] floatValue];
};

- (CGFloat) maxPartisanIndexUsingChamber:(NSInteger)chamber {
	return [[self.partisanIndexAggregates objectForKey:
			[NSString stringWithFormat:@"MaxC%d+P0", chamber]] floatValue];
};

- (CGFloat) overallPartisanIndexUsingChamber:(NSInteger)chamber {
	return [[self.partisanIndexAggregates objectForKey:
			[NSString stringWithFormat:@"AvgC%d+P0", chamber]] floatValue];
};


- (CGFloat) partyPartisanIndexUsingChamber:(NSInteger)chamber andPartyID:(NSInteger)party {
	return [[self.partisanIndexAggregates objectForKey:
			[NSString stringWithFormat:@"AvgC%d+P%d", chamber, party]] floatValue];
};


- (NSNumber *) maxWnomSession {
	return [TexLegeCoreDataUtils fetchCalculation:@"max:" 
									   ofProperty:@"session" 
										 withType:NSInteger32AttributeType 
										 onEntity:@"WnomObj"];
}

/* This queries the partisan index from each legislator and calculates aggregate statistics */
- (NSArray *) aggregatePartisanIndexForChamber:(NSInteger)chamber andPartyID:(NSInteger)party {
	if (chamber == BOTH_CHAMBERS) {
		debug_NSLog(@"aggregatePartisanIndexForChamber: ... cannot be BOTH chambers");
		return nil;
	}
	
	NSNumber *tempNum = [self maxWnomSession];
	NSInteger maxWnomSession = WNOM_DEFAULT_LATEST_SESSION;
	if (tempNum)
		maxWnomSession = [tempNum integerValue];
	
	NSMutableString *predicateString = [NSMutableString stringWithFormat:@"self.legislator.legtype == %d AND self.session == %d", chamber, maxWnomSession];
	
	if (party > kUnknownParty)
		[predicateString appendFormat:@" AND self.legislator.party_id == %d", party];

	if (maxWnomSession == 81)	// let's try some special cases for the party switchers Pena and Hopson and Ritter
		[predicateString appendString:@" AND self.legislator.legislatorID != 50000 AND self.legislator.legislatorID != 49745 AND self.legislator.legislatorID != 25363"];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString]; 
	/*_____________________*/
	
	NSExpression *ex = [NSExpression expressionForFunction:@"average:" arguments:
						[NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"wnomAdj"]]];
	NSExpressionDescription *edAvg = [[NSExpressionDescription alloc] init];
	[edAvg setName:@"averagePartisanIndex"];
	[edAvg setExpression:ex];
	[edAvg setExpressionResultType:NSFloatAttributeType];
	
	ex = [NSExpression expressionForFunction:@"max:" arguments:
		  [NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"wnomAdj"]]];
	NSExpressionDescription *edMax = [[NSExpressionDescription alloc] init];
	[edMax setName:@"maxPartisanIndex"];
	[edMax setExpression:ex];
	[edMax setExpressionResultType:NSFloatAttributeType];
	
	ex = [NSExpression expressionForFunction:@"min:" arguments:
		  [NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"wnomAdj"]]];
	NSExpressionDescription *edMin = [[NSExpressionDescription alloc] init];
	[edMin setName:@"minPartisanIndex"];
	[edMin setExpression:ex];
	[edMin setExpressionResultType:NSFloatAttributeType];
	
	/*_____________________*/
	
	NSFetchRequest *request = [WnomObj fetchRequest];
	[request setPredicate:predicate];
	[request setPropertiesToFetch:[NSArray arrayWithObjects:edAvg, edMax, edMin, nil]];
	[request setResultType:NSDictionaryResultType];
	[edAvg release], [edMax release], [edMin release];
	
	NSArray *objects = [WnomObj objectsWithFetchRequest:request];
	if (IsEmpty(objects)) {
		debug_NSLog(@"PartisanIndexStats Error while fetching Legislators");
	}
	else {
		NSNumber *avgPartisanIndex = [[objects objectAtIndex:0] valueForKey:@"averagePartisanIndex"];
		NSNumber *maxPartisanIndex = [[objects objectAtIndex:0] valueForKey:@"maxPartisanIndex"];
		NSNumber *minPartisanIndex = [[objects objectAtIndex:0] valueForKey:@"minPartisanIndex"];
		debug_NSLog(@"Partisanship for Chamber (%d) Party (%d): min=%@ max=%@ avg=%@", 
					chamber, party, minPartisanIndex, maxPartisanIndex, avgPartisanIndex);
		return [NSArray arrayWithObjects:avgPartisanIndex, maxPartisanIndex, minPartisanIndex, nil];
	}
	
	return nil;
}

#pragma mark -
#pragma mark Statistics for Historical Chart

#define	WNOMAGGREGATES_KEY	@"WnomAggregateObj"

/* This gathers our pre-calculated overall aggregate scores for parties and chambers, from JSON		
	We use this for our red/blue lines in our historical partisanship chart.*/
- (NSArray *) historyForParty:(NSInteger)party Chamber:(NSInteger)chamber {
	NSError *error = nil;
	
	//TODO: right now the aggregates are pulled only from the app bundle, consider allowing for network updates
	NSString *filePath = [[NSBundle mainBundle] pathForResource:WNOMAGGREGATES_KEY ofType:@"json"];
	NSString *jsonString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
	if (error)
		NSLog(@"Error parsing WnomAggregateObj data file: %@; [path: %@", [error localizedDescription], filePath);
	if (jsonString && [jsonString length])
	{
		NSArray *jsonArray = [jsonString objectFromJSONString];
		NSArray *chamberArray = [jsonArray findAllWhereKeyPath:@"chamber" equals:[NSNumber numberWithInt:chamber]];
		if (chamberArray) {
			NSArray *partyArray = [chamberArray findAllWhereKeyPath:@"party" equals:[NSNumber numberWithInt:party]];
			return partyArray;
		}
	}
		
	return nil;
}

#pragma mark -
#pragma mark Chart Generation

- (NSDictionary *)partisanshipDataForLegislatorID:(NSNumber*)legislatorID {
	if (!legislatorID)
		return nil;
	
	LegislatorObj *legislator = [LegislatorObj objectWithPrimaryKeyValue:legislatorID];
	if (!legislator)
		return nil;
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"session" ascending:YES];
	NSArray *descriptors = [[NSArray alloc] initWithObjects:sortDescriptor,nil];
	NSArray *sortedScores = [[legislator.wnomScores allObjects] sortedArrayUsingDescriptors:descriptors];
	[sortDescriptor release];
	[descriptors release];
	NSInteger countOfScores = [legislator.wnomScores count];
	
	
	NSInteger chamber = [legislator.legtype integerValue];
	NSArray *democHistory = [self historyForParty:DEMOCRAT Chamber:chamber];
	NSArray *repubHistory = [self historyForParty:REPUBLICAN Chamber:chamber];
		
	NSUInteger i;
	
	NSMutableDictionary *results = [NSMutableDictionary dictionaryWithCapacity:3];
	NSMutableArray *repubScores = [[NSMutableArray alloc] init];
	NSMutableArray *demScores = [[NSMutableArray alloc] init];
	NSMutableArray *memberScores = [[NSMutableArray alloc] init];
	NSMutableArray *dates = [[NSMutableArray alloc] init];
	
	for ( i = 0; i < countOfScores ; i++) {
		
		WnomObj *wnomObj = [sortedScores objectAtIndex:i];
		NSDate *date = [NSDate dateFromString:[[wnomObj year] stringValue] withFormat:@"yyyy"];
		NSNumber *democY = [[democHistory findWhereKeyPath:@"session" equals:wnomObj.session] objectForKey:@"wnom"];
		NSNumber *repubY = [[repubHistory findWhereKeyPath:@"session" equals:wnomObj.session] objectForKey:@"wnom"];
		if (!democY)
			democY = [NSNumber numberWithFloat:0.0f];
		if (!repubY)
			repubY = [NSNumber numberWithFloat:0.0f];
		
		[repubScores addObject:repubY];
		[demScores addObject:democY];
		[dates addObject:date];

		CGFloat legVal = [[wnomObj wnomAdj] floatValue];
		if (legVal != 0.0f)
			[memberScores addObject:[wnomObj wnomAdj]];
		else
			[memberScores addObject:[NSNumber numberWithFloat:CGFLOAT_MIN]];
	}
		
	[results setObject:repubScores forKey:@"repub"];
	[results setObject:demScores forKey:@"democ"];
	[results setObject:memberScores forKey:@"member"];
	[results setObject:dates forKey:@"time"];
	[repubScores release];
	[demScores release];
	[memberScores release];
	[dates release];
	
	return results;
	
}

@end
