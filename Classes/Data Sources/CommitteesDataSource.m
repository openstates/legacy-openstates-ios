//
//  CommitteesDataSource.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "CommitteesDataSource.h"
#import "TexLegeTheme.h"
#import "DisclosureQuartzView.h"
#import "TexLegeCoreDataUtils.h"
#import "CommitteePositionObj.h"

@implementation CommitteesDataSource

@synthesize fetchedResultsController, managedObjectContext;

@synthesize hideTableIndex;
@synthesize filterChamber, filterString, searchDisplayController;


- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext {
	if (self = [super init]) {
		if (newContext) self.managedObjectContext = newContext;
		self.filterChamber = 0;
		self.filterString = [NSMutableString stringWithString:@""];
		
#if NEEDS_TO_INITIALIZE_DATABASE == 1
		[self initializeDatabase];
#endif
		
	}
	return self;
}

- (void)dealloc {
	self.fetchedResultsController = nil;
	//self.searchDisplayController = nil;
	self.managedObjectContext = nil;	
	self.filterString = nil;
	
    [super dealloc];
}


#pragma mark -
#pragma mark TableDataSourceProtocol methods

// return the data used by the navigation controller and tab bar item
- (NSString *)navigationBarName 
{ return @"Committee Information"; }

- (NSString *)name
{ return @"Committees"; }

- (UIImage *)tabBarImage
{ return [UIImage imageNamed:@"60-signpost.png"]; }

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
	CommitteeObj *tempEntry = nil;
	@try {
		tempEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	@catch (NSException * e) {
		// Perhaps we're returning from a search and we've got a wacked out indexPath.  Let's reset the search and see what happens.
		debug_NSLog(@"CommitteeDataSource.m -- committeeDataForIndexPath:  indexPath must be out of bounds.  %@", [indexPath description]); 
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
		//cell.accessoryView = [TexLegeTheme disclosureLabel:YES];
		//cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]] autorelease];

		DisclosureQuartzView *qv = [[DisclosureQuartzView alloc] initWithFrame:CGRectMake(0.f, 0.f, 25.f, 25.f)];
		//UIImageView *iv = [[UIImageView alloc] initWithImage:[qv imageFromUIView]];
		cell.accessoryView = qv;
		[qv release];
		//[iv release];
		
	}
    
	CommitteeObj *tempEntry = [self dataObjectForIndexPath:indexPath];
	
	if (tempEntry == nil) {
		debug_NSLog(@"Busted in CommitteeDataSource.m: cellForRowAtIndexPath -> Couldn't get committee data for row.");
		return nil;
	}
	
	// let's override some of the datasource's settings ... specifically, the background color.
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	
	cell.detailTextLabel.text = tempEntry.committeeName;
	cell.textLabel.text = (tempEntry.committeeType.integerValue == HOUSE) ? @"House" : @"Senate";

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
	NSInteger count = [[fetchedResultsController sections] count];		
	if (count > 1 /*&! self.hasFilter*/)  {
		return count; 
	}
	return 1;	
}

// This is for the little index along the right side of the table ... use nil if you don't want it.
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return  hideTableIndex ? nil : [fetchedResultsController sectionIndexTitles] ;
	//return  nil ;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return index; // index ..........
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
	// eventually (soon) we'll need to create a new fetchedResultsController to filter for chamber selection
	NSInteger count = [[fetchedResultsController sections] count];		
	if (count > 1) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
		count = [sectionInfo numberOfObjects];
	}
	return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// this table has multiple sections. One for each unique character that an element begins with
	// [A,B,C,D,E,F,G,H,I,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z]
	// return the letter that represents the requested section
	
	NSInteger count = [[fetchedResultsController sections] count];		
	if (count > 1 /*&! self.hasFilter*/)  {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
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
	
	if (self.filterString.length > 0)	// do some string filtering
			[predString appendFormat:@"(committeeName contains[cd] '%@')", self.filterString];
		if (self.filterChamber > 0) {		// do some chamber filtering
			if (predString.length > 0)	// we already have some predicate action, insert "AND"
				[predString appendString:@" AND "];
			[predString appendFormat:@"(committeeType == %@)", [NSNumber numberWithInteger:self.filterChamber]];
		}
		
	NSPredicate *predicate = (predString.length > 0) ? [NSPredicate predicateWithFormat:predString] : nil;

	// You've got to delete the cache, or disable caching before you modify the predicate...
	[NSFetchedResultsController deleteCacheWithName:[fetchedResultsController cacheName]];
	[fetchedResultsController.fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
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

#if NEEDS_TO_INITIALIZE_DATABASE == 1
#warning initializeDatabase IS TURNED ON!!!
#warning DON'T FORGET TO LINK IN THE APPROPRIATE PLIST FILES

- (void)initializeDatabase {
	NSInteger count = [[self.fetchedResultsController sections] count];
	if (count == 0) { // try initializing it...
		
		// Create a new instance of the entity managed by the fetched results controller.
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
		
		// read the legislator data from the plist
		NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"Committees" ofType:@"plist"];
		NSArray *rawPlistArray = [[NSArray alloc] initWithContentsOfFile:thePath];
		
		NSFetchRequest *lege_request = [[NSFetchRequest alloc] init];

		// iterate over the values in the raw  dictionary
		for (NSDictionary * eachCommittee in rawPlistArray)
		{
			// create an legislator instance for each
			CommitteeObj *committeeObject = [NSEntityDescription insertNewObjectForEntityForName:
												 [entity name] inManagedObjectContext:context];
			
			[committeeObject setValue:[eachCommittee valueForKey:@"committeeId"] forKey:@"committeeId"];
			[committeeObject setValue:[eachCommittee valueForKey:@"parentId"] forKey:@"parentId"];
			[committeeObject setValue:[eachCommittee valueForKey:@"committeeType"] forKey:@"committeeType"];
			[committeeObject setValue:[eachCommittee valueForKey:@"committeeName"] forKey:@"committeeName"];
			[committeeObject setValue:[eachCommittee valueForKey:@"url"] forKey:@"url"];
			[committeeObject setValue:[eachCommittee valueForKey:@"clerk"] forKey:@"clerk"];
			[committeeObject setValue:[eachCommittee valueForKey:@"clerk_email"] forKey:@"clerk_email"];
			[committeeObject setValue:[eachCommittee valueForKey:@"phone"] forKey:@"phone"];
			[committeeObject setValue:[eachCommittee valueForKey:@"office"] forKey:@"office"];
						
			// DO SOMETHING HERE FOR COMMITTEE POSITIONS...
			for (NSDictionary * eachMember in [eachCommittee valueForKey:@"members"]) // returns a dictionary array
			{
				CommitteePositionObj *positionObject = 
				[NSEntityDescription insertNewObjectForEntityForName:@"CommitteePositionObj"
											  inManagedObjectContext:context];
				
				// If appropriate, configure the new managed object.
				[positionObject setValue:[eachMember valueForKey:@"memberPos"] forKey:@"position"];
				[positionObject setValue:[eachMember valueForKey:@"memberId"] forKey:@"legislatorID"];
				//[memberObject setValue:nextId forKey:@"sessionID"];

				// NOW LETS GET THE PROPER LEGISLATOR OBJECT TO LINK THE RELATIONSHIP
				LegislatorObj *legislator = [TexLegeCoreDataUtils legislatorWithLegislatorID:[eachMember valueForKey:@"memberId"] withContext:context];
				if (legislator)
					positionObject.legislator = legislator;
				
				[committeeObject addCommitteePositionsObject:positionObject];
			}

			// Save the context.
			NSError *error;
			if (![context save:&error]) {
				// Handle the error...
			}
		}
		[lege_request release];

		// release the raw data
		[rawPlistArray release];
	}
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
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"CommitteeObj" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
		
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
	
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] 
															 initWithFetchRequest:fetchRequest 
															 managedObjectContext:managedObjectContext 
															 sectionNameKeyPath:sectionString cacheName:@"Root"];

    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[nameInitialSortOrder release];	
	
	return fetchedResultsController;
}    

@end
