//
//  DataModelUpdateManager.m
//  TexLege
//
//  Created by Gregory Combs on 1/26/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "DataModelUpdateManager.h"
#import "JSON.h"
#import "UtilityMethods.h"
#import "TexLegeReachability.h"
#import "TexLegeCoreDataUtils.h"
#import "MTStatusBarOverlay.h"
#import "LocalyticsSession.h"
#import "DistrictMapObj.h"

#define JSONDATA_TIMESTAMPFILE	@"dataVersion.json"
#define JSONDATA_IDKEY			@"id"
#define JSONDATA_TIMESTAMPKEY	@"updated"
#define JSONDATA_FILEKEY		@"resource"
#define JSONDATA_ENCODING		NSUTF8StringEncoding

#define TESTING 1	// turn this on to fake the updater into believing all remote data is newer than local.  

@interface DataModelUpdateManager (Private)
- (NSArray *) localDataTimestamps;
- (NSArray *) remoteDataTimestamps;
- (NSArray *) deltaLocalTimestamps:(NSArray *)local toRemote:(NSArray *)remote;
@end

@implementation DataModelUpdateManager

@synthesize availableUpdates, downloadedUpdates, statusBlurbsAndModels;

- (id) init {
	if (self=[super init]) {
		self.downloadedUpdates = [NSMutableArray array];
		
		self.statusBlurbsAndModels = [NSDictionary dictionaryWithObjectsAndKeys: 
									  @"Legislators", @"LegislatorObj",
									  @"Partisanship Scores", @"WnomObj",
									  @"Staffers", @"StafferObj",
									  @"Committees", @"CommitteeObj",
									  @"Committee Positions", @"CommitteePositionObj",
									  @"District Offices", @"DistrictOfficeObj",
									  @"Resources", @"LinkObj",
									  @"District Maps", @"DistrictMapObj",
									  @"Party Scores", @"WnomAggregateObj",
									  nil];		

	}
	return self;
}

- (void) dealloc {
	self.statusBlurbsAndModels = nil;
	self.downloadedUpdates = nil;
	self.availableUpdates = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Check & Perform Updates

- (void) checkAndAlertAvailableUpdates:(id)sender {
	if ([self isDataUpdateAvailable])
		[self alertHasUpdates:self];
}

- (BOOL) isDataUpdateAvailable {
	BOOL hasUpdate = NO;
	NSArray *local = [self localDataTimestamps];
	NSArray *remote = [self remoteDataTimestamps];
	if (local && remote) {
		self.availableUpdates = [self deltaLocalTimestamps:local toRemote:remote];
		hasUpdate = ([self.availableUpdates count] > 0);
	}
	return hasUpdate;
}

- (void) alertHasUpdates:(id)delegate {
	UIAlertView *updaterAlert = [[UIAlertView alloc] initWithTitle:@"Update Available" 
														   message:@"An optional interim data update for TexLege is available.  Would you like to download and install the new data?"  
														  delegate:delegate 
												 cancelButtonTitle:@"Cancel" 
												 otherButtonTitles:@"Update", nil];
	updaterAlert.tag = 6666;
	[updaterAlert show];
	[updaterAlert release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertView.firstOtherButtonIndex) {
		if (alertView.tag == 6666)
			[self performAvailableUpdates];
	}
}

- (void) performAvailableUpdates {
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"DATABASE_UPDATE_REQUEST"];

	[self.downloadedUpdates removeAllObjects];
	
	NSString *statusString = [NSString stringWithFormat:@"Downloading %d Updates", [self.availableUpdates count]];
	
	MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
	overlay.historyEnabled = YES;
	overlay.animation = MTStatusBarOverlayAnimationFallDown;  // MTStatusBarOverlayAnimationShrink
	overlay.detailViewMode = MTDetailViewModeHistory;         // enable automatic history-tracking and show in detail-view
	//overlay.delegate = self;
	overlay.progress = 0.0;
	
	[overlay postMessage:statusString animated:YES];

	
	for (NSString *update in self.availableUpdates) {
		[TexLegeCoreDataUtils loadDataFromRest:update delegate:self];
	}
	[[[RKObjectManager sharedManager] objectStore] save];
}


- (BOOL)checkUpdateFinished {
	BOOL success = self.availableUpdates && ([self.downloadedUpdates count] == [self.availableUpdates count]);
	CGFloat progress = (CGFloat)([self.downloadedUpdates count]) / (CGFloat)[self.availableUpdates count];
	[MTStatusBarOverlay sharedInstance].progress = progress;

	if (success) {
		[[MTStatusBarOverlay sharedInstance] postFinishMessage:@"Update Completed" duration:5];	
		self.availableUpdates = nil;
	}
	return success;
}

#pragma mark -
#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
	if (objects && [objects count]) {
		@try {
			NSString *className = NSStringFromClass([[objects objectAtIndex:0] class]);
			if (className) {
				NSString *notification = [NSString stringWithFormat:@"RESTKIT_LOADED_%@", [className uppercaseString]];
				debug_NSLog(@"%@ %d objects", notification, [objects count]);
				
				if ([className isEqualToString:@"DistrictMapObj"] || [className isEqualToString:@"LegislatorObj"])					
					for (DistrictMapObj *map in [DistrictMapObj allObjects])
						[map resetRelationship:self];
				
				[[[RKObjectManager sharedManager] objectStore] save];
				
				/*				NSError *error = nil;
				 [[[objectLoader managedObjectStore] managedObjectContext]save:&error];
				 if (error)
				 NSLog(@"RestKit save error while loading");
				 */
				[[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
				
				[self.downloadedUpdates addObject:className];
				NSString *statusString = [NSString stringWithFormat:@"Updated %@", [statusBlurbsAndModels objectForKey:className]];
				NSLog(@"%@", statusString);
				//[[MTStatusBarOverlay sharedInstance] postMessage:statusString animated:YES];				
				[self checkUpdateFinished];
			}			
		}
		@catch (NSException * e) {
			NSLog(@"RestKit Load Error: %@", [e description]);
		}
	}
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
	UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Data Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[alert show];
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"RESTKIT_DATA_ERROR"];
	NSLog(@"RestKit Data error: %@", [error localizedDescription]);
	
	[[MTStatusBarOverlay sharedInstance] postErrorMessage:@"Error During Update" duration:8];

}

#pragma mark -
#pragma mark Timestamp Files

- (NSArray *) localDataTimestamps {
	NSMutableArray *dataArray = [NSMutableArray array];
	
	NSArray *objects = [self.statusBlurbsAndModels allKeys];
	for (NSString *classString in objects) {
		if (NSClassFromString(classString)) {
			NSFetchRequest *request = [NSClassFromString(classString) fetchRequest];
			NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:JSONDATA_TIMESTAMPKEY ascending:NO];	// the most recent update will be the first item in the array (descending)
			[request setSortDescriptors:[NSArray arrayWithObject:desc]];
			[request setResultType:NSDictionaryResultType];												// This is necessary to limit it to specific properties during the fetch
			[request setPropertiesToFetch:[NSArray arrayWithObject:JSONDATA_TIMESTAMPKEY]];						// We don't want to fetch everything, we'll get a huge ass memory hit otherwise.
			[desc release];
			NSDictionary *vers = [[NSDictionary alloc] initWithObjectsAndKeys:
								  classString, JSONDATA_IDKEY,
								  [[NSClassFromString(classString) objectWithFetchRequest:request] valueForKey:JSONDATA_TIMESTAMPKEY], JSONDATA_TIMESTAMPKEY,
								  [NSString stringWithFormat:@"%@.json", classString], JSONDATA_FILEKEY,
								  nil];
			[dataArray addObject:vers];
			[vers release];
		}
	}
	
	NSSortDescriptor *idDesc = [[[NSSortDescriptor alloc] initWithKey:JSONDATA_IDKEY
								 ascending:YES
								  selector:@selector(localizedCompare:)] autorelease];
	[dataArray sortUsingDescriptors:[NSArray arrayWithObject:idDesc]];
	return dataArray;
}

- (NSArray *)remoteDataTimestamps {
	NSMutableArray *dataArray = nil;
	NSString *urlMethod = [NSString stringWithFormat:@"%@/%@", RESTKIT_BASE_URL, JSONDATA_TIMESTAMPFILE];
	NSURL *url = [NSURL URLWithString:urlMethod];

	if ([TexLegeReachability canReachHostWithURL:url alert:NO])
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

		NSError *error = nil;
		NSString * remoteVersionString = [NSString stringWithContentsOfURL:url encoding:JSONDATA_ENCODING error:&error];
		if (error) {
			NSLog(@"Error retrieving remote JSON data version file:%@", error);
		}
		if (remoteVersionString && [remoteVersionString length]) {
			NSArray *tempArray = [remoteVersionString JSONValue];
			if (!tempArray) {
				NSLog(@"Error parsing remote json data version string: %@", remoteVersionString);
			}
			else {
				dataArray = [NSMutableArray arrayWithArray:tempArray];
				NSSortDescriptor *idDesc = [[NSSortDescriptor alloc] initWithKey:JSONDATA_IDKEY ascending:YES selector:@selector(localizedCompare:)];
				[dataArray sortUsingDescriptors:[NSArray arrayWithObject:idDesc]];
				[idDesc release];
			}
		}
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
	else
		NSLog(@"Network is unreachable, cannot obtain remote json data version file.");
	return dataArray;
}

- (NSArray *)deltaLocalTimestamps:(NSArray *)local toRemote:(NSArray *)remote {
	NSMutableArray *different = [NSMutableArray array];
#if TESTING
	for (NSDictionary *remoteItem in remote) {
		[different addObject:[remoteItem objectForKey:JSONDATA_IDKEY]];
	}
#else
	if (local && remote && ![local isEqualToArray:remote]) {
		BOOL localIsLarger = [local count] > [remote count];
		NSArray *larger = localIsLarger ? local : remote;
		NSArray *smaller = localIsLarger ? remote : local;
		
		for (NSDictionary *largerItem in larger) {
			NSString *largeID = [largerItem objectForKey:JSONDATA_IDKEY];
			NSString *largeStamp = [largerItem objectForKey:JSONDATA_TIMESTAMPKEY];
			BOOL wasFound = NO;
			for (NSDictionary *smallerItem in smaller) {
				NSString *smallID = [smallerItem objectForKey:JSONDATA_IDKEY];
				NSString *smallStamp = [smallerItem objectForKey:JSONDATA_TIMESTAMPKEY];
				if ([largeID isEqualToString:smallID]) {
					if (![largeStamp isEqualToString:smallStamp] ) {
						NSDictionary *remoteItem = nil; 
						if (localIsLarger)
							remoteItem = smallerItem;
						else
							remoteItem = largerItem;
						[different addObject:remoteItem];
					}
					wasFound = YES;
					break;
				}
			}
			if (!wasFound && !localIsLarger) {
				[different addObject:largerItem];
			}
		}
	}
#endif
	NSLog(@"DataModelUpdateManager: Found %d Differences in Local vs. Remote Data Timestamps", [different count]);
	return different;
}


@end
