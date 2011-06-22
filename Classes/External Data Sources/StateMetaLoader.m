//
//  StateMetadataLoader.m
//  TexLege
//
//  Created by Gregory Combs on 6/10/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "StateMetaLoader.h"
#import <RestKit/Support/JSON/JSONKit/JSONKit.h>
#import "UtilityMethods.h"
#import "TexLegeReachability.h"
#import "OpenLegislativeAPIs.h"
#import "TexLegeLibrary.h"
#import "NSDate+Helper.h"

@interface StateMetaLoader (Private)
- (NSMutableDictionary *)metadataFromCache;
@end

@implementation StateMetaLoader
@synthesize isFresh;
@synthesize selectedState = _selectedState;

+ (id)sharedStateMeta
{
	static dispatch_once_t pred;
	static StateMetaLoader *foo = nil;
	
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}

+ (NSString *)nameForChamber:(NSInteger)chamber {
	NSString *name = nil;
	// prepare to make some assumptions
	if (chamber == HOUSE || chamber == SENATE) {
		NSDictionary *stateMeta = [[StateMetaLoader sharedStateMeta] stateMetadata];
		if (NO == IsEmpty(stateMeta)) {
			if (chamber == SENATE)
				name = [stateMeta objectForKey:kMetaUpperChamberNameKey];
			else {
				name = [stateMeta objectForKey:kMetaLowerChamberNameKey];
			}
			if (NO == IsEmpty(name)) {
				NSArray *words = [name componentsSeparatedByString:@" "];
				if ([words count] > 1 && [[words objectAtIndex:0] length] > 4) { // just to make sure we have a decent, single name
					name = [words objectAtIndex:0];
				}
			}
		}
	}
	return name;
}

- (id)init {
	if ((self=[super init])) {
		updated = nil;
		isFresh = NO;
		_currentSession = nil;
		_selectedState = nil;
		
		[[NSUserDefaults standardUserDefaults] synchronize];
		NSString *tempState = [[NSUserDefaults standardUserDefaults] objectForKey:kMetaSelectedStateKey];
		if (tempState) {
			_selectedState = [tempState copy];
		}
		
		[self metadataFromCache];
	}
	return self;
}

- (void)dealloc {
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
	nice_release(updated);
	nice_release(_metadata);
	nice_release(_currentSession);
	nice_release(_selectedState);
	
	[super dealloc];
}

- (void)setSelectedState:(NSString *)stateID {
	nice_release(_selectedState);
	nice_release(_currentSession);	// we reset this too, because chances are it's not applicable to this state
	
	if (NO == IsEmpty(stateID)) {
		_selectedState= [stateID copy];

		[[NSUserDefaults standardUserDefaults] setObject:stateID forKey:kMetaSelectedStateKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[self loadMetadataForState:stateID];
	}
}

- (NSMutableDictionary *)metadataFromCache {
	nice_release(_metadata);
	NSString *localPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kStateMetaFile];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:localPath]) {
		NSData *jsonFile = [NSData dataWithContentsOfFile:localPath];
		_metadata = [[jsonFile mutableObjectFromJSONData] retain];
	} else {
		_metadata = [[NSMutableDictionary alloc] init];
	}		
	return _metadata;
}
		
- (void)loadMetadataForState:(NSString *)stateID {
	RKRequest *request = nil;
	
	isFresh = NO;
	RKClient *osApiClient = [[OpenLegislativeAPIs sharedOpenLegislativeAPIs] osApiClient];
	NSDictionary *queryParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:osApiKeyValue, @"apikey",nil];
	NSString *method = [NSString stringWithFormat:@"/metadata/%@", stateID];
	request = [osApiClient get:method queryParams:queryParams delegate:self];	
	if (request) {
		request.userData = [NSDictionary dictionaryWithObjectsAndKeys:
							stateID, kMetaSelectedStateKey, nil];
	}
	else {
		[self request:nil didFailLoadWithError:nil];
	}
}

- (NSDictionary *)stateMetadata {
	NSDictionary *stateMeta = nil;
	if (NO == IsEmpty(_selectedState)) {
		stateMeta = [_metadata objectForKey:_selectedState];

		if (IsEmpty(stateMeta) || !isFresh || !updated || ([[NSDate date] timeIntervalSinceDate:updated] > (3600*24))) {	// if we're over a day old, let's refresh
			isFresh = NO;
			debug_NSLog(@"StateMetadata is stale, need to refresh");
			
			if (NO == IsEmpty(_selectedState)) {
				[self loadMetadataForState:_selectedState];
			}
		}
	}
	return stateMeta;
}

- (NSString *)currentSession {
	if (NO == IsEmpty(_currentSession))
		return _currentSession;
	NSDictionary *stateMeta = [_metadata objectForKey:_selectedState];
	
	NSMutableArray *terms = [[NSMutableArray alloc] initWithArray:[stateMeta objectForKey:kMetaSessionsAltKey]];
	NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"start_year" ascending:NO];
	[terms sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
			
	NSInteger maxyear = -1;
	NSString *foundSession = nil;
	
	for (NSDictionary *term in terms) {
		NSNumber *startYear = [term objectForKey:@"start_year"];
		//NSNumber *endYear = [term objectForKey:@"end_year"];
		NSInteger thisYear = [[NSDate date] year];
		if (startYear) {
			NSInteger startInt = [startYear integerValue];
			if (startInt > thisYear) {
				continue;
			}
			else if (startInt > maxyear) {
				maxyear = startInt;
				NSArray *sessions = [term objectForKey:@"sessions"];
				if (!IsEmpty(sessions)) {
					id latest = [sessions lastObject]; 
					if ([latest isKindOfClass:[NSString class]])
						foundSession = latest;
					else if ([latest isKindOfClass:[NSNumber class]])
						foundSession = [latest stringValue];
				}
			}
		}
	}

	if (!IsEmpty(foundSession)) {
		_currentSession = [foundSession copy];	
	}
	nice_release(terms);

	return _currentSession;	
}

#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
	isFresh = NO;

	if (error && request) {
		debug_NSLog(@"Error loading state metadata from %@: %@", [request description], [error localizedDescription]);
		[[NSNotificationCenter defaultCenter] postNotificationName:kStateMetaNotifyError object:nil];
	}

	// We had trouble loading the metadata online, so pull it up from the one in the documents folder
	if (NO == IsEmpty([self metadataFromCache])) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kStateMetaNotifyLoaded object:nil];
	}
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
	if ([request isGET] && [response isOK]) {  
		// Success! Let's take a look at the data  

		if (NO == [request.resourcePath hasPrefix:@"/metadata"]) 
			return;
		
		NSMutableDictionary *stateMeta = [response.body mutableObjectFromJSONData];
		if (IsEmpty(stateMeta)) {
			[self request:request didFailLoadWithError:nil];
			return;
		}
		
		NSString *wantedStateID = nil;
		if (request.userData) {	// try getting our new state id from our initial query info
			wantedStateID = [request.userData objectForKey:kMetaSelectedStateKey];
		}
		
		NSString *gotStateID = [stateMeta objectForKey:kMetaStateAbbrevKey];
		
		if (IsEmpty(wantedStateID) || IsEmpty(gotStateID) || NO == [wantedStateID isEqualToString:gotStateID]) {
			NSLog(@"StateMetaDataLoader: requested metadata for %@, but incoming data is for %@", wantedStateID, gotStateID);
			[self request:request didFailLoadWithError:nil];
		}
		
		nice_release(updated);
		updated = [[NSDate date] retain];
		
		if (NO == IsEmpty(gotStateID)) {
			[_metadata setObject:stateMeta forKey:gotStateID];
		
			NSString *localPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kStateMetaFile];
			if (![[_metadata JSONData] writeToFile:localPath atomically:YES])
				NSLog(@"StateMetadataLoader: error writing cache to file: %@", localPath);
			isFresh = YES;
			[[NSNotificationCenter defaultCenter] postNotificationName:kStateMetaNotifyLoaded object:nil];
			debug_NSLog(@"StateMetadata network download successful, archiving for prosperity.");
		}		
		else {
			[self request:request didFailLoadWithError:nil];
			return;
		}
	}
}

@end
