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

@implementation TexLegeDataExporter
@synthesize managedObjectContext;

- (id) initWithManagedObjectContext:(NSManagedObjectContext*)newContext {
	if (self=[super init]) {
		self.managedObjectContext = newContext;			
	}
	return self;
}

- (void) dealloc {
	self.managedObjectContext = nil;
	[super dealloc];
}

- (void)exportAllDataObjects {
	debug_NSLog(@"DataExporter: EXPORTING ALL CORE DATA OBJECTS");
	
	[self exportObjectsWithEntityName:@"LegislatorObj"];
	[self exportObjectsWithEntityName:@"CommitteeObj"];
	[self exportObjectsWithEntityName:@"CommitteePositionObj"];
	[self exportObjectsWithEntityName:@"WnomObj"];
	[self exportObjectsWithEntityName:@"DistrictOfficeObj"];
	[self exportObjectsWithEntityName:@"DistrictMapObj"];
	[self exportObjectsWithEntityName:@"LinkObj"];

}

- (void)exportObjectsWithEntityName:(NSString *)entityName {
	NSString *outFile = [NSString stringWithFormat:@"%@.plist", entityName];
	NSString *outPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:outFile];

	debug_NSLog(@"DataExporter: EXPORTING %@ OBJECTS TO: %@", entityName, outPath);

	NSArray *objArray = [TexLegeCoreDataUtils allObjectsInEntityNamed:entityName context:self.managedObjectContext];

	NSMutableArray *archivedObjects = [[NSMutableArray alloc] initWithCapacity:[objArray count]];
	for (id<TexLegeDataObjectProtocol> object in objArray) {
		[archivedObjects addObject:[object exportToDictionary]];
	}
	if (![archivedObjects writeToFile:outPath atomically:YES])
			debug_NSLog(@"DataExporter:exportObjectsWithEntityName:%@ - export to file was unsuccessful", entityName);
	[archivedObjects release];
	
	
}

@end
