//
//  CommitteesDataSource.m
//  Created by Gregory S. Combs on 5/31/09.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "CommitteesDataSource.h"
#import "SLFDataModels.h"
#import "StateMetaLoader.h"

#import "TexLegeTheme.h"
#import "DisclosureQuartzView.h"

@implementation CommitteesDataSource
@synthesize resourcePath;
@synthesize resourceClass;
@synthesize stateID;
@synthesize committees;

@synthesize fetchedResultsController;
@synthesize hideTableIndex;
@synthesize filterChamber, filterString, searchDisplayController;

- (id)init {
	if ((self = [super init])) {
        
        self.resourceClass = [SLFCommittee class];
        self.resourcePath = @"/committees/";        

        
		self.filterChamber = 0;
		self.filterString = [NSMutableString stringWithString:@""];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(dataSourceReceivedMemoryWarning:)
													 name:UIApplicationDidReceiveMemoryWarningNotification object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(stateChanged:) 
                                                     name:kStateMetaNotifyStateLoaded 
                                                   object:nil];
        
    }
	return self;
}





- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	self.fetchedResultsController = nil;
	self.searchDisplayController = nil;
	self.filterString = nil;
	self.resourcePath = nil;
    self.committees = nil;
    self.stateID = nil;
    [super dealloc];
}




-(void)dataSourceReceivedMemoryWarning:(id)sender {
	// let's give this a swinging shot....	
	for (NSManagedObject *object in self.fetchedResultsController.fetchedObjects) {
		[[SLFCommittee managedObjectContext] refreshObject:object mergeChanges:NO];
	}
}



- (void)loadDataFromDataStore {
    self.committees = nil;
	NSFetchRequest* fetchRequest = [SLFCommittee fetchRequest];
    
    NSSortDescriptor *nameInitialSortOrder = [[NSSortDescriptor alloc] initWithKey:@"committeeName" ascending:YES] ;
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:nameInitialSortOrder, nil]];
    
	self.committees = [SLFCommittee objectsWithFetchRequest:fetchRequest];
}

- (void)stateChanged:(NSNotification *)notification {
    self.stateID = [[[StateMetaLoader sharedStateMeta] selectedState] abbreviation];
}

- (void)resetCoreData:(NSNotification *)notification {
    /*
     [NSFetchedResultsController deleteCacheWithName:[self.fetchedResultsController cacheName]];
     self.fetchedResultsController = nil;
     NSError *error = nil;
     [self.fetchedResultsController performFetch:&error];*/
    [self loadDataFromDataStore];
}


- (void)setStateID:(NSString *)newID {
    [stateID release];
    stateID = [newID copy];
    if (newID) {
        //self.title = [NSString stringWithFormat:@"%@ Legislators", [newID uppercaseString]];
        //[self loadDataFromDataStore];
        [self loadData];
    }
}

- (void)loadData {
    
    if (!self.stateID || [[NSNull null] isEqual:self.stateID])
        return;
    
    // Load the object model via RestKit	
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    RKObjectMapping* objMapping = [objectManager.mappingProvider objectMappingForClass:self.resourceClass];
    
	
	NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
								 self.stateID, @"state",
								 SUNLIGHT_APIKEY, @"apikey",
								 nil];
	NSString *newPath = [self.resourcePath appendQueryParams:queryParams];
    
    [objectManager loadObjectsAtResourcePath:newPath objectMapping:objMapping delegate:self];
}

- (void)reloadButtonWasPressed:(id)sender {
	// Load the object model via RestKit
	[self loadData];
}


#pragma mark -
#pragma mark TableDataSourceProtocol methods

- (BOOL)usesCoreData
{ return YES; }

// return the committee at the index in the sorted by symbol array
- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
    return [self.committees objectAtIndex:indexPath.row];

	/*
    SLFCommittee *tempEntry = nil;
	@try {
		tempEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	@catch (NSException * e) {
		// Perhaps we're returning from a search and we've got a wacked out indexPath.  Let's reset the search and see what happens.
		debug_NSLog(@"CommitteeDataSource.m -- committeeDataForIndexPath:  indexPath must be out of bounds.  %@", [indexPath description]); 
		[self removeFilter];
		tempEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	return tempEntry;*/
}

- (NSIndexPath *)indexPathForDataObject:(id)dataObject {
    
    NSIndexPath *tempIndex = nil;
	@try {
        NSInteger row = [self.committees indexOfObject:dataObject];
        tempIndex = [NSIndexPath indexPathForRow:row inSection:0];
		//tempIndex = [self.fetchedResultsController indexPathForObject:dataObject];
	}
	@catch (NSException * e) {
	}
	
	return tempIndex;
    
}

// UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL useDark = (indexPath.row % 2 == 0);

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Committees"];
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

		DisclosureQuartzView *qv = [[DisclosureQuartzView alloc] initWithFrame:CGRectMake(0.f, 0.f, 28.f, 28.f)];
		cell.accessoryView = qv;
		[qv release];
		
	}
    
	SLFCommittee *tempEntry = [self dataObjectForIndexPath:indexPath];
	
	if (tempEntry == nil) {
		debug_NSLog(@"Busted in CommitteeDataSource.m: cellForRowAtIndexPath -> Couldn't get committee data for row.");
		return nil;
	}
	
	// let's override some of the datasource's settings ... specifically, the background color.
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	
	cell.detailTextLabel.text = tempEntry.committeeName;
	cell.textLabel.text = chamberStringFromOpenStates(tempEntry.chamber);

	/*
	 if (tableView == self.searchDisplayController.searchResultsTableView) {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	 */
	cell.accessoryView.hidden = (tableView == self.searchDisplayController.searchResultsTableView);


	return cell;
}


#pragma mark -
#pragma mark Indexing / Sections


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {	
	/*NSInteger count = [[fetchedResultsController sections] count];		
	if (count > 1 )  {
		return count; 
	}*/
	return 1;	
}
/*
// This is for the little index along the right side of the table ... use nil if you don't want it.
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return  hideTableIndex ? nil : [fetchedResultsController sectionIndexTitles] ;
	//return  nil ;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return index; // index ..........
}
*/
- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
/*	// eventually (soon) we'll need to create a new fetchedResultsController to filter for chamber selection
	NSInteger count = [[fetchedResultsController sections] count];		
	if (count > 1) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
		count = [sectionInfo numberOfObjects];
	}
	return count;*/
    return [self.committees count];
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// this table has multiple sections. One for each unique character that an element begins with
	// [A,B,C,D,E,F,G,H,I,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z]
	// return the letter that represents the requested section
	
	NSInteger count = [[fetchedResultsController sections] count];		
	if (count > 1 )  {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
		return [sectionInfo indexTitle]; // or [sectionInfo name];
	}
	return @"";
}*/

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
		[predString appendFormat:@"(committeeName CONTAINS[cd] '%@')", self.filterString];
	}
    if (predString.length > 0 && self.stateID) {
        [predString appendFormat:@" AND (stateID LIKE[cd] '%@')", self.stateID];
    }
    
	NSPredicate *predicate = (predString.length > 0) ? [NSPredicate predicateWithFormat:predString] : nil;
	if (predicate) {
        self.committees = [SLFCommittee findAllWithPredicate:predicate];
    }
    else {
        [self loadDataFromDataStore];
    }
/*
    		
	NSPredicate *predicate = (predString.length > 0) ? [NSPredicate predicateWithFormat:predString] : nil;

	// You've got to delete the cache, or disable caching before you modify the predicate...
	[NSFetchedResultsController deleteCacheWithName:[fetchedResultsController cacheName]];
	[fetchedResultsController.fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle error
        debug_NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }           */
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataUpdated object:self];
}


#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdatedAt"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    NSSortDescriptor* first = [NSSortDescriptor sortDescriptorWithKey:@"committeeName" ascending:YES];
	self.committees = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:first, nil]];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataUpdated object:self];
    
    
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
	UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Error" 
                                                     message:[error localizedDescription] 
                                                    delegate:nil 
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[alert show];
	NSLog(@"Hit error: %@", error);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataError object:self];
}



/*
 Set up the fetched results controller.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [SLFCommittee fetchRequest];
			
	// Sort by committeeName.
	NSSortDescriptor *nameInitialSortOrder = [[NSSortDescriptor alloc] initWithKey:@"committeeName" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:nameInitialSortOrder]];
	
	NSString * sectionString;
	// we don't want sections when searching, change to hasFilter if you don't want it for toolbarAction either...
    // nil for section name key path means "no sections".
	if (self.filterString.length > 0) 
		sectionString = nil;
	else
		sectionString = @"committeeNameInitial";
	
	fetchedResultsController = [[NSFetchedResultsController alloc] 
															 initWithFetchRequest:fetchRequest 
															 managedObjectContext:[SLFCommittee managedObjectContext] 
															 sectionNameKeyPath:sectionString cacheName:@"Committees"];

    fetchedResultsController.delegate = self;
	[nameInitialSortOrder release];	
	
	return fetchedResultsController;
}    

@end
