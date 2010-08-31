//
//  DirectoryDataSource.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "LegislatorsDataSource.h"
#import "LegislatorObj.h"
#import "WnomObj.h"
#import "LegislatorMasterTableViewCell.h"
#import "UtilityMethods.h"
#import "ImageCache.h"
#import "LegislatorMasterCellView.h"
#import "TexLegeTheme.h"
#import "LegislatorMasterCell.h"
#import "DistrictOfficeObj.h"
#import "BSForwardGeocoder.h"
#import "UIDevice-Hardware.h"
//#import "NSData+Encryption.h"

@interface LegislatorsDataSource (Private)

#if NEEDS_TO_INITIALIZE_DATABASE == 1
- (void)initializeDatabase;	
- (void) populatePartisanIndexDatabase;
- (void) populateDistrictOffices;
- (void) checkDistrictOffices;
#endif


- (void) save;

@end


@implementation LegislatorsDataSource

@synthesize fetchedResultsController, managedObjectContext;
@synthesize hideTableIndex;
@synthesize filterChamber, filterString, searchDisplayController;
@synthesize leg_cell;



- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext {
	if (self = [super init]) {
		if (newContext)
			self.managedObjectContext = newContext;
	
		self.filterChamber = 0;
		self.filterString = [NSMutableString stringWithString:@""];

#if NEEDS_TO_INITIALIZE_DATABASE == 1
		[self initializeDatabase];
		[self populatePartisanIndexDatabase];
		[self populateDistrictOffices];
		[self checkDistrictOffices];
#endif
		
	}
	return self;
}

- (void)dealloc {	
	self.fetchedResultsController = nil;
	self.searchDisplayController = nil;
	self.managedObjectContext = nil;	// I THINK THIS IS CORRECT, SINCE WE'VE SYNTHESIZED IT AS RETAIN...
	self.filterString = nil;
	self.leg_cell = nil;	
	
    [super dealloc];
}

#pragma mark -
#pragma mark TableDataSourceProtocol methods
// return the data used by the navigation controller and tab bar item

- (NSString *)name 
{ return @"Legislators"; }

- (NSString *)navigationBarName 
{ return @"Legislator Directory"; }

- (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"123-id-card.png"]; }

- (BOOL)showDisclosureIcon
{ return YES; }

- (BOOL)usesCoreData
{ return YES; }

- (BOOL)canEdit
{ return NO; }

#pragma mark -
#pragma mark UITableViewDataSource methods

// legislator name is displayed in a plain style tableview

- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
};


// return the legislator at the index in the sorted by symbol array
- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
	LegislatorObj *tempEntry = nil;
	@try {
		tempEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	@catch (NSException * e) {
		// Perhaps we're returning from a search and we've got a wacked out indexPath.  Let's reset the search and see what happens.
		debug_NSLog(@"DirectoryDataSource.m -- legislatorDataForIndexPath:  indexPath must be out of bounds.  %@", [indexPath description]); 
		[self removeFilter];
		tempEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	return tempEntry;	
}

- (NSIndexPath *)indexPathForDataObject:(id)dataObject {
	return [self.fetchedResultsController indexPathForObject:dataObject];
}

// UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	LegislatorObj *dataObj = [self dataObjectForIndexPath:indexPath];
	if (dataObj == nil) {
		debug_NSLog(@"Busted in DirectoryDataSource.m: cellForRowAtIndexPath -> Couldn't get legislator data for row.");
		return nil;
	}
	
#if kDeviceSensitiveRowHeight == 0
	NSUInteger platformType = [[UIDevice currentDevice] platformType];
	if (platformType != UIDeviceiPhoneSimulatoriPad && platformType <= UIDevice3GiPhone)
    {
		static NSString *leg_searchcell_ID = @"LegislatorDirectorySkinny";
		
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:leg_searchcell_ID];
		if (cell == nil) {
			
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:leg_searchcell_ID] autorelease];
			
			cell.detailTextLabel.font =		[TexLegeTheme boldFifteen];
			cell.textLabel.font =			[TexLegeTheme boldTwelve];
			cell.detailTextLabel.textColor = [TexLegeTheme textDark];
			cell.textLabel.textColor =		[TexLegeTheme accent];
			
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
			cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
			cell.detailTextLabel.minimumFontSize = 12.0f;
			//cell.accessoryView = [TexLegeTheme disclosureLabel:YES];
			cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]] autorelease];
		}
		
		// configure cell contents
		cell.textLabel.text = [dataObj.legtype_name stringByAppendingFormat:@" - %@", [dataObj districtPartyString]];
		cell.detailTextLabel.text = [dataObj legProperName];
		cell.imageView.image = [UIImage imageNamed:dataObj.photo_name];
		cell.accessoryView.hidden = (![self showDisclosureIcon] || tableView == self.searchDisplayController.searchResultsTableView);

		return cell;
    }
	else
#endif
		
#if 1	// IF YOU WANT QUARTZ DRAWN CELLS ... 
	{
			
		static NSString *leg_cell_ID = @"LegislatorQuartz";		
			
		LegislatorMasterCell *cell = (LegislatorMasterCell *)[tableView dequeueReusableCellWithIdentifier:leg_cell_ID];
		
		if (cell == nil) {
			cell = [[[LegislatorMasterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:leg_cell_ID] autorelease];
			//cell.frame = CGRectMake(0.0, 0.0, 320.0, 73.0);
			cell.frame = CGRectMake(0.0, 0.0, 320.0, 73.0);

		}
		
		cell.legislator = dataObj;
		cell.cellView.useDarkBackground = (indexPath.row % 2 == 0);
		cell.accessoryView.hidden = (![self showDisclosureIcon] || tableView == self.searchDisplayController.searchResultsTableView);
		
		return cell;
	}
	
#else
	{
		static NSString *leg_cell_ID = @"LegislatorDirectory";		
		LegislatorMasterTableViewCell *cell = (LegislatorMasterTableViewCell *)[tableView 
																				dequeueReusableCellWithIdentifier:leg_cell_ID];
		if (cell == nil) {
			NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"LegislatorMasterTableViewCell" owner:self options:nil];
			for (id suspect in objects) {
				if ([suspect isKindOfClass:[LegislatorMasterTableViewCell class]])
					self.leg_cell = suspect;
			}
			cell = self.leg_cell;
			self.leg_cell = nil;
		}
				
		[cell setupWithLegislator:dataObj];
		cell.useDarkBackground = (indexPath.row % 2 == 0);
		cell.accessoryView.hidden = (![self showDisclosureIcon] || tableView == self.searchDisplayController.searchResultsTableView);
		
		return cell;
	}
#endif
}

#pragma mark -
#pragma mark Indexing / Sections


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {	
	NSInteger count = [[self.fetchedResultsController sections] count];		
	if (count > 1 /*&! self.hasFilter*/)  {
		return count; 
	}
	return 1;	
}

// This is for the little index along the right side of the table ... use nil if you don't want it.
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return  hideTableIndex ? nil : [self.fetchedResultsController sectionIndexTitles] ;
	//return  nil ;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return index; // index ..........
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
	// eventually (soon) we'll need to create a new fetchedResultsController to filter for chamber selection
	NSInteger count = [[self.fetchedResultsController sections] count];		
	if (count > 1) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
		count = [sectionInfo numberOfObjects];
	}
	return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// this table has multiple sections. One for each unique character that an element begins with
	// [A,B,C,D,E,F,G,H,I,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z]
	// return the letter that represents the requested section
	
	NSInteger count = [[self.fetchedResultsController sections] count];		
	if (count > 1 /*&! self.hasFilter*/)  {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
		return [sectionInfo indexTitle]; // or [sectionInfo name];
	}
	return @"";
}

#pragma mark -
#pragma mark Filtering Functions

// do we want to do a proper whichFilter sort of thing?
- (BOOL) hasFilter {
	return (self.filterString.length > 0 || self.filterChamber > 0);
}

// Predicate Programming
// You want your search to be diacritic insensitive to match the 'é' in pensée and 'e' in pensee. 
// You get this by adding the [d] after the attribute; the [c] means case insensitive.
//
// We can also do: "(firstName beginswith 'G') AND (lastName like 'Combs')"
//    or: "group.name matches "'work.*'", "ALL children.age > 12", and "ANY children.age > 12"
//    or for operations: "@sum.items.price < 1000"
//
// The matches operator uses regex, so is not supported by Core Data’s SQL store— although 
//     it does work with in-memory filtering.
// *** The Core Data SQL store supports only one to-many operation per query; therefore in any predicate 
//      sent to the SQL store, there may be only one operator (and one instance of that operator) 
//      from ALL, ANY, and IN.
// You cannot necessarily translate “arbitrary” SQL queries into predicates.
//*

- (void) updateFilterPredicate {
	NSMutableString * predString = [NSMutableString stringWithString:@""];

	if (self.filterChamber > 0)	// do some chamber filtering
		[predString appendFormat:@"(legtype = %@)", [NSNumber numberWithInteger:self.filterChamber]];
	if (self.filterString.length > 0) {		// do some string filtering
		if (predString.length > 0)	// we already have some predicate action, insert "AND"
			[predString appendString:@" AND "];
		[predString appendFormat:@"((lastname CONTAINS[cd] '%@') OR (firstname CONTAINS[cd] '%@')", self.filterString, self.filterString];
		[predString appendFormat:@" OR (middlename CONTAINS[cd] '%@') OR (nickname CONTAINS[cd] '%@')", self.filterString, self.filterString];
		[predString appendFormat:@" OR (district CONTAINS[cd] '%@'))", self.filterString];
	}

	NSPredicate *predicate = (predString.length > 0) ? [NSPredicate predicateWithFormat:predString] : nil;
	
	// You've got to delete the cache, or disable caching before you modify the predicate...
	[NSFetchedResultsController deleteCacheWithName:[self.fetchedResultsController cacheName]];
	[self.fetchedResultsController.fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Handle error
        debug_NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }           
}

// probably unnecessary, but we might as well validate the new info with our expectations...
- (void) setFilterByString:(NSString *)filter {
	if (!filter) filter = @"";
	
	if (![self.filterString isEqualToString:filter]) {
		self.filterString = [NSMutableString stringWithString:filter];
	}

	// we also get called on toolbar chamber switches, with or without a search string, so update anyway...
	[self updateFilterPredicate];	
}

- (void) removeFilter {
	// do we want to tell it to clear out our chamber selection too? Not really, the ViewController sets it for us.
	// self.filterChamber = 0;
	[self setFilterByString:@""]; // we updateFilterPredicate automatically
	
}	

#pragma mark -
#pragma mark Core Data Methods

- (void)save{
	@try {
		NSError *error;
		if (![self.managedObjectContext save:&error]) {
			debug_NSLog(@"DirectoryDataSource:save - unresolved error %@, %@", error, [error userInfo]);
		}		
	}
	@catch (NSException * e) {
		debug_NSLog(@"Failure in DirectoryDataSource:save, name=%@ reason=%@", e.name, e.reason);
	}
}

#if NEEDS_TO_INITIALIZE_DATABASE == 1
#warning initializeDatabase IS TURNED ON!!!
#warning DON'T FORGET TO LINK IN THE APPROPRIATE PLIST FILES
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

- (void) checkDistrictOffices {
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	// Get our table-specific Core Data.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DistrictOfficeObj" 
												 inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	//[fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"legislatorID", nil]];
	
	NSError *error = nil;
	NSArray *objArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	
	if (error) {
		debug_NSLog(@"DirectoryDataSource:fetch - unresolved error %@, %@", error, [error userInfo]);
		return;
	}
	
	for (DistrictOfficeObj *obj in objArray) {
		if ([obj.latitude doubleValue] < 20.0f) { // we don't have a valid location
			[self geocodeDistrictOffice:obj];
			if ([obj.latitude doubleValue] < 20.0f) // we don't have a valid location
				debug_NSLog(@"Found invalid location: %@", [obj address]);
			else
				debug_NSLog(@"Fixed one: %@", [obj address]);
		}
	}
	[self save];
	
}


- (void) populateDistrictOffices {
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	// Get our table-specific Core Data.
	NSEntityDescription *legEntity = [NSEntityDescription entityForName:@"LegislatorObj" 
												 inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:legEntity];
		
	[fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"legislatorID", nil]];
	
	NSError *error = nil;
	NSArray *legArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	
	if (error) {
		debug_NSLog(@"DirectoryDataSource:save - unresolved error %@, %@", error, [error userInfo]);
		return;
	}
	
	// read the legislator data from the plist
	NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"Legislators" ofType:@"plist"];
	NSArray *rawPlistArray = [[NSArray alloc] initWithContentsOfFile:thePath];
	
	NSEntityDescription *distOfficeEntity = [NSEntityDescription entityForName:@"DistrictOfficeObj" 
												  inManagedObjectContext:self.managedObjectContext];
	
	NSMutableSet	*theset = [[NSMutableSet alloc] initWithCapacity:5];	// arbitrary limit, change at will.
	
	// iterate over the values in the raw  dictionary
	for (NSDictionary * aDictionary in rawPlistArray)
	{
		NSNumber *legID = [aDictionary valueForKey:@"legislatorID"];
		NSNumber *chamber = [aDictionary valueForKey:@"legtype"];
		NSNumber *district = [aDictionary valueForKey:@"district"];
		
		LegislatorObj *foundLeg = nil;
		
		// lets find the appropriate legislator object and add this wnom set to it.
		for (LegislatorObj *leg in legArray) {
			if ([leg.legislatorID isEqual:legID]) {
				foundLeg = leg;
				continue;
			}
		}
		if (!foundLeg) {
			debug_NSLog(@"Not Found in core data: %@", legID);
			continue;
		}

		
		NSString *street = [aDictionary valueForKey:@"dist1_street"];
		NSString *city = [aDictionary valueForKey:@"dist1_city"];
		NSString *zip = [aDictionary valueForKey:@"dist1_zip"];
		NSString *phone = [aDictionary valueForKey:@"dist1_phone"];
		NSString *fax = [aDictionary valueForKey:@"dist1_fax"];
		
		if (street && [street length]) {
			DistrictOfficeObj *newObj = (DistrictOfficeObj *)[NSEntityDescription insertNewObjectForEntityForName:
																	[distOfficeEntity name] inManagedObjectContext:self.managedObjectContext];
			
			newObj.chamber = chamber;
			newObj.district = district;
			newObj.phone = phone;
			newObj.fax = fax;
			newObj.address = street;
			newObj.city = city;
			newObj.stateCode = @"TX";
			newObj.zipCode = zip;
			newObj.legislator = foundLeg;
			newObj.pinColorIndex = [NSNumber numberWithInteger:MKPinAnnotationColorRed];

			[self geocodeDistrictOffice:newObj];
		}
		
		street = [aDictionary valueForKey:@"dist2_street"];
		city = [aDictionary valueForKey:@"dist2_city"];
		zip = [aDictionary valueForKey:@"dist2_zip"];
		phone = [aDictionary valueForKey:@"dist2_phone"];
		fax = [aDictionary valueForKey:@"dist2_fax"];
		
		if (street && [street length]) {
			DistrictOfficeObj *newObj = (DistrictOfficeObj *)[NSEntityDescription insertNewObjectForEntityForName:
															  [distOfficeEntity name] inManagedObjectContext:self.managedObjectContext];
			
			newObj.chamber = chamber;
			newObj.district = district;
			newObj.phone = phone;
			newObj.fax = fax;
			newObj.address = street;
			newObj.city = city;
			newObj.stateCode = @"TX";
			newObj.zipCode = zip;
			newObj.legislator = foundLeg;
			newObj.pinColorIndex = [NSNumber numberWithInteger:MKPinAnnotationColorRed];

			[self geocodeDistrictOffice:newObj];
		}
		
		street = [aDictionary valueForKey:@"dist3_street"];
		city = [aDictionary valueForKey:@"dist3_city"];
		zip = [aDictionary valueForKey:@"dist3_zip"];
		phone = [aDictionary valueForKey:@"dist3_phone1"];
		fax = [aDictionary valueForKey:@"dist3_fax"];
		
		if (street && [street length]) {
			DistrictOfficeObj *newObj = (DistrictOfficeObj *)[NSEntityDescription insertNewObjectForEntityForName:
															  [distOfficeEntity name] inManagedObjectContext:self.managedObjectContext];
			
			newObj.chamber = chamber;
			newObj.district = district;
			newObj.phone = phone;
			newObj.fax = fax;
			newObj.address = street;
			newObj.city = city;
			newObj.stateCode = @"TX";
			newObj.zipCode = zip;
			newObj.legislator = foundLeg;
			newObj.pinColorIndex = [NSNumber numberWithInteger:MKPinAnnotationColorRed];

			[self geocodeDistrictOffice:newObj];
		}
		
		
		street = [aDictionary valueForKey:@"dist4_street"];
		city = [aDictionary valueForKey:@"dist4_city"];
		zip = [aDictionary valueForKey:@"dist4_zip"];
		phone = [aDictionary valueForKey:@"dist4_phone1"];
		fax = [aDictionary valueForKey:@"dist4_fax"];
		
		if (street && [street length]) {
			DistrictOfficeObj *newObj = (DistrictOfficeObj *)[NSEntityDescription insertNewObjectForEntityForName:
															  [distOfficeEntity name] inManagedObjectContext:self.managedObjectContext];
			
			newObj.chamber = chamber;
			newObj.district = district;
			newObj.phone = phone;
			newObj.fax = fax;
			newObj.address = street;
			newObj.city = city;
			newObj.stateCode = @"TX";
			newObj.zipCode = zip;
			newObj.legislator = foundLeg;
			newObj.pinColorIndex = [NSNumber numberWithInteger:MKPinAnnotationColorRed];

			[self geocodeDistrictOffice:newObj];
		}
				
	}
	[self save];
	debug_NSLog(@"---------------------------------------------------------Saved District Office Entities");
	[rawPlistArray release];
	[theset release];
	
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

#endif


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
@end
