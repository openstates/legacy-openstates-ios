//
//  DistrictMapDataSource.m
//  Created by Gregory Combs on 8/23/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "DistrictMapDataSource.h"
#import "SLFDataModels.h"

#import "TexLegeTheme.h"

#import "DisclosureQuartzView.h"

@interface DistrictMapDataSource (Private)
- (NSArray *)sortDescriptors;
@end


@implementation DistrictMapDataSource
@synthesize resourcePath;
@synthesize resourceClass;
@synthesize fetchedResultsController;
@synthesize hideTableIndex, byDistrict;
@synthesize filterChamber, filterString, searchDisplayController;

- (id)init {
	if ((self = [super init])) {
		self.filterChamber = 0;
		self.filterString = [NSMutableString stringWithString:@""];
		fetchedResultsController = nil;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(dataSourceReceivedMemoryWarning:)
													 name:UIApplicationDidReceiveMemoryWarningNotification object:nil];				
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(resetCoreData:) name:@"RESTKIT_LOADED_DISTRICTMAPOBJ" object:nil];		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(resetCoreData:) name:@"RESTKIT_LOADED_LEGISLATOROBJ" object:nil];		
		
	}
	return self;
}

- (void)resetCoreData:(NSNotification *)notification {
	[NSFetchedResultsController deleteCacheWithName:[self.fetchedResultsController cacheName]];
	self.fetchedResultsController = nil;
	NSError *error = nil;
	[self.fetchedResultsController performFetch:&error];
}

-(void)dataSourceReceivedMemoryWarning:(id)sender {
	// let's give this a swinging shot....	
	for (NSManagedObject *object in self.fetchedResultsController.fetchedObjects) {
		[[SLFDistrictMap managedObjectContext] refreshObject:object mergeChanges:NO];
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    self.resourcePath = nil;
	self.fetchedResultsController = nil;
	self.filterString = nil;
	self.searchDisplayController = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark TableDataSourceProtocol methods

- (BOOL)usesCoreData
{ return YES; }

#pragma mark -
#pragma mark Data Object Methods
// return the committee at the index in the sorted by symbol array
- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *tempEntry = nil;
	@try {
		tempEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	@catch (NSException * e) {
		// Perhaps we're returning from a search and we've got a wacked out indexPath.  Let's reset the search and see what happens.
		RKLogError(@"dataObjectForIndexPath must be out of bounds.  %@", [indexPath description]); 
		[self removeFilter];
		tempEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	return tempEntry;
}

- (NSIndexPath *)indexPathForDataObject:(id)dataObject {
	NSIndexPath *tempIndex = nil;
	@try {
		tempIndex = [self.fetchedResultsController indexPathForObject:dataObject];
	}
	@catch (NSException * e) {
	}
	
	return tempIndex;
}


#pragma mark -
#pragma UITableViewDataSource

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
    
	SLFDistrictMap *tempEntry = [self dataObjectForIndexPath:indexPath];
	
	if (tempEntry == nil) {
		RKLogError(@"cellForRowAtIndexPath -> Couldn't get object data for row.");
		return nil;
	}
	
	// let's override some of the datasource's settings ... specifically, the background color.
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	
	NSString *localDist = NSLocalizedStringFromTable(@"District", @"StandardUI", @"The title for a legislative district, as in District 1");
	NSString *localAbbrev = abbreviateString(@"District");
	if (self.byDistrict)
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ (%@)", localDist, 
									 [tempEntry valueForKey:@"district"], 
									 [tempEntry valueForKeyPath:@"legislator.lastName"]];
	else
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@ %@)", 
									 [tempEntry valueForKeyPath:@"legislator.fullName"], localAbbrev,
									 [tempEntry valueForKey:@"district"]];
	
	cell.textLabel.text = chamberStringFromOpenStates([tempEntry valueForKey:@"chamber"]);
	
	
	cell.accessoryView.hidden = (tableView == self.searchDisplayController.searchResultsTableView);
	
	return cell;
}


#pragma mark -
#pragma mark Indexing / Sections


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {	
	NSInteger count = [[self.fetchedResultsController sections] count];		
	if (count > 1 && !self.hasFilter && !self.byDistrict)  {
		return count; 
	}
	return 1;	
}

// This is for the little index along the right side of the table ... use nil if you don't want it.
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	//return  hideTableIndex ? nil : [self.fetchedResultsController sectionIndexTitles] ;
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
		[predString appendFormat:@"(chamber LIKE[cd] '%@')", stringForChamber(self.filterChamber, TLReturnOpenStates)];
	if (self.filterString.length > 0) {		// do some string filtering
		if (predString.length > 0)	// we already have some predicate action, insert "AND"
			[predString appendString:@" AND "];
		[predString appendFormat:@"((legislator.fullName CONTAINS[cd] '%@')", self.filterString];
		[predString appendFormat:@" OR (district CONTAINS[cd] '%@'))", self.filterString];
	}
	NSPredicate *predicate = (predString.length > 0) ? [NSPredicate predicateWithFormat:predString] : nil;
	
	// You've got to delete the cache, or disable caching before you modify the predicate...
	[NSFetchedResultsController deleteCacheWithName:[self.fetchedResultsController cacheName]];
	[self.fetchedResultsController.fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Handle error
        RKLogError(@"Unresolved error %@, %@", [error localizedDescription], [error userInfo]);
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
        RKLogError(@"Unresolved error %@, %@", [error localizedDescription], [error userInfo]);
    }           
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataUpdated object:self];
}

/*
 Set up the fetched results controller.
 */
- (NSArray *)sortDescriptors {
	NSArray *descriptors = nil;
	if (self.byDistrict) {
		NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"district" ascending:YES] ;
		NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@"chamber" ascending:NO] ;
		descriptors = [NSArray arrayWithObjects:sort1, sort2, nil];
		[sort1 release];
		[sort2 release];
	}
	else {
		NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"legislator.lastName" ascending:YES] ;
		NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@"legislator.firstName" ascending:YES] ;
		descriptors = [NSArray arrayWithObjects:sort1, sort2, nil];
		[sort1 release];
		[sort2 release];
	}
	return descriptors;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
	NSFetchRequest *fetchRequest = [SLFDistrictMap fetchRequest];
	
	[fetchRequest setSortDescriptors:[self sortDescriptors]];
	
	fetchedResultsController = [[NSFetchedResultsController alloc] 
															 initWithFetchRequest:fetchRequest 
															 managedObjectContext:[SLFDistrictMap managedObjectContext] 
															 sectionNameKeyPath:nil cacheName:@"DistrictMaps"];
	
    fetchedResultsController.delegate = self;
	return fetchedResultsController;
}    


@end
