//
//  DataModelUpdateManager.m
//  Created by Gregory Combs on 1/26/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "DataModelUpdateManager.h"
#import <RestKit/Support/JSON/JSONKit/JSONKit.h>
#import "UtilityMethods.h"
#import "TexLegeReachability.h"
#import "TexLegeCoreDataUtils.h"
#import "MTStatusBarOverlay.h"
#import "LocalyticsSession.h"
#import "DistrictMapObj+RestKit.h"
#import "NSDate+Helper.h"

#define FORCE_ALL_UPDATES 0

#define JSONDATA_ENCODING		NSUTF8StringEncoding
#define TXLUPDMGR_CLASSKEY		@"className"
#define TXLUPDMGR_QUERYKEY		@"queryType"
#define TXLUPDMGR_UPDATEDPROP	@"updated"
#define TXLUPDMGR_UPDATEDPARAM	@"updated_since"

						// QUERIES RETURN AN ARRAY OF ROWS
enum TXL_QueryTypes {
	QUERYTYPE_IDS_NEW = 1,		//	 *filtered* by updated_since;	contains only primaryKey
	QUERYTYPE_IDS_ALL_PRUNE,	//	 **PRUNES CORE DATA**		;	contains only primaryKey
	QUERYTYPE_COMPLETE_NEW,		//   *filtered* by updated_since;	contains *all* properties
	QUERYTYPE_COMPLETE_ALL		//						all rows;	contains *all* properties
};
#define queryIsComplete(query) (query >= QUERYTYPE_COMPLETE_NEW)
#define queryIsNew(query) ((query == QUERYTYPE_IDS_NEW) || (query == QUERYTYPE_COMPLETE_NEW))

#define numToInt(number) (number ? [number integerValue] : 0)	// should this be NSNotFound or nil or null?
#define intToNum(integer) [NSNumber numberWithInt:integer]

@interface DataModelUpdateManager (Private)

- (NSString *)localDataTimestampForModel:(NSString *)classString;

// Someday we may opt to handle updating for this aggregate partisanship file.  Right now it's manually updated.
// In the future, we might use a method like the following to get timestamps and update accordingly.
#define WNOMAGGREGATES_UPDATING 0
#if WNOMAGGREGATES_UPDATING
- (NSString *) localDataTimestampForArray:(NSArray *)entityArray;
#endif	
@end

@implementation DataModelUpdateManager
@synthesize activeUpdates;

- (id) init {
	if ((self=[super init])) {
		_queue = [[RKRequestQueue alloc] init];
		_queue.concurrentRequestsLimit = 1;
		_queue.delegate = self;
//		_queue.showsNetworkActivityIndicatorWhenBusy = YES;
		
		activeUpdates = [[NSCountedSet alloc] init];
		statusBlurbsAndModels = [[NSDictionary alloc] initWithObjectsAndKeys: 
									  NSLocalizedStringFromTable(@"Legislators", @"DataTableUI", @"Status indicator for updates"), @"LegislatorObj",
									  NSLocalizedStringFromTable(@"Partisanship Scores", @"DataTableUI", @"Status indicator for updates"), @"WnomObj",
									  NSLocalizedStringFromTable(@"Staffers", @"DataTableUI", @"Status indicator for updates"), @"StafferObj",
									  NSLocalizedStringFromTable(@"Committees", @"DataTableUI", @"Status indicator for updates"), @"CommitteeObj",
									  NSLocalizedStringFromTable(@"Committee Positions", @"DataTableUI", @"Status indicator for updates"), @"CommitteePositionObj",
									  NSLocalizedStringFromTable(@"District Offices", @"DataTableUI", @"Status indicator for updates"), @"DistrictOfficeObj",
									  NSLocalizedStringFromTable(@"Resources", @"DataTableUI", @"Status indicator for updates"), @"LinkObj",
									  NSLocalizedStringFromTable(@"District Maps", @"DataTableUI", @"Status indicator for updates"), @"DistrictMapObj",
									  NSLocalizedStringFromTable(@"Party Scores", @"DataTableUI", @"Status indicator for updates"), @"WnomAggregateObj",
									  nil];		
	}
	return self;
}


- (void) dealloc {
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
	[_queue cancelRequestsWithDelegate:self];
	[_queue release], _queue = nil;
	[statusBlurbsAndModels release], statusBlurbsAndModels = nil;
	self.activeUpdates = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark Check & Perform Updates

- (void) performDataUpdatesIfAvailable:(id)sender {
	NSArray *objects = [statusBlurbsAndModels allKeys];
	if ([TexLegeReachability texlegeReachable]) {
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"DATABASE_UPDATE_REQUEST"];
		NSString *statusString = NSLocalizedStringFromTable(@"Checking for Data Updates", @"DataTableUI", @"Status indicator for updates");
		MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedMTStatusBarOverlay] ;
		overlay.historyEnabled = YES;
		overlay.animation = MTStatusBarOverlayAnimationFallDown;  // MTStatusBarOverlayAnimationShrink
		overlay.detailViewMode = MTDetailViewModeHistory;         // enable automatic history-tracking and show in detail-view
		overlay.progress = 0.0;
		[overlay postMessage:statusString animated:YES];	
		
		self.activeUpdates = [NSCountedSet set];
						
		RKObjectManager* objectManager = [RKObjectManager sharedManager];

		for (NSString *entityName in objects) {
#if FORCE_ALL_UPDATES
			NSString *localTS = @"2008-01-01 00:00:00";
#else
			NSString *localTS = [self localDataTimestampForModel:entityName];
#endif
			NSString *resourcePath = [NSString stringWithFormat:@"/rest.php/%@/", entityName];
			NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:localTS,TXLUPDMGR_UPDATEDPARAM,nil];
			NSString* resourcePathWithQuery = RKPathAppendQueryParams(resourcePath, queryParams);
			
			Class entityClass = NSClassFromString(entityName);
			if (entityClass) {							
				[self.activeUpdates addObject:entityName];		// we don't add WnomAggregateObj because we don't get it loaded the same way.
				
				RKObjectLoader *loader = [objectManager objectLoaderWithResourcePath:resourcePathWithQuery delegate:self];
				loader.method = RKRequestMethodGET;
				loader.objectClass = entityClass;
				loader.backgroundPolicy = RKRequestBackgroundPolicyContinue;
				[_queue addRequest:loader];
			}			
		}		
		if ([_queue count]) {
			[_queue start];
		}
	}
}

// Send a simple query to our server's REST API.  The queryType determines the content and the resulting actions once we receive the response
- (void) queryIDsForModel:(NSString *)entityName {
	NSString *resourcePath = [[NSString alloc] initWithFormat:@"/rest_ids.php/%@/", entityName];
	RKRequest *request = [[RKClient sharedClient] get:resourcePath delegate:self];	
	if (request) {
		request.userData = [NSDictionary dictionaryWithObjectsAndKeys:
								  entityName, TXLUPDMGR_CLASSKEY,
								  intToNum(QUERYTYPE_IDS_ALL_PRUNE), TXLUPDMGR_QUERYKEY, nil];
	}
	else {
		NSLog(@"DataUpdateManager Error, unable to obtain RestKit request for %@", resourcePath);
	}
	[resourcePath release];
}

// This scans the core data entity looking for "stale" objects, ones that were deleted on the server database
- (void)pruneModel:(NSString *)className forUpstreamIDs:(NSArray *)upstreamIDs {
	Class entityClass = NSClassFromString(className);

	if (!entityClass || ![[TexLegeCoreDataUtils registeredDataModels] containsObject:className])
		return;			// What do we do for WnomAggregateObj ???

	RKObjectManager* objectManager = [RKObjectManager sharedManager];

	BOOL changed = NO;
	
	NSSet *existingSet = [NSSet setWithArray:[TexLegeCoreDataUtils allPrimaryKeyIDsInEntityNamed:className]];	
	NSSet *newSet = [NSSet setWithArray:upstreamIDs];
	
	// Determine which items were removed
	NSMutableSet *removedItems = [NSMutableSet setWithSet:existingSet];
	[removedItems minusSet:newSet];
	
	for (NSNumber *staleObjID in removedItems) {
		NSLog(@"DataUpdateManager: PRUNING OBJECT FROM %@: ID = %@", className, staleObjID);
		[TexLegeCoreDataUtils deleteObjectInEntityNamed:className withPrimaryKeyValue:staleObjID];			
		changed = YES;
	}
	if (changed) {
		[[objectManager objectStore] save];
		
		NSString *notification = [NSString stringWithFormat:@"RESTKIT_LOADED_%@", [className uppercaseString]];
		[[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
		
		NSString *statusString = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Pruned %@", @"DataTableUI", @"Status indicator for updates, these objects are being removed from the database"), 
								  [statusBlurbsAndModels objectForKey:className]];
		[[MTStatusBarOverlay sharedMTStatusBarOverlay] postImmediateMessage:statusString duration:1 animated:YES];
	}	
}

- (void)updateProgress {	
	NSInteger count = [_queue count];
	CGFloat progress = 1.0f;
	if (count > 0)
		progress = 1.0f / (CGFloat)count;
	[MTStatusBarOverlay sharedMTStatusBarOverlay].progress = progress;
}

#pragma mark -
#pragma mark RKRequestQueueDelegate methods

- (void)requestQueue:(RKRequestQueue *)queue didSendRequest:(RKRequest *)request {
    //_statusLabel.text = [NSString stringWithFormat:@"RKRequestQueue %@ sharedQueue is current loading %d of %d requests", 
    //                     queue, [queue loadingCount], [queue count]];
	[self updateProgress];
}

- (void)requestQueueDidBeginLoading:(RKRequestQueue *)queue {
//    _statusLabel.text = [NSString stringWithFormat:@"Queue %@ Began Loading...", queue];
}

- (void)requestQueueDidFinishLoading:(RKRequestQueue *)queue {
//    _statusLabel.text = [NSString stringWithFormat:@"Queue %@ Finished Loading...", queue];
	[self updateProgress];
	if ([_queue count] == 0)
		[[MTStatusBarOverlay sharedMTStatusBarOverlay] postFinishMessage:NSLocalizedStringFromTable(@"Update Completed", @"DataTableUI", @"Status indicator for updates") duration:5];	
}

#pragma mark -
#pragma mark RKRequestDelegate methods

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
	if (error && request) {
		debug_NSLog(@"Error loading data model query from %@: %@", [request description], [error localizedDescription]);		
	}	
}

// Handling GET Requests  
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
	if ([request isGET] && [response isOK]) {  
		// Success! Let's take a look at the data  
		
		if (!request.userData)
			return; // We've got no user data, can't do anything...

		NSString *className = [request.userData objectForKey:TXLUPDMGR_CLASSKEY];
		NSInteger queryType = numToInt([request.userData objectForKey:TXLUPDMGR_QUERYKEY]);
		
		if (NO == queryIsComplete(queryType)) { // we're only working with an array of IDs
			NSArray *resultIDs = [response bodyAsJSON];
			if (resultIDs && [resultIDs count]) {
				if (queryType == QUERYTYPE_IDS_NEW) {
					// DO SOMETHING
				}
				else if (queryType == QUERYTYPE_IDS_ALL_PRUNE) {
					[self pruneModel:className forUpstreamIDs:resultIDs];
				}
			}
		}
	}
}		

#pragma mark -
#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
	NSString *className = NSStringFromClass(objectLoader.objectClass);

	@try {
		if (className) {
			[self.activeUpdates removeObject:className];
			
			if (objects && [objects count]) {
				NSString *notification = [NSString stringWithFormat:@"RESTKIT_LOADED_%@", [className uppercaseString]];
				debug_NSLog(@"%@ %d objects", notification, [objects count]);
				
				NSString *statusString = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %@", @"DataTableUI", @"Status indicator for updates"), 
										  [statusBlurbsAndModels objectForKey:className]];
				[[MTStatusBarOverlay sharedMTStatusBarOverlay] postMessage:statusString animated:YES];				
			
				// We shouldn't do a costly reset if there's another reset headed out way in a few seconds.
				if (([className isEqualToString:@"DistrictMapObj"] &! [self.activeUpdates containsObject:@"LegislatorObj"]) 
					|| ([className isEqualToString:@"LegislatorObj"] &! [self.activeUpdates containsObject:@"DistrictMapObj"])) 
				{
					for (DistrictMapObj *map in [DistrictMapObj allObjects]) {
						[map resetRelationship:self];
					}
				}
				[[[RKObjectManager sharedManager] objectStore] save];
				[[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];				
			}
			[self queryIDsForModel:className];	// THIS TRIGGERS A PRUNING
		}			
	}
	@catch (NSException * e) {
		NSLog(@"RestKit Load Error %@: %@", className, [e description]);
	}	
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"RESTKIT_DATA_ERROR"];
	[[MTStatusBarOverlay sharedMTStatusBarOverlay] postErrorMessage:NSLocalizedStringFromTable(@"Error During Update", @"AppAlerts", @"Status indicator for updates") duration:8];
	NSString *className = NSStringFromClass(objectLoader.objectClass);
	if (className)
		[self.activeUpdates removeObject:className];
	
	NSLog(@"RestKit Data error loading %@: %@", className, [error localizedDescription]);
}

#pragma mark -
#pragma mark Timestamp Files

- (NSString *)localDataTimestampForModel:(NSString *)classString {
	if (NSClassFromString(classString)) {
		NSFetchRequest *request = [NSClassFromString(classString) fetchRequest];
		NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:TXLUPDMGR_UPDATEDPROP ascending:NO];	// the most recent update will be the first item in the array (descending)
		[request setSortDescriptors:[NSArray arrayWithObject:desc]];
		[request setResultType:NSDictionaryResultType];												// This is necessary to limit it to specific properties during the fetch
		[request setPropertiesToFetch:[NSArray arrayWithObject:TXLUPDMGR_UPDATEDPROP]];						// We don't want to fetch everything, we'll get a huge ass memory hit otherwise.
		[desc release];
		
		return [[NSClassFromString(classString) objectWithFetchRequest:request] valueForKey:TXLUPDMGR_UPDATEDPROP];	// this relies on objectWithFetchRequest returning the object at index 0
	}
	else if ([classString isEqualToString:@"WnomAggregateObj"]) {
#if WNOMAGGREGATES_UPDATING
		NSError *error = nil;
		NSString *path = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:@"WnomAggregateObj.json"];
		NSString *json = [NSString stringWithContentsOfFile:path encoding:JSONDATA_ENCODING error:&error];
		if (!error && json) {
			NSArray *aggregates = [json objectFromJSONString];
			NSString *timestamp = [self localDataTimestampForArray:aggregates];
		}
		else {
			NSLog(@"DataModelUpdateManager:timestampForModel - error loading aggregates json - %@", path);
		}
#endif
	}
	
	return nil;
}

#if WNOMAGGREGATES_UPDATING
- (NSString *) localDataTimestampForArray:(NSArray *)entityArray {
	if (!entityArray || ![entityArray count])
		return [[NSDate date] timestampString];
	
	NSMutableArray *tempSorted = [[NSMutableArray alloc] initWithArray:entityArray];
	NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:JSONDATA_TIMESTAMPKEY ascending:NO];	// the most recent update will be the first item in the array (descending)
	[tempSorted sortUsingDescriptors:desc];
	[desc release];

	NSString *timestamp = nil;
	id object = [[tempSorted objectAtIndex:0] objectForKey:JSONDATA_TIMESTAMPKEY];
	if (!object) {
		NSLog(@"DataModelUpdateManager:timestampForArray - no 'updated' timestamp key found.");
	}
	else if ([object isKindOfClass:[NSString class]])
		timestamp = object;
	else if ([object isKindOfClass:[NSDate class]])
		timestamp = [object timestampString];
	else {
		NSLog(@"DataModelUpdateManager:timestampForArray - Unexpected type in dictionary, wanted timestamp string, %@", [object description]);
	}

	[tempSorted release];
	return timestamp;
}
#endif

@end
