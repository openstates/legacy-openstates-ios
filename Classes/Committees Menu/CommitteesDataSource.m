//
//  CommitteesDataSource.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "CommitteesDataSource.h"

@implementation CommitteesDataSource

@synthesize fetchedResultsController, managedObjectContext;

@synthesize hideTableIndex;
@synthesize filterChamber, filterString, searchDisplayController;


// setup the data collection
- init {
	if (self = [super init]) {
		self.filterChamber = 0;
		self.filterString = [NSMutableString stringWithString:@""];
	}
	return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext {
	if ([self init])
		if (newContext) self.managedObjectContext = newContext;
	return self;
}

- (void)dealloc {
	self.fetchedResultsController = nil;
	self.searchDisplayController = nil;
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

- (BOOL)usesToolbar
{ return YES; }

- (BOOL)usesSearchbar
{ return NO; }

- (BOOL)canEdit
{ return NO; }

- (CGFloat) rowHeight {
	CGFloat height;
#if kDeviceSensitiveRowHeight == 1
	//if (0 /*something about checking to see if a passed in tableView == searchResultsTable*/)
	//else 
	if (![UtilityMethods isIPadDevice])	// We're on an iPhone/iTouch
		height = 44.0f;
	else
		// an iPad and not a searchResultsTable
#endif
		height = 44.0f;
	
	return height;
}


// atomic number is displayed in a plain style tableview
- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
}


// return the committee at the index in the sorted by symbol array
- (CommitteeObj *)committeeDataForIndexPath:(NSIndexPath *)indexPath {
	CommitteeObj *tempEntry = nil;
	@try {
		tempEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	@catch (NSException * e) {
		// Perhaps we're returning from a search and we've got a wacked out indexPath.  Let's reset the search and see what happens.
		NSLog(@"CommitteeDataSource.m -- committeeDataForIndexPath:  indexPath must be out of bounds.  %@", [indexPath description]); 
		[self removeFilter];
		tempEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	return tempEntry;
}

// UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Committees"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Committees"] autorelease];
	}
    
#if NEEDS_TO_INITIALIZE_DATABASE
	[self initializeDatabase];
#endif

	CommitteeObj *tempEntry = [fetchedResultsController objectAtIndexPath:indexPath];
	
	if (tempEntry == nil) {
		debug_NSLog(@"Busted in CommitteeDataSource.m: cellForRowAtIndexPath -> Couldn't get committee data for row.");
		return nil;
	}
	
	// configure cell contents
	
	//cell.indentationLevel = -4;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.detailTextLabel.text = tempEntry.committeeName;
	cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	cell.detailTextLabel.minimumFontSize = 12.0f;

	if (tempEntry.committeeType.integerValue == HOUSE)
		cell.textLabel.text = [NSString stringWithString: @"House"];
	else //if (tempEntry.committeeType == SENATE)
		cell.textLabel.text = [NSString stringWithString: @"Senate"];
	
	// all the rows should show the disclosure indicator
	if ([self showDisclosureIcon])
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				
	if (tableView == self.searchDisplayController.searchResultsTableView) 
		cell.accessoryType = UITableViewCellAccessoryNone;

	
	//UIColor *dark = [UIColor colorWithRed:0.592f green:0.596f blue:0.608f alpha:1.0];
	//UIColor *light = [UIColor colorWithRed:0.675f green:0.678f blue:0.686f alpha:1.0];
#define DARK_BACKGROUND  [UIColor colorWithRed:218.0/255.0 green:223.0/255.0 blue:226.0/255.0 alpha:1.0]
#define LIGHT_BACKGROUND [UIColor colorWithRed:250.0/255.0 green:251.0/255.0 blue:251.0/255.0 alpha:1.0]

	cell.backgroundColor = (indexPath.row % 2 == 0) ? DARK_BACKGROUND : LIGHT_BACKGROUND;
	cell.detailTextLabel.textColor = 	[UIColor colorWithRed:67.f/255.f green:86.f/255.f blue:98.f/255.f alpha:1.f];
	cell.textLabel.textColor =			[UIColor colorWithRed:151.f/255.f green:161.f/255.f blue:166.f/255.f alpha:1.f];
	
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
	//return  hideTableIndex ? nil : [fetchedResultsController sectionIndexTitles] ;
	return  nil ;
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
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

#if NEEDS_TO_INITIALIZE_DATABASE

- (void)initializeDatabase {
	NSInteger count = [[self.fetchedResultsController sections] count];
	if (count == 0) { // try initializing it...
		
		// Create a new instance of the entity managed by the fetched results controller.
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
		
		// read the legislator data from the plist
		NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"Committees" ofType:@"plist"];
		NSArray *rawPlistArray = [[NSArray alloc] initWithContentsOfFile:thePath];
		
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
				NSFetchRequest *lege_request = [[[NSFetchRequest alloc] init] autorelease];
				NSEntityDescription *lege_entity = [NSEntityDescription entityForName:@"LegislatorObj" 
															   inManagedObjectContext:managedObjectContext];
				[lege_request setEntity:lege_entity];
				
				NSPredicate *lege_predicate = [NSPredicate predicateWithFormat:@"self.legislatorID == %@", [eachMember valueForKey:@"memberId"]];
				[lege_request setPredicate:lege_predicate];
				
				NSError *error = nil;
				NSArray *lege_array = [managedObjectContext executeFetchRequest:lege_request error:&error];
				if (lege_array != nil) {
					if ([lege_array count] > 0) { // may be 0 if the object has been deleted
						LegislatorObj * legislatorObject = [lege_array objectAtIndex:0]; // just get the first (only!!) one.
						[positionObject setValue:legislatorObject forKey:@"legislator"];
					}
				}
				[committeeObject addCommitteePositionsObject:positionObject]; //<label id="code.SVC.addSessionObject"/>
			}
			
			// Save the context.
			NSError *error;
			if (![context save:&error]) {
				// Handle the error...
			}
		}
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
