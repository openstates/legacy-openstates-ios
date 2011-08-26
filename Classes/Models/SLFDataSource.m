//
//  SLFDataSource.m
//  Created by Gregory S. Combs on 8/3/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFDataSource.h"
#import "SLFDataModels.h"
#import "SLFRestKitManager.h"

@interface SLFDataSource()
- (void)dataSourceReceivedMemoryWarning:(id)sender;
@end

@implementation SLFDataSource

@synthesize stateID;
@synthesize resourcePath;
@synthesize resourceClass;
@synthesize sortBy;
@synthesize groupBy;
@synthesize loading;
@synthesize fetchedResultsController;
@synthesize hideTableIndex;
@synthesize searchDisplayController;
@synthesize queryParameters;

- (id)initWithObjClass:(Class)newClass 
                    sortBy:(NSString *)newSort
                   groupBy:(NSString *)newGroup
{
	if ((self = [super init])) {
        
        NSCParameterAssert( (newClass != NULL) );
        NSCParameterAssert( [newClass isSubclassOfClass:[NSManagedObject class]] );
                   
        self.resourceClass = newClass;
        self.sortBy = newSort;
        self.groupBy = newGroup;
        self.loading = NO;
        self.queryParameters = [NSMutableDictionary dictionaryWithObject:SUNLIGHT_APIKEY forKey:@"apikey"];

        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(dataSourceReceivedMemoryWarning:)
													 name:UIApplicationDidReceiveMemoryWarningNotification 
                                                   object:nil];
		
	}
	return self;
}


- (void)dealloc {	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    self.stateID = nil;    
	self.fetchedResultsController = nil;
	self.searchDisplayController = nil;	
    self.sortBy = nil;
    self.groupBy = nil;
    self.queryParameters = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark TableDataSourceProtocol methods
// return the data used by the navigation controller and tab bar item

- (BOOL)usesCoreData
{ return YES; }

-(void)dataSourceReceivedMemoryWarning:(id)sender {
    if (self.fetchedResultsController) {
        for (NSManagedObject *object in self.fetchedResultsController.fetchedObjects) {
            [[self.resourceClass managedObjectContext] refreshObject:object mergeChanges:NO];
        }
    }
}

#pragma mark -
#pragma mark Data Object Accessors

- (void)setStateID:(NSString *)newID {
    [stateID release];
    stateID = [newID copy];
    if (newID) {
        [self loadData];
    }
}

- (NSString *)resourcePath {
    NSCParameterAssert(NO); // they must override this
    return nil;
}

- (NSString *)primaryKeyProperty {
    return self.stateID;
}

- (void)loadData {
    [self loadDataWithResourcePath:self.resourcePath];
}

- (void)loadDataWithResourcePath:(NSString *)newPath {
    NSCParameterAssert(newPath != NULL);
    
    if (!self.primaryKeyProperty || [[NSNull null] isEqual:self.primaryKeyProperty]) {
        return;
    }
    
    if (self.loading) {
        RKLogDebug(@"Multiple loadData attempts.");
        return; // we're already working on it!
    }
    self.loading = YES;
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    RKObjectMapping* objMapping = [objectManager.mappingProvider objectMappingForClass:self.resourceClass];

	NSString *pathToLoad = [newPath appendQueryParams:self.queryParameters];
    
    RKLogDebug(@"Loading data at path: %@", pathToLoad);
    [objectManager loadObjectsAtResourcePath:pathToLoad objectMapping:objMapping delegate:self];
}


- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
    
	id tempEntry = nil;
    
	@try {
		tempEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	@catch (NSException * e) {
		RKLogError(@"IndexPath must be out of bounds.  %@", [indexPath description]); 
        tempEntry = nil;
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
#pragma mark UITableViewDataSource methods

// subclasses *must* override this
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSCAssert( NO, @"Some subclass needs to implement this method.");
	return nil;	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {	
	NSInteger count = [[self.fetchedResultsController sections] count];		
    return count; 
}

// This is for the little index along the right side of the table ... use nil if you don't want it.
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return  (self.hideTableIndex) ? nil : [self.fetchedResultsController sectionIndexTitles];
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
		if (!headerTitle) {
			headerTitle = [sectionInfo name];
        }
        if (headerTitle) {
            return headerTitle;
        }
	}
    
	return @"";
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
    
    fetchedResultsController = [[self.resourceClass fetchAllSortedBy:self.sortBy
                                                      ascending:YES 
                                                  withPredicate:predicate 
                                                        groupBy:self.groupBy] retain];
    return fetchedResultsController;
}    

#pragma mark -
#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoaderDidFinishLoading:(RKObjectLoader*)objectLoader {
    self.loading = NO;
    //[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataUpdated object:self];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    self.loading = NO;
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataError object:self];
}

@end
