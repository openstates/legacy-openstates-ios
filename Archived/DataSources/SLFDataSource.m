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
@synthesize groupBy;
@synthesize loading;
@synthesize fetchedResultsController;
@synthesize hideTableIndex;
@synthesize searchDisplayController;
@synthesize queryParameters;

- (id)initWithObjClass:(Class)newClass groupBy:(NSString *)newGroup
{
	if ((self = [super init])) {
        NSCParameterAssert( (newClass != NULL) );
        NSCParameterAssert( [newClass isSubclassOfClass:[NSManagedObject class]] );
        self.resourceClass = newClass;
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
    [[RKObjectManager sharedManager].client.requestQueue cancelRequestsWithDelegate:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    self.stateID = nil;    
	self.fetchedResultsController = nil;
	self.searchDisplayController = nil;	
    self.groupBy = nil;
    self.queryParameters = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark TableDataSourceProtocol methods

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
    if (stateID)
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

- (void)loadData {
    if (self.fetchedResultsController) {
        NSError *error = nil;  
        if (![fetchedResultsController performFetch:&error]) {
            RKLogError(@"Unresolved error %@, %@", [error localizedDescription], [error userInfo]);
        }  
    }
    [self loadDataWithResourcePath:self.resourcePath];
}

- (void)loadDataWithResourcePath:(NSString *)newPath {
    NSCParameterAssert(newPath != NULL);
    if (self.loading) {
        RKLogDebug(@"Multiple loadData attempts.");
        return; // we're already working on it!
    }
    self.loading = YES;
	NSString *pathToLoad = [newPath appendQueryParams:self.queryParameters];
    [[SLFRestKitManager sharedRestKit] loadObjectsAtResourcePath:pathToLoad delegate:self];
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
	return [[self.fetchedResultsController sections] count];		
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return  (self.hideTableIndex) ? nil : [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return index;
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)sectionIndex {
    NSInteger count = 0;
    NSArray *sections = [self.fetchedResultsController sections];
	if ([sections count] > sectionIndex) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
            //NSLog(@"%@", [sectionInfo objects]);
		count = [sectionInfo numberOfObjects];
	}
	return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex {
	NSString *headerTitle = nil;
    NSArray *sections = [self.fetchedResultsController sections];
	if ([sections count] > sectionIndex )  {
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
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

- (NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController)
        return fetchedResultsController;
    
    id<RKManagedObjectCache> cache = [[[RKObjectManager sharedManager] objectStore] managedObjectCache];
    NSCParameterAssert(cache != NULL);
    NSString *pathToLoad = [self.resourcePath appendQueryParams:self.queryParameters];
    NSArray *fetches = [cache fetchRequestsForResourcePath:pathToLoad];
    NSCParameterAssert(!IsEmpty(fetches));
    NSFetchRequest *request = [fetches objectAtIndex:0];
    NSCParameterAssert(request != NULL);
    
    fetchedResultsController = [[self.resourceClass fetchRequest:request groupedBy:self.groupBy] retain];
    fetchedResultsController.delegate = self;    
    return fetchedResultsController;
}    

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataUpdated object:self];
}

#pragma mark -
#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoaderDidFinishLoading:(RKObjectLoader*)objectLoader {
    self.loading = NO;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
        return;
    }
    RKLogDebug(@"Loaded %d objects into frc.", [self.fetchedResultsController.fetchedObjects count]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataUpdated object:self];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    self.loading = NO;
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataError object:self];
}

@end
