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
#import "UIColor-Expanded.h"
#import "TexLegeTheme.h"
#import "TexLegeCoreDataUtils.h"

@interface PartisanIndexStats (Private)

- (NSArray *) aggregatePartisanIndexForChamber:(NSInteger)chamber andPartyID:(NSInteger)party;

@end

@implementation PartisanIndexStats

@synthesize managedObjectContext, chartTemplate;

SYNTHESIZE_SINGLETON_FOR_CLASS(PartisanIndexStats);

// setup the data collection
- (id)init {
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
	self.managedObjectContext = nil;	// I THINK THIS IS CORRECT, SINCE WE'VE SYNTHESIZED IT AS RETAIN...
	if (m_partisanIndexAggregates) [m_partisanIndexAggregates release], m_partisanIndexAggregates = nil;
	
	self.chartTemplate = nil;
	
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
				NSArray *aggregatesArray = [self aggregatePartisanIndexForChamber:chamber andPartyID:party];
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
		}
		//debug_NSLog(@"Index Aggregates: %@", [tempAggregates description]);			
		m_partisanIndexAggregates = [[NSDictionary dictionaryWithDictionary:tempAggregates] retain];
	}
	
	return m_partisanIndexAggregates;
}

- (NSNumber *) minPartisanIndexUsingLegislator:(LegislatorObj *)legislator {
	return [self.partisanIndexAggregates objectForKey:
			[NSString stringWithFormat:@"MinC%d+P0", [legislator.legtype integerValue]]];
};

- (NSNumber *) maxPartisanIndexUsingLegislator:(LegislatorObj *)legislator {
	return [self.partisanIndexAggregates objectForKey:
			[NSString stringWithFormat:@"MaxC%d+P0", [legislator.legtype integerValue]]];
};

- (NSNumber *) overallPartisanIndexUsingLegislator:(LegislatorObj *)legislator {
	return [self.partisanIndexAggregates objectForKey:
			[NSString stringWithFormat:@"AvgC%d+P0", [legislator.legtype integerValue]]];
};


- (NSNumber *) partyPartisanIndexUsingLegislator:(LegislatorObj *)legislator {
	return [self.partisanIndexAggregates objectForKey:
			[NSString stringWithFormat:@"AvgC%d+P%d", [legislator.legtype integerValue], [legislator.party_id integerValue]]];
};


#pragma mark -
#pragma mark Partisan Indexing

- (NSArray *) aggregatePartisanIndexForChamber:(NSInteger)chamber andPartyID:(NSInteger)party {
	
	if (chamber == BOTH_CHAMBERS) {
		debug_NSLog(@"aggregatePartisanIndexForChamber: ... cannot be BOTH chambers");
		return nil;
	}
	
	NSString *predicateString = nil;
	if (party > kUnknownParty)
		predicateString = [NSString stringWithFormat:@"legtype == %d AND party_id == %d", chamber, party];
	else
		predicateString = [NSString stringWithFormat:@"legtype == %d", chamber];	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString]; 
	/*_____________________*/
	
	NSExpression *ex = [NSExpression expressionForFunction:@"average:" arguments:
						[NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"partisan_index"]]];
	NSExpressionDescription *edAvg = [[NSExpressionDescription alloc] init];
	[edAvg setName:@"averagePartisanIndex"];
	[edAvg setExpression:ex];
	[edAvg setExpressionResultType:NSFloatAttributeType];
	
	ex = [NSExpression expressionForFunction:@"max:" arguments:
		  [NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"partisan_index"]]];
	NSExpressionDescription *edMax = [[NSExpressionDescription alloc] init];
	[edMax setName:@"maxPartisanIndex"];
	[edMax setExpression:ex];
	[edMax setExpressionResultType:NSFloatAttributeType];
	
	ex = [NSExpression expressionForFunction:@"min:" arguments:
		  [NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"partisan_index"]]];
	NSExpressionDescription *edMin = [[NSExpressionDescription alloc] init];
	[edMin setName:@"minPartisanIndex"];
	[edMin setExpression:ex];
	[edMin setExpressionResultType:NSFloatAttributeType];
	
	/*_____________________*/
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setPredicate:predicate];
	[request setPropertiesToFetch:[NSArray arrayWithObjects:edAvg, edMax, edMin, nil]];
	[request setResultType:NSDictionaryResultType];
	[edAvg release], [edMax release], [edMin release];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LegislatorObj" 
											  inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	NSError *error;
	NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];
	[request release];
	if (objects == nil) {
		// Handle the error.
		debug_NSLog(@"Error");
	}
	else {
		if ([objects count] > 0) {
			NSNumber *avgPartisanIndex = [[objects objectAtIndex:0] valueForKey:@"averagePartisanIndex"];
			NSNumber *maxPartisanIndex = [[objects objectAtIndex:0] valueForKey:@"maxPartisanIndex"];
			NSNumber *minPartisanIndex = [[objects objectAtIndex:0] valueForKey:@"minPartisanIndex"];
			//return [avgPartisanIndex floatValue];
			return [NSArray arrayWithObjects:avgPartisanIndex, maxPartisanIndex, minPartisanIndex, nil];
		}
	}
	
	return nil;
	
}

- (NSString *) partisanRankForLegislator:(LegislatorObj *)legislator onlyParty:(BOOL)inParty {
	
	NSArray *legislators = nil;
	
	if (inParty)
		legislators = [TexLegeCoreDataUtils allLegislatorsSortedByPartisanshipFromChamber:[legislator.legtype integerValue] 
																			   andPartyID:[legislator.party_id integerValue] 
																				  context:self.managedObjectContext];
	else
		legislators = [TexLegeCoreDataUtils allLegislatorsSortedByPartisanshipFromChamber:[legislator.legtype integerValue] 
																			   andPartyID:kUnknownParty 
																				  context:self.managedObjectContext];
	if (legislators) {
		NSInteger rank = [legislators indexOfObject:legislator] + 1;
		NSInteger count = [legislators count];
		return [NSString stringWithFormat:@"%d out of %d", rank, count];	
	}
	else {
		return nil;
	}
}


- (NSDictionary *) historyForParty:(NSInteger)party Chamber:(NSInteger)chamber {
	NSDictionary *historyDict = nil;
	
	if (party == REPUBLICAN && chamber == HOUSE)
		historyDict = [NSDictionary dictionaryWithObjectsAndKeys:
					   [NSNumber numberWithFloat:0.54409], [NSNumber numberWithInteger:72],
					   [NSNumber numberWithFloat:0.559875531], [NSNumber numberWithInteger:73],
					   [NSNumber numberWithFloat:0.552640372], [NSNumber numberWithInteger:74],
					   [NSNumber numberWithFloat:0.621388023], [NSNumber numberWithInteger:75],
					   [NSNumber numberWithFloat:0.629700791], [NSNumber numberWithInteger:76],
					   [NSNumber numberWithFloat:0.621778609], [NSNumber numberWithInteger:77],
					   [NSNumber numberWithFloat:0.621042716], [NSNumber numberWithInteger:78],
					   [NSNumber numberWithFloat:0.617089494], [NSNumber numberWithInteger:79],
					   [NSNumber numberWithFloat:0.636998902], [NSNumber numberWithInteger:80],
					   [NSNumber numberWithFloat:0.734943024], [NSNumber numberWithInteger:81],nil];
	else if (party == DEMOCRAT && chamber == HOUSE)
		historyDict = [NSDictionary dictionaryWithObjectsAndKeys:
					   [NSNumber numberWithFloat:-0.42222], [NSNumber numberWithInteger:72],
					   [NSNumber numberWithFloat:-0.449964135], [NSNumber numberWithInteger:73],
					   [NSNumber numberWithFloat:-0.445684078], [NSNumber numberWithInteger:74],
					   [NSNumber numberWithFloat:-0.536115388], [NSNumber numberWithInteger:75],
					   [NSNumber numberWithFloat:-0.581599285], [NSNumber numberWithInteger:76],
					   [NSNumber numberWithFloat:-0.585928296], [NSNumber numberWithInteger:77],
					   [NSNumber numberWithFloat:-0.644611479], [NSNumber numberWithInteger:78],
					   [NSNumber numberWithFloat:-0.695038928], [NSNumber numberWithInteger:79],
					   [NSNumber numberWithFloat:-0.689908867], [NSNumber numberWithInteger:80],
					   [NSNumber numberWithFloat:-0.816011438], [NSNumber numberWithInteger:81],nil];
	else if (party == REPUBLICAN && chamber == SENATE)
		historyDict = [NSDictionary dictionaryWithObjectsAndKeys:
					   [NSNumber numberWithFloat:0.4383], [NSNumber numberWithInteger:76],
					   [NSNumber numberWithFloat:0.607931], [NSNumber numberWithInteger:77],
					   [NSNumber numberWithFloat:0.799931], [NSNumber numberWithInteger:78],
					   [NSNumber numberWithFloat:0.722995], [NSNumber numberWithInteger:79],
					   [NSNumber numberWithFloat:0.386157], [NSNumber numberWithInteger:80],
					   [NSNumber numberWithFloat:0.599742], [NSNumber numberWithInteger:81],nil];
	else if (party == DEMOCRAT && chamber == SENATE)
		historyDict = [NSDictionary dictionaryWithObjectsAndKeys:
					   [NSNumber numberWithFloat:-0.4161], [NSNumber numberWithInteger:76],
					   [NSNumber numberWithFloat:-0.5796], [NSNumber numberWithInteger:77],
					   [NSNumber numberWithFloat:-0.833222], [NSNumber numberWithInteger:78],
					   [NSNumber numberWithFloat:-0.656078], [NSNumber numberWithInteger:79],
					   [NSNumber numberWithFloat:-0.688802], [NSNumber numberWithInteger:80],
					   [NSNumber numberWithFloat:-0.69183], [NSNumber numberWithInteger:81],nil];
	
	return historyDict;
}

#pragma mark -
#pragma mark Chart Generation

- (NSString *)chartTemplate {
	if (!chartTemplate) {
		/*
		 NSString *thePath = [[NSBundle mainBundle] pathForResource:@"TexLegeStrings" ofType:@"plist"];
		 NSDictionary *textDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
		 if ([UtilityMethods isIPadDevice])
		 chartTemplate = [[textDict objectForKey:@"ChartTemplate"] retain];
		 else
		 chartTemplate = [[textDict objectForKey:@"ChartTemplateSmall"] retain];
		 */
		NSString *file = nil;
		if ([UtilityMethods isIPadDevice])
			file = @"ChartsTemplate~ipad";
		else
			file = @"ChartsTemplate~iphone";
		
		NSString *thePath = [[NSBundle mainBundle] pathForResource:file ofType:@"htm"];
		NSError *error;
		chartTemplate = [[NSString stringWithContentsOfFile:thePath encoding:NSUTF8StringEncoding error:&error] retain];
	}
	return chartTemplate;
}

- (NSDictionary *)chartDataForLegislator:(LegislatorObj*)legislator {	
	if (!legislator)
		return nil;
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"session" ascending:YES];
	NSArray *descriptors = [[NSArray alloc] initWithObjects:sortDescriptor,nil];
	NSArray *sortedScores = [[legislator.wnomScores allObjects] sortedArrayUsingDescriptors:descriptors];
	[sortDescriptor release];
	[descriptors release];
	NSInteger countOfScores = [legislator.wnomScores count];
	
	
	NSInteger chamber = [legislator.legtype integerValue];
	NSDictionary *democDict = [self historyForParty:DEMOCRAT Chamber:chamber];
	NSDictionary *repubDict = [self historyForParty:REPUBLICAN Chamber:chamber];
	
	NSMutableString *repubData = [[NSMutableString alloc] initWithString:@"["];
	NSMutableString *democData = [[NSMutableString alloc] initWithString:@"["];
	NSMutableString *memberData = [[NSMutableString alloc] initWithString:@"["];
	//NSMutableString *timeData = [[NSMutableString alloc] initWithString:@"["];
	
	CGFloat min = -0.85f, max = 0.85f;

	
	NSString *firstYear = nil;
	NSUInteger i;
	
	for ( i = 0; i < countOfScores ; i++) {
		//BOOL showLabel = ((i % 2 == 0) || countOfScores < 3);
		
		WnomObj *wnomObj = [sortedScores objectAtIndex:i];
		
		id democY = [democDict objectForKey:[wnomObj session]];
		id repubY = [repubDict objectForKey:[wnomObj session]];
		
		[repubData appendString:[repubY stringValue]];
		[democData appendString:[democY stringValue]];
		
		//[timeData appendString:[[wnomObj year] stringValue]];
		if (i==0)
			firstYear = [[wnomObj year] stringValue];
		
		CGFloat legVal = [[wnomObj wnomAdj] floatValue];
		if (legVal > max && legVal > [repubY floatValue])
			max = legVal;
		if (legVal < min && legVal < [democY floatValue])
			min = legVal;
		
		if (legVal != 0.0f)
			[memberData appendString:[[wnomObj wnomAdj] stringValue]];
		else
			[memberData appendString:@"null"];
		
		if (i<(countOfScores-1)) {
			[repubData appendString:@", "];
			[democData appendString:@", "];
			[memberData appendString:@", "];
			//[timeData appendString:@", "];
		}
		
	}
	[repubData appendString:@"]"];
	[democData appendString:@"]"];
	[memberData appendString:@"]"];
	//[timeData appendString:@"]"];
	
	NSString *timeData = @"";
	if (firstYear) {
		timeData =  firstYear;
	}
	
	
	NSString *minmax = @"min: -0.85, max: 0.85";
	if (min < -1.04f || max > 1.04f)
		minmax = [NSString stringWithFormat:@"min: %f, max: %f", min, max];
	
	//debug_NSLog(@"minmax = %@", minmax);
	
	NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:	
							  repubData, @"repub", 
							  democData, @"democ", 
							  memberData, @"member", 
							  timeData, @"time",
							  minmax, @"minmax",
							  nil];
	
	[repubData release], [democData release], [memberData release];
	//	, [timeData release];
	
	return dataDict;
	
}


- (NSString *)partisanChartForLegislator:(LegislatorObj*)legislator width:(NSString*)width {
	if (!legislator)
		return nil;
	
	NSUInteger matches = 0;
	NSMutableString *content = [self.chartTemplate mutableCopy];
	
	NSString *legName = [legislator lastname];
	
	matches += [content replaceOccurrencesOfString:@"LEGISLATOR" withString:legName
										   options:NSLiteralSearch range:NSMakeRange(0, [content length])];
	
	matches += [content replaceOccurrencesOfString:@"CHAMBER" withString:[legislator chamberName] 
										   options:NSLiteralSearch range:NSMakeRange(0, [content length])];
	
	NSDictionary *chartData = [self chartDataForLegislator:legislator];
	if (chartData) {
		
		matches += [content replaceOccurrencesOfString:@"DATA_DEMOC" withString:[chartData objectForKey:@"democ"] 
											   options:NSLiteralSearch range:NSMakeRange(0, [content length])];
		matches += [content replaceOccurrencesOfString:@"DATA_REPUB" withString:[chartData objectForKey:@"repub"] 
											   options:NSLiteralSearch range:NSMakeRange(0, [content length])];
		matches += [content replaceOccurrencesOfString:@"DATA_MEMBER" withString:[chartData objectForKey:@"member"] 
											   options:NSLiteralSearch range:NSMakeRange(0, [content length])];
		matches += [content replaceOccurrencesOfString:@"DATA_TIME" withString:[chartData objectForKey:@"time"] 
											   options:NSLiteralSearch range:NSMakeRange(0, [content length])];
		matches += [content replaceOccurrencesOfString:@"DATA_MINMAX" withString:[chartData objectForKey:@"minmax"]
											   options:NSLiteralSearch range:NSMakeRange(0, [content length])];
		
		NSString *style = @"";
		NSString *viewport = @"";
		if ([UtilityMethods isIPadDevice]) {
			//style = @"width: 500px; height: 180px; margin: 0 auto  background-color: transparent";
			style = [NSString stringWithFormat:@"width: %@; height: 180px; auto", width];
			debug_NSLog(@"%@", style);
			
		}
		else {
			//style = @"width: 320px; height: 192px; margin: 0 auto";
			//style = @"width: 100%; height: 192px;";
			//style = @"height: 180px; auto";
			style = [NSString stringWithFormat:@"width: %@; height: 180px; auto", width];
			viewport = @"width = device-width";
			
			//viewport = @"initial-scale = 1";
		}
		matches += [content replaceOccurrencesOfString:@"VIEWPORT_SETTING" withString:viewport options:NSLiteralSearch range:NSMakeRange(0, [content length])];
		matches += [content replaceOccurrencesOfString:@"CONTENT_STYLE" withString:style options:NSLiteralSearch range:NSMakeRange(0, [content length])];
	}
	//debug_NSLog(@"Partisan chart template, found/replaced %d matches", matches);
	return [content autorelease];
}

@end
