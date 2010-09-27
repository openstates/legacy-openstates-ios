//
//  DistrictOfficeDataSource.m
//  TexLege
//
//  Created by Gregory Combs on 8/23/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "DistrictOfficeDataSource.h"
#import "TexLegeTheme.h"
#import "DistrictOfficeObj.h"
#import "DisclosureQuartzView.h"
#import "BSForwardGeocoder.h"

@interface DistrictOfficeDataSource (Private)

#if WANTS_OLD_SCHOOL_IMPORT == 1
- (void)initializeDatabase;	
- (NSError *) geocodeDistrictOffice:(DistrictOfficeObj *)office;
- (IBAction) saveAction:(id)sender;
#endif

@end


@implementation DistrictOfficeDataSource
@synthesize fetchedResultsController, managedObjectContext;
@synthesize hideTableIndex, byDistrict;
@synthesize filterChamber, filterString, searchDisplayController;


- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext {
	if (self = [super init]) {
		if (newContext) self.managedObjectContext = newContext;
		self.filterChamber = 0;
		self.filterString = [NSMutableString stringWithString:@""];
		
#if WANTS_OLD_SCHOOL_IMPORT == 1
		[self initializeDatabase];
#endif
		self.byDistrict = NO;
		
	}
	return self;
}

- (void)dealloc {
	self.fetchedResultsController = nil;
	self.managedObjectContext = nil;	
	self.filterString = nil;
	self.searchDisplayController = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark TableDataSourceProtocol methods

// return the data used by the navigation controller and tab bar item
- (NSString *)navigationBarName 
{ return @"District Offices"; }

- (NSString *)name
{ return @"Districts Offices"; }

- (UIImage *)tabBarImage
{ return [UIImage imageNamed:@"Building.png"]; }

- (BOOL)showDisclosureIcon
{ return YES; }

- (BOOL)usesCoreData
{ return YES; }

- (BOOL)canEdit
{ return NO; }


// atomic number is displayed in a plain style tableview
- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
}


// return the committee at the index in the sorted by symbol array
- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
	DistrictOfficeObj *tempEntry = nil;
	@try {
		tempEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	@catch (NSException * e) {
		// Perhaps we're returning from a search and we've got a wacked out indexPath.  Let's reset the search and see what happens.
		debug_NSLog(@"DistrictOfficeDataSource.m -- dataObjectForIndexPath must be out of bounds.  %@", [indexPath description]); 
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
	BOOL useDark = (indexPath.row % 2 == 0);
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Committees"];	// just steal the committees style?
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Committees"] autorelease];
		
		cell.detailTextLabel.font = [TexLegeTheme boldFifteen];
		cell.textLabel.font =		[TexLegeTheme boldTwelve];
		cell.detailTextLabel.textColor = 	[TexLegeTheme textDark];
		cell.textLabel.textColor =	[TexLegeTheme accent];
		
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
		cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		cell.detailTextLabel.minimumFontSize = 12.0f;
		//cell.accessoryView = [TexLegeTheme disclosureLabel:YES];
		//cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]] autorelease];
		DisclosureQuartzView *qv = [[DisclosureQuartzView alloc] initWithFrame:CGRectMake(0.f, 0.f, 28.f, 28.f)];
		//UIImageView *iv = [[UIImageView alloc] initWithImage:[qv imageFromUIView]];
		cell.accessoryView = qv;
		[qv release];
		//[iv release];
		
		
	}
    
	DistrictOfficeObj *tempEntry = [self dataObjectForIndexPath:indexPath];
	
	if (tempEntry == nil) {
		debug_NSLog(@"Busted in DistrictOfficeDataSource.m: cellForRowAtIndexPath -> Couldn't get object data for row.");
		return nil;
	}
	
	// let's override some of the datasource's settings ... specifically, the background color.
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	
	if (self.byDistrict)
		cell.detailTextLabel.text = [NSString stringWithFormat:@"District %@ (%@: %@)", tempEntry.district, [tempEntry.legislator lastname], tempEntry.city];
	else
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (Dist. %@: %@)", [tempEntry.legislator legProperName], tempEntry.district, tempEntry.city];
		
	cell.textLabel.text = (tempEntry.chamber.integerValue == HOUSE) ? @"House" : @"Senate";
	
	
	cell.accessoryView.hidden = (tableView == self.searchDisplayController.searchResultsTableView);
	
	return cell;
}


#pragma mark -
#pragma mark Indexing / Sections


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {	
	//debug_NSLog(@"%@", [self.fetchedResultsController.fetchRequest description]);
	NSInteger count = [[self.fetchedResultsController sections] count];		
	if (count > 1 && !self.hasFilter && !self.byDistrict)  {
		return count; 
	}
	return 1;	
}

// This is for the little index along the right side of the table ... use nil if you don't want it.
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	//return  hideTableIndex ? nil : [fetchedResultsController sectionIndexTitles] ;
	return  nil ;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return index; // index ..........
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
	// eventually (soon) we'll need to create a new fetchedResultsController to filter for chamber selection
	NSInteger count = [[self.fetchedResultsController sections] count];		
	if (count >= 1) {
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
	if (count > 1 && !self.hasFilter && !self.byDistrict)  {
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
		[predString appendFormat:@"(chamber = %@)", [NSNumber numberWithInteger:self.filterChamber]];
	if (self.filterString.length > 0) {		// do some string filtering
		if (predString.length > 0)	// we already have some predicate action, insert "AND"
			[predString appendString:@" AND "];
		[predString appendFormat:@"((legislator.lastname CONTAINS[cd] '%@') OR (legislator.firstname CONTAINS[cd] '%@')", self.filterString, self.filterString];
		[predString appendFormat:@" OR (legislator.middlename CONTAINS[cd] '%@') OR (legislator.nickname CONTAINS[cd] '%@')", self.filterString, self.filterString];
		[predString appendFormat:@" OR (district CONTAINS[cd] '%@') OR (county CONTAINS[cd] '%@')", self.filterString, self.filterString];
		[predString appendFormat:@" OR (city CONTAINS[cd] '%@') OR (zipCode CONTAINS[cd] '%@'))", self.filterString, self.filterString];
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

- (IBAction) sortByType:(id)sender {
	[NSFetchedResultsController deleteCacheWithName:[self.fetchedResultsController cacheName]];
	self.fetchedResultsController = nil;
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Handle error
        debug_NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }           
	
	
}

#pragma mark -
#pragma mark Core Data Methods

/*
 Set up the fetched results controller.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DistrictOfficeObj" 
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	if (self.byDistrict) {
		NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"district" ascending:YES] ;
		NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@"chamber" ascending:NO] ;
		[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort1, sort2, nil]];
		[sort1 release];
		[sort2 release];
	}
	else {
		NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"legislator.lastname" ascending:YES] ;
		NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@"legislator.firstname" ascending:YES] ;
		[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort1, sort2, nil]];
		[sort1 release];
		[sort2 release];
		
	}
		
	fetchedResultsController = [[NSFetchedResultsController alloc] 
															 initWithFetchRequest:fetchRequest 
															 managedObjectContext:self.managedObjectContext 
															 sectionNameKeyPath:nil cacheName:@"DistrictOffices"];
	
    fetchedResultsController.delegate = self;
	
	[fetchRequest release];
	
	return fetchedResultsController;
}    

#if WANTS_OLD_SCHOOL_IMPORT == 1
#warning initializeDatabase IS TURNED ON!!!
#warning DON'T FORGET TO LINK IN THE APPROPRIATE PLIST FILES
	
/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (managedObjectContext != nil) {
        if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
			// Handle error.
			debug_NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}

   
- (NSError *) geocodeDistrictOffice:(DistrictOfficeObj *)office {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

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
			if (result.addressDict && ([[result.addressDict valueForKey:@"address"] length] || [result.formattedAddress length])) {
				//debug_NSLog(@"%@ ..... %@", [result.addressDict valueForKey:@"address"], result.formattedAddress);
				firstResult = result;
				break;
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
	
	[pool drain];

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
	[self saveAction:nil];
	
}


- (void) initializeDatabase {
	
	NSManagedObjectContext *context = self.managedObjectContext;
		
	// read the legislator data from the plist
	NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"DistrictOffices" ofType:@"plist"];
	NSArray *rawPlistArray = [[NSArray alloc] initWithContentsOfFile:thePath];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DistrictOfficeObj" 
														inManagedObjectContext:self.managedObjectContext];
	
	// iterate over the values in the raw  dictionary
	for (NSDictionary * aDictionary in rawPlistArray)
	{
		DistrictOfficeObj *object = [NSEntityDescription insertNewObjectForEntityForName:
										 [entity name] inManagedObjectContext:context];
		if (object) {
			[object importFromDictionary:aDictionary];
			if ([object.pinColorIndex integerValue]==MKPinAnnotationColorRed)
				object.pinColorIndex = [NSNumber numberWithInteger:MKPinAnnotationColorGreen];
		}		
		
	}
	[self saveAction:nil];
	debug_NSLog(@"---------------------------------------------------------Saved District Office Entities");
	[rawPlistArray release];
	
}
#endif

@end
