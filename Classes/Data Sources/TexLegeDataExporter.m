//
//  TexLegeDataExporter.m
//  TexLege
//
//  Created by Gregory Combs on 8/31/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TexLegeDataExporter.h"
#import "UtilityMethods.h"
#import "TexLegeCoreDataUtils.h"
#import "TexLegeDataObjectProtocol.h"
#import "TexLegeAppDelegate.h"

#import "JSON.h"
#import "LegislatorObj.h"
#import "NSString_Extensions.h"

@implementation TexLegeDataExporter

- (void) dealloc {
	[super dealloc];
}

- (void)exportAllDataObjectsWithJSON:(BOOL)doJSON force:(BOOL)force {
	debug_NSLog(@"DataExporter: EXPORTING ALL CORE DATA OBJECTS");
	
	[self exportObjectsWithEntityName:@"LegislatorObj" JSON:doJSON force:force];
	[self exportObjectsWithEntityName:@"CommitteeObj" JSON:doJSON force:force];
	[self exportObjectsWithEntityName:@"CommitteePositionObj" JSON:doJSON force:force];
	[self exportObjectsWithEntityName:@"WnomObj" JSON:doJSON force:force];
	[self exportObjectsWithEntityName:@"WnomObj" JSON:doJSON force:force];
	[self exportObjectsWithEntityName:@"StafferObj" JSON:doJSON force:force];
	[self exportObjectsWithEntityName:@"DistrictOfficeObj" JSON:doJSON force:force];
	[self exportObjectsWithEntityName:@"DistrictMapObj" JSON:doJSON force:force];			// do a plist or json
	[self exportObjectsWithEntityName:@"LinkObj" JSON:doJSON force:force];

}
- (void)exportAllDataObjects {
	[self exportAllDataObjectsWithJSON:NO force:YES];
}

// I don't think this really helps ... it's not magically on a seperate thread, as far as I can tell.  So it blocks to UI, doesn't it?
- (void)writeFileInBackground:(id)dictObject {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (dictObject && [dictObject isKindOfClass:[NSDictionary class]]) {
		id fileData = [dictObject objectForKey:@"data"];
		NSString *filePath = [dictObject objectForKey:@"path"];
		
		if (fileData && [fileData isKindOfClass:[NSString class]]) {
			if (fileData && [fileData length]) {
				NSError *error = nil;
				[fileData writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
				if (error)
					NSLog(@"DataExporter:exportObjectsWithEntityName:%@ - export to file was unsuccessful; error: %@", 
						  filePath, [error localizedDescription]);
			}
		}
		else if (fileData && [fileData isKindOfClass:[NSArray class]]) {
			NSMutableArray *archivedObjects = [[NSMutableArray alloc] initWithCapacity:[fileData count]];
			for (id<TexLegeDataObjectProtocol> object in fileData) {
				[archivedObjects addObject:[object exportToDictionary]];
			}
			if (![archivedObjects writeToFile:filePath atomically:YES]) {
				NSLog(@"DataExporter:exportObjectsWithEntityName:%@ - export to file was unsuccessful", filePath);
			}
			[archivedObjects release];
		}
	}
	[pool drain];
}

- (void)exportObjectsWithEntityName:(NSString *)entityName JSON:(BOOL)doJSON force:(BOOL)force{
	
	//if ([entityName isEqualToString:@"DistrictMapObj"])
	//	doJSON = NO;
	
	NSString *outFile = nil;
	if (!doJSON)
		outFile = [NSString stringWithFormat:@"%@.plist", entityName];
	else {
		if (!outFile) {
			outFile = [NSString stringWithFormat:@"%@.builtInExport.json", entityName];
		}
	}

	NSString *outPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:outFile];
		
	if (force || (![[NSFileManager defaultManager] fileExistsAtPath:outPath])) {
		debug_NSLog(@"DataExporter: EXPORTING %@ OBJECTS TO: %@", entityName, outPath);
		NSArray *objArray = [NSClassFromString(entityName) allObjects];

		NSDictionary *outputDict = nil;
		if (!doJSON)
			outputDict = [NSDictionary dictionaryWithObjectsAndKeys:objArray, @"data", outPath, @"path", nil];
		else {
			NSString *jsonString = [objArray JSONRepresentation];
			if (jsonString && [jsonString length])
				outputDict = [NSDictionary dictionaryWithObjectsAndKeys:jsonString, @"data", outPath, @"path", nil];
		}
		if (outputDict)
			[self performSelectorInBackground:@selector(writeFileInBackground:) withObject:outputDict];
	}
}


#if 0

- (void)hackyLegislatorIDs {
	NSString *entityName = @"LegislatorObj";
	
	NSString *outFile = [NSString stringWithFormat:@"%@.plist", entityName];
	NSString *outPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:outFile];
	
	debug_NSLog(@"DataExporter: EXPORTING %@ OBJECTS TO: %@", entityName, outPath);
	
	NSArray *objArray = [TexLegeCoreDataUtils allObjectsInEntityNamed:entityName];
	
	NSString *inFile = [NSString stringWithFormat:@"hacky.plist"];
	NSString *inPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:inFile];

	NSArray *plistArray = [NSArray arrayWithContentsOfFile:inPath];
	
	NSMutableArray *archivedObjects = [[NSMutableArray alloc] initWithCapacity:[objArray count]];
	for (LegislatorObj * legislator in objArray) {
		NSDictionary *stockDict = [legislator exportToDictionary];
		
		NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:stockDict];
		
		NSString *transDataContributorID = nil;
		for (NSDictionary *tempDict in plistArray) {
			if ([legislator.legislatorID isEqualToNumber:[tempDict objectForKey:@"oldID"]]) {
				transDataContributorID = [tempDict objectForKey:@"newID"];
				break;
			}
		}
		if (transDataContributorID)
			[newDict setObject:transDataContributorID forKey:@"transDataContributorID"];
		
		
		[archivedObjects addObject:newDict];
		[newDict release];
		
	}
	if (![archivedObjects writeToFile:outPath atomically:YES])
		debug_NSLog(@"DataExporter:exportObjectsWithEntityName:%@ - export to file was unsuccessful", entityName);
	[archivedObjects release];
	
	[self exportObjectsWithEntityName:@"CommitteeObj"];
	[self exportObjectsWithEntityName:@"CommitteePositionObj"];
	[self exportObjectsWithEntityName:@"WnomObj"];
	[self exportObjectsWithEntityName:@"StafferObj"];
	[self exportObjectsWithEntityName:@"DistrictOfficeObj"];
	[self exportObjectsWithEntityName:@"DistrictMapObj"];
	[self exportObjectsWithEntityName:@"LinkObj"];
	
}

- (void)hackyLegislatorIDs {
	NSArray *legislators = [LegislatorObj allObjects];
	
	static const NSString *urlRoot = @"http://transparencydata.com/api/1.0/entities.json?apikey=350284d0c6af453b9b56f6c1c7fea1f9&search=";

	NSMutableArray *list = [NSMutableArray array];
	
	for (LegislatorObj *legislator in legislators) {
		NSString *chamberString = [legislator.legtype integerValue] == HOUSE ? @"state:lower" : @"state:upper";
		NSString *nameSearch = nil;
		if ([legislator.lastname hasSuffix:@"Toureilles"]) {
			nameSearch = @"Toureilles";
		}
		else if ([legislator.lastname hasSuffix:@"Keffer"] && [legislator.firstname hasPrefix:@"Jim"]) {
			nameSearch = @"James+Keffer";
		}
		else if ([legislator.lastname hasSuffix:@"Moody"]) {
			nameSearch = @"Joseph+Moody";
		}
		else {
			nameSearch = [NSString stringWithFormat:@"%@ %@", legislator.firstname, legislator.lastname];
			nameSearch = [nameSearch stringByReplacingOccurrencesOfString:@" " withString:@"+"];
		}
		NSData *stuff = [nameSearch dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		NSString *newStuff = [[[NSString alloc] initWithData:stuff encoding:NSASCIIStringEncoding] autorelease];			
			
		NSString *urlString = [NSString stringWithFormat:@"%@%@", urlRoot, newStuff];
		NSURL *url = [NSURL URLWithString:urlString];
		NSError *error = nil;
		NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
		NSArray *tempArray = [jsonString JSONValue];
		NSDictionary *found = nil;
		for (NSDictionary *dict in tempArray) {
			NSString *state = [dict objectForKey:@"state"];	// hope it's TX
			NSString *chamber = [dict objectForKey:@"seat"];	// hope it's "state:lower / state:upper"
			NSString *type = [dict objectForKey:@"type"];
			BOOL typeYES = (type && [type isKindOfClass:[NSString class]] && [type isEqualToString:@"politician"]);
			BOOL stateYES = (state && [state isKindOfClass:[NSString class]] && [state isEqualToString:@"TX"]);
			//BOOL chamberYES = (chamber && [chamber isKindOfClass:[NSString class]] && [chamber isEqualToString:chamberString]);
			

			if (typeYES && stateYES /*&& chamberYES*/) {
			
				found = dict;
				
				NSDictionary *newDict = [[NSDictionary alloc] initWithObjectsAndKeys:
										 [found objectForKey:@"name"], @"newName",
										 [legislator fullNameLastFirst], @"oldName",
										 [found objectForKey:@"id"], @"newID",
										 legislator.legislatorID, @"oldID",
										 nil];
										 
				[list addObject:newDict];
				
				continue;	// this should be a break but it helps us by dropping in multiple entries for ambiguous search results
			}
		}
		if (!found) {
			if ([legislator.lastname isEqualToString:@"Birdwell"]) {
					//http://transparencydata.com/api/1.0/entities/id_lookup.json?apikey=350284d0c6af453b9b56f6c1c7fea1f9&namespace=urn:nimsp:recipient&id=145549
			}
			
			debug_NSLog(@"hacky didn't find one for %@", urlString);
		}
		
	}
	
	NSString *outFile = [NSString stringWithFormat:@"hacky.plist"];
	NSString *outPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:outFile];
	if (![list writeToFile:outPath atomically:YES])
		debug_NSLog(@"DataExporter:hacky export to file was unsuccessful");

}
#endif


@end
