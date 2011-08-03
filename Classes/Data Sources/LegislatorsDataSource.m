//
//  LegislatorsDataSource.m
//  Created by Gregory S. Combs on 5/31/09.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LegislatorsDataSource.h"
#import "SLFLegislator.h"

#import "SLFRestKitManager.h"
#import "StateMetaLoader.h"
#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "LegislatorCell.h"

@interface LegislatorsDataSource (Private)
- (void)dataSourceReceivedMemoryWarning:(id)sender;
@end


@implementation LegislatorsDataSource
@synthesize resourcePath;
@synthesize resourceClass;
@synthesize stateID;

@synthesize fetchedResultsController;
@synthesize hideTableIndex;
@synthesize searchDisplayController;

- (id)init {
	if ((self = [super init])) {
        
        self.resourceClass = [SLFLegislator class];
        self.resourcePath = @"/legislators/";        
	
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(dataSourceReceivedMemoryWarning:)
													 name:UIApplicationDidReceiveMemoryWarningNotification 
                                                   object:nil];
		
	}
	return self;
}


- (void)dealloc {	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	self.fetchedResultsController = nil;
	self.searchDisplayController = nil;
	//self.filterString = nil;
	
    self.resourcePath = nil;
    self.stateID = nil;
    
    [super dealloc];
}

-(void)dataSourceReceivedMemoryWarning:(id)sender {
	// let's give this a swinging shot....	
	for (NSManagedObject *object in self.fetchedResultsController.fetchedObjects) {
		[[SLFLegislator managedObjectContext] refreshObject:object mergeChanges:NO];
	}
}

- (void)setStateID:(NSString *)newID {
    [stateID release];
    stateID = [newID copy];
    if (newID) {
        [self loadData];
    }
}

- (void)loadData {
    
    if (!self.stateID || [[NSNull null] isEqual:self.stateID])
        return;
    
    // Load the object model via RestKit	
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    RKObjectMapping* legMapping = [objectManager.mappingProvider objectMappingForClass:self.resourceClass];
    
	
	NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
								 self.stateID, @"state",
								 @"true", @"active",
								 SUNLIGHT_APIKEY, @"apikey",
								 nil];
	NSString *newPath = [self.resourcePath appendQueryParams:queryParams];
    
    [objectManager loadObjectsAtResourcePath:newPath objectMapping:legMapping delegate:self];
}

- (void)reloadButtonWasPressed:(id)sender {
	// Load the object model via RestKit
	[self loadData];
}


#pragma mark -
#pragma mark TableDataSourceProtocol methods
// return the data used by the navigation controller and tab bar item

- (BOOL)usesCoreData
{ return YES; }

#pragma mark -
#pragma mark UITableViewDataSource methods

// return the legislator at the index in the sorted by symbol array
- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
    
	SLFLegislator *tempEntry = nil;
	@try {
		tempEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	@catch (NSException * e) {
		// Perhaps we're returning from a search and we've got a wacked out indexPath.  Let's reset the search and see what happens.
		debug_NSLog(@"LegislatorsDataSource.m -- dataObjectForIndexPath:  indexPath must be out of bounds.  %@", [indexPath description]); 

        @try {
            tempEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        @catch (NSException * e) {
            tempEntry = nil;
        }
        
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

// UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SLFLegislator *dataObj = [self dataObjectForIndexPath:indexPath];
	if (dataObj == nil) {
		debug_NSLog(@"Busted in LegislatorsDataSource.m: cellForRowAtIndexPath -> Couldn't get legislator data for row.");
		return nil;
	}
	static NSString *leg_cell_ID = @"LegislatorQuartz";		
		
	LegislatorCell *cell = (LegislatorCell *)[tableView dequeueReusableCellWithIdentifier:leg_cell_ID];
	
	if (cell == nil) {
		cell = [[[LegislatorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:leg_cell_ID] autorelease];
		cell.frame = CGRectMake(0.0, 0.0, 320.0, 73.0);
	}
	
	[cell setLegislator:dataObj];
	cell.cellView.useDarkBackground = (indexPath.row % 2 == 0);
	cell.accessoryView.hidden = (tableView == self.searchDisplayController.searchResultsTableView);
	
	return cell;	
}

#pragma mark -
#pragma mark Indexing / Sections


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {	
	NSInteger count = [[self.fetchedResultsController sections] count];		
	if (count > 1)  {
		return count; 
	}
    return 0;
}

// This is for the little index along the right side of the table ... use nil if you don't want it.
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return  self.hideTableIndex ? nil : [self.fetchedResultsController sectionIndexTitles] ;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return index;
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {

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
	
	NSString *headerTitle = nil;
	NSInteger count = [[self.fetchedResultsController sections] count];		
	if (count > 1 )  {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
		headerTitle = [sectionInfo indexTitle];
		if (!headerTitle)
			headerTitle = [sectionInfo name];
	}
	if (!headerTitle)
		headerTitle = @"";

	return headerTitle;
}


#pragma mark -
#pragma mark NSFetchedResultsController


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataUpdated object:self];
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController) {
        return fetchedResultsController;
    }        
    
    NSPredicate * predicate = nil;
    if (self.stateID) {
        predicate = [NSPredicate predicateWithFormat:@"(stateID LIKE[cd] '%@')", self.stateID];
    }
    
    fetchedResultsController = [[SLFLegislator fetchAllSortedBy:@"lastName"
                                                      ascending:YES 
                                                  withPredicate:predicate 
                                                        groupBy:@"lastnameInitial"] retain];
    return fetchedResultsController;
}    


#pragma mark RKObjectLoaderDelegate methods

/*
- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdatedAt"];
	[[NSUserDefaults standardUserDefaults] synchronize];
            
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataUpdated object:self];

}
*/

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    
    [[SLFRestKitManager sharedRestKit] showFailureAlertWithRequest:objectLoader error:error];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataError object:self];
}


@end
