//
//  TexLegeCoreDataUtils.m
//  Created by Gregory Combs on 8/31/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "TexLegeCoreDataUtils.h"
#import "LegislatorObj+RestKit.h"
#import "CommitteeObj+RestKit.h"
#import "CommitteePositionObj+RestKit.h"
#import "DistrictMapObj+RestKit.h"
#import "DistrictOfficeObj.h"
#import "StafferObj.h"
#import "NSDate+Helper.h"
#import "LocalyticsSession.h"
#import "TexLegeObjectCache.h"
#import "UtilityMethods.h"

#import "NSInvocation+CWVariableArguments.h"

//#define VERIFYCOMMITTEES 1
#ifdef VERIFYCOMMITTEES
#import "JSONDataImporter.h"
#endif

#define SEED_DB_NAME @"TexLegeSeed.sqlite"
#define APP_DB_NAME @"TexLege.sqlite"

@implementation TexLegeCoreDataUtils

+ (id) fetchCalculation:(NSString *)calc ofProperty:(NSString *)prop withType:(NSAttributeType)retType onEntity:(NSString *)entityName {
	
	// Let's just hope it's the kind of class we want
	Class modelClass = NSClassFromString(entityName);
	if (!modelClass || NO == [modelClass isSubclassOfClass:[RKManagedObject class]])
		return nil;

	// setup request
	NSFetchRequest *request = [modelClass fetchRequest];	
	// need to use dictionary to access values
	[request setResultType:NSDictionaryResultType];
	// build expression (must do this for each value you want to retrieve)
	NSExpression *attributeToFetch = [NSExpression expressionForKeyPath:prop];
	NSExpression *functionToPerformOnAttribute = [NSExpression expressionForFunction:calc 
																		   arguments:[NSArray arrayWithObject:attributeToFetch]];
	
	NSExpressionDescription *propertyToFetch = [[NSExpressionDescription alloc] init];
	[propertyToFetch setName:@"myFetchedValue"]; // name used to access value in dictionary
	[propertyToFetch setExpression:functionToPerformOnAttribute];
	[propertyToFetch setExpressionResultType:retType];
	// modify request to fetch only the attribute
	[request setPropertiesToFetch:[NSArray arrayWithObject:propertyToFetch]];
	[propertyToFetch release];
	
	// execute fetch
	NSArray *results = [modelClass objectsWithFetchRequest:request];
	
	// get value
	id fetchedVal = nil;
	if (!IsEmpty(results))
		fetchedVal = [[results objectAtIndex:0] valueForKey:@"myFetchedValue"];
	else
		NSLog(@"CoreData Error while fetching calc (%@) of property (%@) on entity (%@).", calc, prop, entityName);
	
	return fetchedVal;
}
		
+ (DistrictMapObj*)districtMapForDistrict:(NSNumber*)district andChamber:(NSNumber*)chamber {
	return [TexLegeCoreDataUtils districtMapForDistrict:district andChamber:chamber lightProperties:YES];
}

+ (DistrictMapObj*)districtMapForDistrict:(NSNumber*)district andChamber:(NSNumber*)chamber lightProperties:(BOOL)light {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.district == %@ AND self.chamber == %@", district, chamber];
	return [TexLegeCoreDataUtils dataObjectWithPredicate:predicate entityName:@"DistrictMapObj" lightProperties:light];
}

+ (LegislatorObj*)legislatorForDistrict:(NSNumber*)district andChamber:(NSNumber*)chamber 
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.district == %@ AND self.legtype == %@", district, chamber];
	return [LegislatorObj objectWithPredicate:predicate];
}

+ (id)dataObjectWithPredicate:(NSPredicate *)predicate entityName:(NSString*)entityName {
	return [TexLegeCoreDataUtils dataObjectWithPredicate:predicate entityName:entityName lightProperties:YES];
}

// You better make the predicate specific ... so that it only provides one result.  
+ (id)dataObjectWithPredicate:(NSPredicate *)predicate entityName:(NSString*)entityName lightProperties:(BOOL)light {
	if (!predicate || !entityName || !NSClassFromString(entityName))
		return nil;

	NSFetchRequest *request = [NSClassFromString(entityName) fetchRequest];
	if (light && [entityName isEqualToString:@"DistrictMapObj"])
		[request setPropertiesToFetch:[DistrictMapObj lightPropertiesToFetch]];
	[request setPredicate:predicate];
	
	return [NSClassFromString(entityName) objectWithFetchRequest:request];
}

+ (NSArray*)allObjectIDsInEntityNamed:(NSString*)entityName {
	if (entityName && NSClassFromString(entityName))
	{	
		NSFetchRequest *request = [NSClassFromString(entityName) fetchRequest];
		[request setResultType:NSManagedObjectIDResultType];	// only return object IDs
		return [NSClassFromString(entityName) objectsWithFetchRequest:request];	
	}
	return nil;
}

+ (NSArray*)allPrimaryKeyIDsInEntityNamed:(NSString*)entityName {
	Class entityClass = NSClassFromString(entityName);
	if (entityName && entityClass)
	{	
		NSFetchRequest *request = [entityClass fetchRequest];
		
		// only return primary key IDs
		[request setResultType:NSDictionaryResultType];	
		[request setPropertiesToFetch:[NSArray arrayWithObject:[entityClass primaryKeyProperty]]];
		
		return [[entityClass objectsWithFetchRequest:request] valueForKeyPath:[entityClass primaryKeyProperty]];
	}
	return nil;
}

+ (NSArray *) allDistrictMapsLight {
	NSFetchRequest *fetchRequest = [DistrictMapObj fetchRequest];	
	[fetchRequest setPropertiesToFetch:[DistrictMapObj lightPropertiesToFetch]];
	return [DistrictMapObj objectsWithFetchRequest:fetchRequest];
}

+ (NSArray *)allDistrictMapIDsWithBoundingBoxesContaining:(CLLocationCoordinate2D)coordinate
{		
	NSNumber *lat = [NSNumber numberWithDouble:coordinate.latitude];
	NSNumber *lon = [NSNumber numberWithDouble:coordinate.longitude];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"maxLat >= %@ AND minLat <= %@ AND maxLon >=%@ AND minLon <= %@", lat, lat, lon, lon];
	
	NSFetchRequest * request = [DistrictMapObj fetchRequest];
	[request setPropertiesToFetch:[NSArray arrayWithObject:@"districtMapID"]];
	[request setResultType:NSDictionaryResultType];	// only return object IDs
	[request setPredicate:predicate];
	NSArray *results = [DistrictMapObj objectsWithFetchRequest:request];
	if (results && [results count]) {
		NSMutableArray *list = [NSMutableArray arrayWithCapacity:[results count]];
		for (NSDictionary *result in results) {
			[list addObject:[result objectForKey:@"districtMapID"]];
		}
		return list;
	}
	return nil;
}

+ (void) deleteObjectInEntityNamed:(NSString *)entityName withPrimaryKeyValue:(id)keyValue {
	if (!entityName || !NSClassFromString(entityName))
		return;
	
	RKManagedObject *object = [NSClassFromString(entityName) objectWithPrimaryKeyValue:keyValue];
	if (object == nil) {
		debug_NSLog(@"Can't Delete: There's no %@ objects matching ID: %@", entityName, keyValue);
	}
	else {
		[[NSClassFromString(entityName) managedObjectContext] deleteObject:object];
	}
}

+ (void) deleteAllObjectsInEntityNamed:(NSString*)entityName {
	debug_NSLog(@"I HOPE YOU REALLY WANT TO DO THIS ... DELETING ALL OBJECTS IN %@", entityName);
	debug_NSLog(@"----------------------------------------------------------------------");
	
	if (!entityName || !NSClassFromString(entityName))
		return;

	NSArray *fetchedObjects = [NSClassFromString(entityName) allObjects];
	if (fetchedObjects == nil) {
		debug_NSLog(@"There's no objects to delete ???");
	}
	for (NSManagedObject *object in fetchedObjects) {
		[[NSClassFromString(entityName) managedObjectContext] deleteObject:object];
	}
}

+ (void)initRestKitObjects:(id)sender {
	
	RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:RESTKIT_BASE_URL];
	RKObjectMapper* mapper = objectManager.mapper;
	// Initialize object store
	NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"TexLege" ofType:@"momd"];
	NSURL *momURL = [NSURL fileURLWithPath:modelPath];
	NSManagedObjectModel *mom = [[[NSManagedObjectModel alloc] initWithContentsOfURL:momURL] autorelease];
		
	objectManager.client.username = RESTKIT_USERNAME;
	objectManager.client.password = RESTKIT_PASSWORD;
	
	[RKRequestQueue sharedQueue].showsNetworkActivityIndicatorWhenBusy = YES;
	
	// Add our element to object mappings
	[mapper registerClass:[LegislatorObj class] forElementNamed:@"legislators"];
	[mapper registerClass:[CommitteeObj class] forElementNamed:@"committees"];
	[mapper registerClass:[CommitteePositionObj class] forElementNamed:@"committeePositions"];
	[mapper registerClass:[DistrictMapObj class] forElementNamed:@"districtMaps"];
	[mapper registerClass:[DistrictOfficeObj class] forElementNamed:@"districtOffices"];
	[mapper registerClass:[StafferObj class] forElementNamed:@"staffers"];
	
	// Update date format so that we can parse twitter dates properly
	// Wed Sep 29 15:31:08 +0000 2010
	NSMutableArray* dateFormats = [[[mapper dateFormats] mutableCopy] autorelease];
	[dateFormats addObject:@"E MMM d HH:mm:ss Z y"];
	[dateFormats addObject:[NSDate dateFormatString]];
	[dateFormats addObject:[NSDate timeFormatString]];
	[dateFormats addObject:[NSDate timestampFormatString]];
	[mapper setDateFormats:dateFormats];
		
	// Database seeding is configured as a copied target of the main application. There are only two differences
    // between the main application target and the 'Generate Seed Database' target:
    //  1) RESTKIT_GENERATE_SEED_DB is defined in the 'Preprocessor Macros' section of the build setting for the target
    //      This is what triggers the conditional compilation to cause the seed database to be built
    //  2) Source JSON files are added to the 'Generate Seed Database' target to be copied into the bundle. This is required
    //      so that the object seeder can find the files when run in the simulator.
	
#ifdef RESTKIT_GENERATE_SEED_DB
	// Initialize object store
    objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:SEED_DB_NAME 
															 usingSeedDatabaseName:nil /// this is stupid ... we can't supply it yet.
																managedObjectModel:mom];
	
    RKManagedObjectSeeder* seeder = [RKManagedObjectSeeder objectSeederWithObjectManager:objectManager];
    [seeder seedObjectsFromFile:@"LegislatorObj.json" toClass:[LegislatorObj class] keyPath:nil];
    [seeder seedObjectsFromFile:@"DistrictMapObj.json" toClass:[DistrictMapObj class] keyPath:nil];
    [seeder seedObjectsFromFile:@"CommitteeObj.json" toClass:[CommitteeObj class] keyPath:nil];
    [seeder seedObjectsFromFile:@"CommitteePositionObj.json" toClass:[CommitteePositionObj class] keyPath:nil];
    [seeder seedObjectsFromFile:@"DistrictOfficeObj.json" toClass:[DistrictOfficeObj class] keyPath:nil];
    [seeder seedObjectsFromFile:@"StafferObj.json" toClass:[StafferObj class] keyPath:nil];
    
	for (DistrictMapObj *map in [DistrictMapObj allObjects])
		[map resetRelationship:self];

    // Finalize the seeding operation and output a helpful informational message
    [seeder finalizeSeedingAndExit];
    
    // NOTE: If all of your mapped objects use element -> class registration, you can perform seeding in one line of code:
    // [RKManagedObjectSeeder generateSeedDatabaseWithObjectManager:objectManager fromFiles:@"users.json", nil];
#endif
	
	objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:APP_DB_NAME 
															 usingSeedDatabaseName:SEED_DB_NAME 
																managedObjectModel:mom];
	//objectManager.objectStore.managedObjectCache = [[TexLegeObjectCache new] autorelease];
	
#ifdef VERIFYCOMMITTEES
	JSONDataImporter *importer = [[JSONDataImporter alloc] init];
	[importer verifyCommitteeAssignmentsByChamber:HOUSE];
	[importer verifyCommitteeAssignmentsByChamber:SENATE];
	[importer verifyCommitteeAssignmentsByChamber:JOINT];
	[importer release];
	
#endif
}

+ (NSArray *)registeredDataModels {
	return [[[[[RKObjectManager sharedManager] objectStore] managedObjectModel] entitiesByName] allKeys];
}

+ (void) resetSavedDatabase:(id)sender {
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"DATABASE_RESET"];
	[[[RKObjectManager sharedManager] objectStore] deletePersistantStoreUsingSeedDatabaseName:SEED_DB_NAME];
	
	//exit(0);

	for (DistrictMapObj *map in [DistrictMapObj allObjects])
		[map resetRelationship:self];
	[[[RKObjectManager sharedManager] objectStore] save];

	for (NSString *className in [TexLegeCoreDataUtils registeredDataModels]) {
		NSString *notification = [NSString stringWithFormat:@"RESTKIT_LOADED_%@", [className uppercaseString]];
		[[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
	}
}
@end

/*

 @interface TexLegeDataMaintenance()
- (void)informDelegateOfFailureWithMessage:(NSString *)message failOption:(TexLegeDataMaintenanceFailOption)failOption;
- (void)informDelegateOfSuccess;
@end


@implementation TexLegeDataMaintenance

@synthesize delegate;

- (id) initWithDelegate:(id<TexLegeDataMaintenanceDelegate>)newDelegate {
	if (self = [super init]) {
		if (newDelegate)
			delegate = newDelegate;
	}
	return self;
}

- (void) dealloc {
	delegate = nil;
	[super dealloc];
}

- (void)informDelegateOfFailureWithMessage:(NSString *)message failOption:(TexLegeDataMaintenanceFailOption)failOption;
{
    if ([delegate respondsToSelector:@selector(dataMaintenanceDidFail:errorMessage:option:)])
    {
        NSInvocation *invocation = [NSInvocation invocationWithTarget:delegate 
                                                             selector:@selector(dataMaintenanceDidFail:errorMessage:option:) 
                                                      retainArguments:YES, self, message, failOption];
        [invocation invokeOnMainThreadWaitUntilDone:YES];
    } 
}

- (void)informDelegateOfSuccess
{
    if ([delegate respondsToSelector:@selector(dataMaintenanceDidFinishSuccessfully:)])
    {
        [delegate performSelectorOnMainThread:@selector(dataMaintenanceDidFinishSuccessfully:) 
                                   withObject:self 
                                waitUntilDone:NO];
    }
}

#pragma mark -
- (void)main 
{	
	BOOL success = NO;
    @try 
    {		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		for (DistrictMapObj *map in [DistrictMapObj allObjects])
			[map resetRelationship:self];
		
		[[[RKObjectManager sharedManager] objectStore] save];
		success = YES;
		[pool drain];
    }
    @catch (NSException * e) 
    {
        debug_NSLog(@"Exception: %@", e);
    }
	if (success)
		[self informDelegateOfSuccess];
	else
		[self informDelegateOfFailureWithMessage:@"Could not reset core data relationships." failOption:TexLegeDataMaintenanceFailOptionLog];
}

@end
*/
