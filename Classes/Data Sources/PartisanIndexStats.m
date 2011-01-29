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
#import "NSDate+Helper.h"
#import "DataModelUpdateManager.h"
#import "JSON.h"

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
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(resetData:) name:@"DATAMODEL_UPDATED" object:nil];

		// initialize these
		[self partisanIndexAggregates];
		
	}
	return self;
}



- (void)dealloc {	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	self.managedObjectContext = nil;	// I THINK THIS IS CORRECT, SINCE WE'VE SYNTHESIZED IT AS RETAIN...
	if (m_partisanIndexAggregates) [m_partisanIndexAggregates release], m_partisanIndexAggregates = nil;
	
	self.chartTemplate = nil;
	
    [super dealloc];
}

- (NSNumber *) currentSessionYear {
	return [NSNumber numberWithInteger:[[NSDate date] year]];
	//return [NSNumber numberWithInteger:2009];
}

- (void)resetData:(NSNotificationCenter *)notification {
	if (m_partisanIndexAggregates) [m_partisanIndexAggregates release], m_partisanIndexAggregates = nil;
	[self partisanIndexAggregates];
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

#define	WNOMAGGREGATES_KEY	@"WnomAggregates"
- (NSDictionary *) loadAggregatesData {
	NSDictionary *aggregatesData = nil;
	
	DataModelUpdateManager *updater = [[DataModelUpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext];
	NSDictionary *dataCatalog = [updater getLocalDataModelCatalog];
	[updater release];
	
	NSString *dataFile = nil;
	if (dataCatalog) {
		NSDictionary *modelInfo = [dataCatalog objectForKey:WNOMAGGREGATES_KEY];
		if (modelInfo) {
			dataFile = [modelInfo objectForKey:@"URL"];
		}
	}
	if (!dataFile)
		dataFile = [NSString stringWithFormat:@"%@.json", WNOMAGGREGATES_KEY];
	
	NSString *filePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:dataFile];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;

	if (![fileManager fileExistsAtPath:filePath]) {
		NSString *defaultFilePath = [[NSBundle mainBundle] pathForResource:WNOMAGGREGATES_KEY ofType:@"json"];
		if (defaultFilePath) {
			[fileManager copyItemAtPath:defaultFilePath toPath:filePath error:&error];
			if (error)
				NSLog(@"Error copying WnomAggregates data file to user's directory: %@; [path: %@", [error localizedDescription], filePath);
		}
	}
	NSString *jsonString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
	if (error)
		NSLog(@"Error parsing WnomAggregates data file: %@; [path: %@", [error localizedDescription], filePath);
	if (jsonString && [jsonString length])
		aggregatesData = [jsonString JSONValue];

	return aggregatesData;
}

- (NSDictionary *) historyForParty:(NSInteger)party Chamber:(NSInteger)chamber {
	
	NSDictionary *aggregatesData = [self loadAggregatesData];
	if (!aggregatesData)
		return nil;
	
	NSString *key = [NSString stringWithFormat:@"%d_%d", chamber, party];
	NSDictionary *chamberPartyDict = [aggregatesData objectForKey:key];
	NSDictionary *historyDict = [chamberPartyDict objectForKey:WNOMAGGREGATES_KEY];

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
		
		id democY = [democDict objectForKey:[[wnomObj session] stringValue]];
		id repubY = [repubDict objectForKey:[[wnomObj session] stringValue]];
		if (!democY)
			democY = [NSNumber numberWithFloat:0.0f];
		if (!repubY)
			repubY = [NSNumber numberWithFloat:0.0f];
		
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
	
	NSMutableString *content = [self.chartTemplate mutableCopy];
	
	NSString *legName = [legislator lastname];
	
	[content replaceOccurrencesOfString:@"LEGISLATOR" withString:legName
										   options:NSLiteralSearch range:NSMakeRange(0, [content length])];
	
	[content replaceOccurrencesOfString:@"CHAMBER" withString:[legislator chamberName] 
										   options:NSLiteralSearch range:NSMakeRange(0, [content length])];
	
	NSDictionary *chartData = [self chartDataForLegislator:legislator];
	if (chartData) {
		
		[content replaceOccurrencesOfString:@"DATA_DEMOC" withString:[chartData objectForKey:@"democ"] 
											   options:NSLiteralSearch range:NSMakeRange(0, [content length])];
		[content replaceOccurrencesOfString:@"DATA_REPUB" withString:[chartData objectForKey:@"repub"] 
											   options:NSLiteralSearch range:NSMakeRange(0, [content length])];
		[content replaceOccurrencesOfString:@"DATA_MEMBER" withString:[chartData objectForKey:@"member"] 
											   options:NSLiteralSearch range:NSMakeRange(0, [content length])];
		[content replaceOccurrencesOfString:@"DATA_TIME" withString:[chartData objectForKey:@"time"] 
											   options:NSLiteralSearch range:NSMakeRange(0, [content length])];
		[content replaceOccurrencesOfString:@"DATA_MINMAX" withString:[chartData objectForKey:@"minmax"]
											   options:NSLiteralSearch range:NSMakeRange(0, [content length])];
		
		NSString *style = @"";
		NSString *viewport = @"";
		if ([UtilityMethods isIPadDevice]) {
//			style = [NSString stringWithFormat:@"width: %@; height: 180px; auto", width];
//			viewport = @"width = device-width";
			style = [NSString stringWithFormat:@"width: %@; height: 184px; auto", width];

		}
		else {
			style = @"height: 184px; auto";
			viewport = @"width = device-width";
			//style = [NSString stringWithFormat:@"width: %@; height: 180px; auto", width];
//			viewport = @"initial-scale = 1";
		}
		[content replaceOccurrencesOfString:@"VIEWPORT_SETTING" withString:viewport options:NSLiteralSearch range:NSMakeRange(0, [content length])];
		[content replaceOccurrencesOfString:@"CONTENT_STYLE" withString:style options:NSLiteralSearch range:NSMakeRange(0, [content length])];
	}
	
	return [content autorelease];
}

- (void) resetChartCache:(id)sender {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSError *error = nil;
	NSString *pathToDocs = [UtilityMethods applicationDocumentsDirectory];
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathToDocs error:&error];
	
	if (error) {
		debug_NSLog(@"Error reading documents directory for svg cache reset: %@", error);
	}
	if (files && [files count]) {
		for (NSString *file in files) {
			if ([file hasSuffix:@".land.svg"] || [file hasSuffix:@".port.svg"]) {
				NSString *filePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:file];
				
				[[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
				if (error) {
					debug_NSLog(@"Error deleting svg cache at path:%@ --- %@", filePath, error);
				}
			}
		}
	}	
	[pool drain];
}

- (BOOL) resetChartCacheIfNecessary {
	
	BOOL needsReset = [[NSUserDefaults standardUserDefaults] boolForKey:kResetChartCacheKey];
	
	if (needsReset) {
		[self performSelectorInBackground:@selector(resetChartCache:) withObject:nil]; 
	}
	
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kResetChartCacheKey];
	[[NSUserDefaults standardUserDefaults] synchronize];

	return needsReset;
}
@end
