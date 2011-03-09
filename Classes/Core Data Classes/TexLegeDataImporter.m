//
//  TexLegeDataImporter.m
//  TexLege
//
//  Created by Gregory Combs on 9/15/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TexLegeDataImporter.h"
#import "TexLegeCoreDataUtils.h"
#import "TexLegeDataObjectProtocol.h"
#import "UtilityMethods.h"
#import "CommitteeObj.h"
#import "LegislatorObj.h"
#import "TexLegeReachability.h"
#import "TexLegeAppDelegate.h"

@interface TexLegeDataImporter (Private)

- (IBAction)saveAction:(id)sender;

@end

@implementation TexLegeDataImporter

- (NSManagedObjectContext *)managedObjectContext {
	return [LegislatorObj managedObjectContext];
}

- (id) init {
	if (self=[super init]) {
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

/*
 - (void)fixLegislators {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Legislators" ofType:@"plist"];
	assert(path);
	
	NSMutableArray *oldLegeArray = [NSMutableArray arrayWithContentsOfFile:path];
	
	for (NSDictionary *oldLegDict in oldLegeArray) {
		NSNumber *oldID = [oldLegDict objectForKey:@"legislatorID"];
		
		LegislatorObj *newLeg = [TexLegeCoreDataUtils legislatorWithLegislatorID:oldID withContext:self.managedObjectContext];
		NSString *cap_phone = [oldLegDict objectForKey:@"cap_phone"];
		if (cap_phone)
			newLeg.cap_phone = cap_phone;
	}
	
}
*/

- (void)importAllDataObjects {
	debug_NSLog(@"DataImporter: IMPORTING ALL CORE DATA OBJECTS");
	
	[self importObjectsWithEntityName:@"LegislatorObj"];
//#warning this is hacky
//	[self fixLegislators];
	
	[self importObjectsWithEntityName:@"WnomObj"];

	[self importObjectsWithEntityName:@"CommitteeObj"];
	[self importObjectsWithEntityName:@"CommitteePositionObj"];

	[self importObjectsWithEntityName:@"StafferObj"];

	[self importObjectsWithEntityName:@"LinkObj"];

	[self importObjectsWithEntityName:@"DistrictOfficeObj"];
#if NEEDS_TO_PARSE_KMLMAPS == 0
	[self importObjectsWithEntityName:@"DistrictMapObj"];
#endif
}


- (void)importObjectsWithEntityName:(NSString *)entityName {
	NSString *importPath = [[NSBundle mainBundle] pathForResource:entityName ofType:@"plist"];
	NSArray *importPlist = [NSArray arrayWithContentsOfFile:importPath];
	
	if (!importPlist || ![importPlist count]) {
		debug_NSLog(@"DataImporter: %@ plist not found in bundle, looking in documents directory", entityName);
		NSString *outFile = [NSString stringWithFormat:@"%@.plist", entityName];
		importPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:outFile];
		importPlist = [NSArray arrayWithContentsOfFile:importPath];
		
		if (!importPlist || ![importPlist count]) {
			debug_NSLog(@"DataImporter: ERROR ... couldn't not find data to import: %@", importPath);
			return;
		}
	}
	
	debug_NSLog(@"DataImporter: IMPORTING %@ OBJECTS FROM: %@", entityName, importPath);
	
	[TexLegeCoreDataUtils deleteAllObjectsInEntityNamed:entityName];

	NSInteger importCount = 0;
	for (NSDictionary * aDictionary in importPlist) {
		id<TexLegeDataObjectProtocol> object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
		
		if (object) {
			[object importFromDictionary:aDictionary];
			importCount++;
			if ([(id)object isKindOfClass:[CommitteeObj class]]) {
				//CommitteeObj *committee = object;
				//debug_NSLog(@"%@ %@",[committee committeeNameInitial], committee.committeeId); 
			}
		}
	}
	debug_NSLog(@"DataImporter: IMPORTED %d %@ OBJECTS", importCount, entityName);

	[self saveAction:nil];	
	
}

- (IBAction)saveAction:(id)sender{
	
	@try {
		NSError *error = nil;
		if (self.managedObjectContext != nil) {
			if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
				debug_NSLog(@"DataImporter:saveAction - unresolved error %@, %@", error, [error userInfo]);
			} 
		}
	}
	@catch (NSException * e) {
		debug_NSLog(@"Failure in DataImporter:saveAction, name=%@ reason=%@", e.name, e.reason);
	}
}


@end
