//
//  TexLegeDataExporter.m
//  TexLege
//
//  Created by Gregory Combs on 8/31/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TexLegeDataExporter.h"
#import "UtilityMethods.h"
#import "DistrictOfficeObj.h"

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

- (void)exportDistrictOffices {
	NSString *outPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent: @"DistrictOffices.plist"];

	debug_NSLog(@"DataExporter: EXPORTING DISTRICT OFFICES TO: %@", outPath);

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	// Get our table-specific Core Data.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DistrictOfficeObj" 
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
		
	NSError *error = nil;
	NSArray *objArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	
	if (error || !objArray || ![objArray count]) {
		debug_NSLog(@"DataExporter:exportDistrictOffices - unresolved error %@, %@", error, [error userInfo]);
		return;
	}
		
		
	NSMutableArray *archivedObjects = [[NSMutableArray alloc] initWithCapacity:[objArray count]];
	for (DistrictOfficeObj *object in objArray) {
		[archivedObjects addObject:[object exportDictionary]];
	}
	if (![archivedObjects writeToFile:outPath atomically:YES])
			debug_NSLog(@"DataExporter:exportDistrictOffices - export to file was unsuccessful");
	[archivedObjects release];
	
	
}

#if 0
- (void)initializeDatabase {
	NSInteger count = [[self.fetchedResultsController sections] count];
	if (count == 0) { // try initializing it...
		
		// Create a new instance of the entity managed by the fetched results controller.
		NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
		NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
		
		// read the legislator data from the plist
		NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"Legislators" ofType:@"plist"];
		NSArray *rawPlistArray = [[NSArray alloc] initWithContentsOfFile:thePath];
		
		// iterate over the values in the raw  dictionary
		for (NSDictionary * aDictionary in rawPlistArray)
		{
			// create an legislator instance for each
			NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:
												 [entity name] inManagedObjectContext:context];
			
			[newManagedObject setValue:[aDictionary valueForKey:@"legislatorID"] forKey:@"legislatorID"];
			[newManagedObject setValue:[aDictionary valueForKey:@"legtype"] forKey:@"legtype"];
			[newManagedObject setValue:[aDictionary valueForKey:@"legtype_name"] forKey:@"legtype_name"];
			[newManagedObject setValue:[aDictionary valueForKey:@"lastname"] forKey:@"lastname"];
			[newManagedObject setValue:[aDictionary valueForKey:@"firstname"] forKey:@"firstname"];
			[newManagedObject setValue:[aDictionary valueForKey:@"middlename"] forKey:@"middlename"];
			[newManagedObject setValue:[aDictionary valueForKey:@"nickname"] forKey:@"nickname"];
			[newManagedObject setValue:[aDictionary valueForKey:@"suffix"] forKey:@"suffix"];
			[newManagedObject setValue:[aDictionary valueForKey:@"party_name"] forKey:@"party_name"];
			[newManagedObject setValue:[aDictionary valueForKey:@"party_id"] forKey:@"party_id"];
			[newManagedObject setValue:[aDictionary valueForKey:@"district"] forKey:@"district"];
			[newManagedObject setValue:[aDictionary valueForKey:@"tenure"] forKey:@"tenure"];
			[newManagedObject setValue:[aDictionary valueForKey:@"partisan_index"] forKey:@"partisan_index"];
			
			[newManagedObject setValue:[aDictionary valueForKey:@"photo_name"] forKey:@"photo_name"];
			//		[newManagedObject setValue:[aDictionary valueForKey:@"leg_image"] forKey:@"leg_image"];
			
			[newManagedObject setValue:[aDictionary valueForKey:@"bio_url"] forKey:@"bio_url"];
			[newManagedObject setValue:[aDictionary valueForKey:@"twitter"] forKey:@"twitter"];
			[newManagedObject setValue:[aDictionary valueForKey:@"email"] forKey:@"email"];
			
			[newManagedObject setValue:[aDictionary valueForKey:@"notes"] forKey:@"notes"];
			[newManagedObject setValue:[aDictionary valueForKey:@"chamber_desk"] forKey:@"chamber_desk"];
			
			[newManagedObject setValue:[aDictionary valueForKey:@"cap_office"] forKey:@"cap_office"];
			[newManagedObject setValue:[aDictionary valueForKey:@"staff"] forKey:@"staff"];
			[newManagedObject setValue:[aDictionary valueForKey:@"cap_phone"] forKey:@"cap_phone"];
			[newManagedObject setValue:[aDictionary valueForKey:@"cap_fax"] forKey:@"cap_fax"];
			[newManagedObject setValue:[aDictionary valueForKey:@"cap_phone2_name"] forKey:@"cap_phone2_name"];
			[newManagedObject setValue:[aDictionary valueForKey:@"cap_phone2"] forKey:@"cap_phone2"];
			
			[newManagedObject setValue:[aDictionary valueForKey:@"dist1_street"] forKey:@"dist1_street"];
			[newManagedObject setValue:[aDictionary valueForKey:@"dist1_city"] forKey:@"dist1_city"];
			[newManagedObject setValue:[aDictionary valueForKey:@"dist1_zip"] forKey:@"dist1_zip"];
			[newManagedObject setValue:[aDictionary valueForKey:@"dist1_phone"] forKey:@"dist1_phone"];
			[newManagedObject setValue:[aDictionary valueForKey:@"dist1_fax"] forKey:@"dist1_fax"];
			
			[newManagedObject setValue:[aDictionary valueForKey:@"dist2_street"] forKey:@"dist2_street"];
			[newManagedObject setValue:[aDictionary valueForKey:@"dist2_city"] forKey:@"dist2_city"];
			[newManagedObject setValue:[aDictionary valueForKey:@"dist2_zip"] forKey:@"dist2_zip"];
			[newManagedObject setValue:[aDictionary valueForKey:@"dist2_phone"] forKey:@"dist2_phone"];
			[newManagedObject setValue:[aDictionary valueForKey:@"dist2_fax"] forKey:@"dist2_fax"];
			
			[newManagedObject setValue:[aDictionary valueForKey:@"dist3_street"] forKey:@"dist3_street"];
			[newManagedObject setValue:[aDictionary valueForKey:@"dist3_city"] forKey:@"dist3_city"];
			[newManagedObject setValue:[aDictionary valueForKey:@"dist3_zip"] forKey:@"dist3_zip"];
			[newManagedObject setValue:[aDictionary valueForKey:@"dist3_phone1"] forKey:@"dist3_phone1"];
			[newManagedObject setValue:[aDictionary valueForKey:@"dist3_fax"] forKey:@"dist3_fax"];
			
			[newManagedObject setValue:[aDictionary valueForKey:@"dist4_street"] forKey:@"dist4_street"];
			[newManagedObject setValue:[aDictionary valueForKey:@"dist4_city"] forKey:@"dist4_city"];
			[newManagedObject setValue:[aDictionary valueForKey:@"dist4_zip"] forKey:@"dist4_zip"];
			[newManagedObject setValue:[aDictionary valueForKey:@"dist4_phone1"] forKey:@"dist4_phone1"];
			[newManagedObject setValue:[aDictionary valueForKey:@"dist4_fax"] forKey:@"dist4_fax"];
			
			[self save];
		}
		// release the raw data
		[rawPlistArray release];
	}
}

- (NSError *) geocodeDistrictOffice:(DistrictOfficeObj *)office {
	NSError *parseError = nil;
	NSString *searchQuery = [NSString stringWithFormat:@"%@, %@, TX, %@", office.address, office.city, office.zipCode];
	
	// Create the url to Googles geocoding API, we want the response to be in XML
	NSString* mapsUrl = [[NSString alloc] initWithFormat:@"http://maps.google.com/maps/api/geocode/xml?address=%@&sensor=false&region=us", 
						 searchQuery];
	
	// Create the url object for our request. It's important to escape the 
	// search string to support spaces and international characters
	NSURL *url = [[NSURL alloc] initWithString:[mapsUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	// Run the KML parser
	BSGoogleV3KmlParser *parser = [[BSGoogleV3KmlParser alloc] init];
	
	[parser parseXMLFileAtURL:url parseError:&parseError ignoreAddressComponents:NO];
	
	[url release];
	[mapsUrl release];
	
	// If the query was successfull we store the array with results
	if(parser.statusCode == G_GEO_SUCCESS)
	{
		BSKmlResult *firstResult = nil;
		
		for (BSKmlResult *result in parser.results) {
			if (result.addressDict && ([[result.addressDict valueForKey:@"address"] length]|| [result.formattedAddress length])) {
				//debug_NSLog(@"%@ ..... %@", [result.addressDict valueForKey:@"address"], result.formattedAddress);
				firstResult = result;
				continue;
			}
		}
		if (!firstResult) {
			firstResult = [parser.results objectAtIndex:0];
			debug_NSLog(@"Troublesome address for %@", [office.legislator legProperName]);
		}
		
		NSDictionary *addressDict = firstResult.addressDict;
		
		
		BOOL missingAddress = (addressDict && [[addressDict valueForKey:@"address"] length] == 0);
		
		if (missingAddress) {
			debug_NSLog(@"[Forward Geocoder] Has a missing address: MISSINGADDR=%d, %@", missingAddress, searchQuery);
			//[addressDict setValue:@"Post Office Box" forKey:@"formattedAddress"];
			[addressDict setValue:office.address forKey:@"formattedAddress"];
		}
		
		office.formattedAddress = [addressDict valueForKey:@"formattedAddress"];
		office.county = [firstResult county];
		office.latitude = [NSNumber numberWithDouble:[firstResult latitude]];
		office.longitude = [NSNumber numberWithDouble:[firstResult longitude]];
		office.spanLat = [NSNumber numberWithDouble:firstResult.coordinateSpan.latitudeDelta];
		office.spanLon = [NSNumber numberWithDouble:firstResult.coordinateSpan.longitudeDelta];
	}
	
	//debug_NSLog(@"Found placemarks: %d", [parser.results count]);
	
	if ([parser.results count] == 0)
		debug_NSLog(@"Nothing found for %@", searchQuery);
	
	
	[parser release];	
	
	
	if(parseError != nil)
	{
		debug_NSLog(@"Geocode parse error: %@", [parseError localizedDescription]);
	}
	
	
	return parseError;
	
}



/*
 - (void) encryptWnomData {
 NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
 NSEntityDescription *entity = [NSEntityDescription entityForName:@"WnomObj"
 inManagedObjectContext:self.managedObjectContext];
 [fetchRequest setEntity:entity];
 
 NSError *error;
 NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
 if (fetchedObjects == nil) {
 debug_NSLog(@"There's no WnomObj objects to delete ???");
 }
 [fetchRequest release];
 
 //for (WnomObj *object in fetchedObjects)
 WnomObj *object = [fetchedObjects objectAtIndex:124];
 {
 //object.wnomAdj
 //object.wnomStderr
 //object.adjMean
 
 debug_NSLog(@"starting number: %@", [object.wnomAdj description]);
 
 NSData *wnomData = [NSKeyedArchiver archivedDataWithRootObject:object.wnomAdj];
 debug_NSLog(@"raw archival: %@", [wnomData description]);
 
 NSData *encryptedData = [wnomData AES256EncryptWithKey:[UtilityMethods cipher32Byte]];
 debug_NSLog(@"encrypted: %@", [encryptedData description]);
 
 NSData *decryptedData = [encryptedData AES256DecryptWithKey:[UtilityMethods cipher32Byte]];
 debug_NSLog(@"decypted: %@", [decryptedData description]);
 
 NSNumber *decryptedNum = [NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
 
 debug_NSLog(@"ending number: %@", [decryptedNum description]);
 
 }
 
 }
 */

- (void) clearPartisanshipIndexDatabase {
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"WnomObj"
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSError *error;
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects == nil) {
		debug_NSLog(@"There's no WnomObj objects to delete ???");
	}
	[fetchRequest release];
	
	for (NSManagedObject *object in fetchedObjects) {
		[self.managedObjectContext deleteObject:object];
	}
	[self save];
}


- (void) populatePartisanIndexDatabase
{
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	// Get our table-specific Core Data.
	NSEntityDescription *legEntity = [NSEntityDescription entityForName:@"LegislatorObj" 
												 inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:legEntity];
	
	// Sort by lastname.
	NSSortDescriptor *lastnnameSortOrder = [[NSSortDescriptor alloc] initWithKey:@"lastname"
																	   ascending:YES] ;
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:lastnnameSortOrder, nil]];
	
	[fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"legislatorID",@"partisan_index", nil]];
	
	NSError *error = nil;
	NSArray *legArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	[lastnnameSortOrder release];
	
	
	if (error) {
		debug_NSLog(@"DirectoryDataSource:save - unresolved error %@, %@", error, [error userInfo]);
		return;
	}
	
	// read the legislator data from the plist
	NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"Wnom" ofType:@"plist"];
	NSArray *rawPlistArray = [[NSArray alloc] initWithContentsOfFile:thePath];
	
	NSEntityDescription *wnomEntity = [NSEntityDescription entityForName:@"WnomObj" 
												  inManagedObjectContext:self.managedObjectContext];
	
	NSNumber		*currentLegID = nil;
	NSMutableSet	*wnomSet = [[NSMutableSet alloc] initWithCapacity:30];	// arbitrary limit, change at will.
	
	// iterate over the values in the raw  dictionary
	for (NSDictionary * aDictionary in rawPlistArray)
	{
		NSNumber *wnomLegID = [aDictionary valueForKey:@"legislatorID"];
		NSNumber *session = [aDictionary valueForKey:@"session"];
		NSNumber *wnomAdj = [aDictionary valueForKey:@"wnom_adj"];
		NSNumber *wnomStderr = [aDictionary valueForKey:@"wnom_stderr"];
		NSNumber *adjMean = [aDictionary valueForKey:@"adj_mean"];
		
		// we've got a new legislator
		if (![wnomLegID isEqual:currentLegID]) {
			if ([wnomSet count])
			{
				BOOL found = NO;
				
				// lets find the appropriate legislator object and add this wnom set to it.
				for (LegislatorObj *leg in legArray) {
					if ([leg.legislatorID isEqual:currentLegID]) {
						[leg addWnomScores:wnomSet];
						debug_NSLog(@"Adding %d scores to %@ - %@", [wnomSet count], leg.legislatorID, [leg legProperName]);
						NSNumber *tempMean = [[wnomSet anyObject] valueForKey:@"adjMean"];
						found = YES;
						if (![tempMean isEqual:leg.partisan_index])
							leg.partisan_index = tempMean;
					}
				}
				if (!found) {
					debug_NSLog(@"Not Found in core data: %@", currentLegID);
				}
				
				[wnomSet removeAllObjects];
			}
			currentLegID = wnomLegID;
		}
		WnomObj *newWnomObj = (WnomObj *)[NSEntityDescription insertNewObjectForEntityForName:
										  [wnomEntity name] inManagedObjectContext:self.managedObjectContext];
		newWnomObj.session = session;
		newWnomObj.wnomAdj = wnomAdj;
		newWnomObj.wnomStderr = wnomStderr;
		newWnomObj.adjMean = adjMean;
		[wnomSet addObject:newWnomObj];
		
	}
	[self save];
	debug_NSLog(@"---------------------------------------------------------Saved Partisan Index DB");
	[rawPlistArray release];
	[wnomSet release];
	
	
}


/*
 Set up the fetched results controller.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	// Get our table-specific Core Data.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LegislatorObj" 
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Sort by committeeName.
	NSSortDescriptor *nameInitialSortOrder = [[NSSortDescriptor alloc] initWithKey:@"lastname"
																		 ascending:YES] ;
	NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstname"
																	ascending:YES] ;
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:nameInitialSortOrder, firstDescriptor, nil]];
	
	
	NSString * sectionString;
	// we don't want sections when searching, change to hasFilter if you don't want it for toolbarAction either...
    // nil for section name key path means "no sections".
	if (self.filterString.length > 0) 
		sectionString = nil;
	else
		sectionString = @"lastnameInitial";
	
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] 
															 initWithFetchRequest:fetchRequest 
															 managedObjectContext:self.managedObjectContext 
															 sectionNameKeyPath:sectionString cacheName:@"Root"];
	
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[nameInitialSortOrder release];	
	[firstDescriptor release];	
	
	return fetchedResultsController;
} 
#endif
@end
