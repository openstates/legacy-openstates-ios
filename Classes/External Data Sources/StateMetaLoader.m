//
//  StateMetadataLoader.m
//  Created by Gregory Combs on 6/10/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "StateMetaLoader.h"
#import "StatesListMetaLoader.h"

#import "JSONKit.h"
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
@synthesize updated;
@synthesize needsStateSelection;
@synthesize selectedSession = _selectedSession;
@synthesize selectedState = _selectedState;

+ (id)sharedStateMeta
{
	static dispatch_once_t pred;
	static StateMetaLoader *foo = nil;
	
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}

- (id)init {
	if ((self=[super init])) {
		_sessions = nil;
        _sessionDisplayNames = nil;
		_selectedSession = nil;
		_selectedState = nil;
		_loadingStates = [[NSMutableArray alloc] init];
		
		[[NSUserDefaults standardUserDefaults] synchronize];
		NSString *tempState = [[NSUserDefaults standardUserDefaults] objectForKey:kMetaSelectedStateKey];
        
		if (!IsEmpty(tempState)) {
            
			_selectedState = [tempState copy];
            
            needsStateSelection = NO;
			
			NSDictionary *tempSessionDict = [[NSUserDefaults standardUserDefaults] objectForKey:kMetaSelectedStateSessionKey];
			if (tempSessionDict) {
				NSString *tempSession = [tempSessionDict objectForKey:tempState];
				
				if (!IsEmpty(tempSession)) {
					_selectedSession = [tempSession copy];
				}
			}
		}
        else {
            //TODO: we need to show a list of available states when there's no preexisting state selection

            needsStateSelection = YES;
        }
		
		[self metadataFromCache];
	}
	return self;
}

- (void)dealloc {
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
	self.updated = nil;
	nice_release(_metadata);
	nice_release(_selectedSession);
	nice_release(_sessions);
    nice_release(_sessionDisplayNames);
	nice_release(_selectedState);
	nice_release(_loadingStates);
	[super dealloc];
}



- (NSMutableDictionary *)metadataFromCache {
	
	nice_release(_metadata);
	nice_release(_sessions);
    nice_release(_sessionDisplayNames);
	nice_release(_selectedSession);
	
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
	
	if (IsEmpty(stateID) || [_loadingStates containsObject:stateID])	// we're already working on it
		return;
	
	[_loadingStates addObject:stateID];	// add it to our list of active loads
	
	RKClient *osApiClient = [[OpenLegislativeAPIs sharedOpenLegislativeAPIs] osApiClient];
	NSDictionary *queryParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY, @"apikey",nil];
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

- (BOOL)isFresh {
	// if we're over a half-hour old, it's time to refresh
	return (self.updated && ([[NSDate date] timeIntervalSinceDate:updated] < (3600*24)));    // under a day old
}

- (NSDictionary *)stateMetadata {    
    NSDictionary *stateMeta = nil;
	if (NO == IsEmpty(_selectedState)) {

        stateMeta = [_metadata objectForKey:_selectedState];

        BOOL doLoad = [TexLegeReachability openstatesReachable];
        
        BOOL isLoading = [ _loadingStates containsObject:_selectedState];
        
        if ( (self.isFresh) &&			// IF we've updated recently **AND**
            (isLoading || stateMeta)    // we're already loading OR we have valid info for the list of state
            )
        {
            doLoad = NO;
        }
        
        if (doLoad) { 
            
            debug_NSLog(@"StateMeta is stale, need to refresh");
            
            [self loadMetadataForState:_selectedState];
            
        }
        
    }    
    return stateMeta;
    
}

- (void)setSelectedState:(NSString *)stateID {
	
	if (NO == IsEmpty(stateID)) {
		
		NSLog(@"State Metadata: Changing state to %@", stateID);
        
		[[NSUserDefaults standardUserDefaults] setObject:stateID forKey:kMetaSelectedStateKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[self loadMetadataForState:stateID];
	}
}

- (NSArray *)sessions {
	
	if (NO == IsEmpty(_sessions))
		return _sessions;
	
	nice_release(_sessions);
	_sessions = [[NSMutableArray alloc] init];
	
	NSDictionary *stateMeta = [_metadata objectForKey:_selectedState];
	
	// WE'RE ASSUMING THAT THE SESSIONS ARE ALREADY SORTED!
	//
	// NSMutableArray *terms = [[NSMutableArray alloc] initWithArray:[stateMeta objectForKey:kMetaSessionTermsKey]];	
	// NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"start_year" ascending:NO];
	// [terms sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
	
	for (NSDictionary *term in [stateMeta objectForKey:kMetaSessionTermsKey]) {
		for (NSString *session in [term objectForKey:kMetaSessionsKey]) {
			if (!IsEmpty(session))
				[_sessions addObject:session];
		}
	}
		
	return _sessions;
	
}

- (NSString *)latestSession {
	return [self.sessions lastObject];
}

- (NSInteger)sessionIndexForDisplayName:(NSString *)displayName {
    NSInteger index = [self.sessions count];
    
    if (!IsEmpty(displayName) && self.sessionDisplayNames) {

        NSNumber *value = [self.sessionDisplayNames objectForKey:displayName];
        if (value) {
            index = [value integerValue];
        }            
    }
    
    return index;
    
}

- (NSString *)displayNameForSession:(NSString *)aSession {
    NSString *display = aSession;
    
    if (!IsEmpty(aSession)) {
        
        NSDictionary * details = [self.stateMetadata objectForKey:kMetaSessionsDetailsKey];
        if (details) {
            
            NSDictionary * sessionDetail = [details objectForKey:aSession];
            if (sessionDetail) {
    
                NSString * tempName = [sessionDetail objectForKey:kMetaSessionsDisplayNameKey];
                if (!IsEmpty(tempName)) {
                    
                    display = tempName;
                }
            }
        }
    }
    
    return display;
}


- (NSDictionary *)findSessionDisplayNames {
    
    if (IsEmpty(self.sessions))
        return nil;
    
    nice_release(_sessionDisplayNames);
    _sessionDisplayNames = [[NSMutableDictionary alloc] init];
    
    NSInteger index = 0;
    
    for (NSString *aSession in self.sessions) {
        
        NSString *temp = [self displayNameForSession:aSession];
        
        if (!IsEmpty(temp)) {
            [_sessionDisplayNames setObject:[NSNumber numberWithInt:index] forKey:temp];            
        }
        
        index++;
    }
    
    return _sessionDisplayNames;
}


- (NSDictionary *)sessionDisplayNames {
 
    if (!IsEmpty(_sessionDisplayNames))
        return _sessionDisplayNames;
    
    return [self findSessionDisplayNames];
}


- (NSString *)selectedSession {
	
	if (IsEmpty(_selectedSession)) {
				
		// default to returning the latest session, if no one has picked something yet.
		_selectedSession = [[self latestSession] copy];
	}
	
	return _selectedSession;
}

- (void)setSelectedSession:(NSString *)sessionID {
	
	// sanity check to make sure we're setting it to something sensible
	if (!IsEmpty(sessionID) && [self.sessions containsObject:sessionID]) {
		
		NSDictionary *stateSession = [NSDictionary dictionaryWithObject:sessionID forKey:self.selectedState];
		[[NSUserDefaults standardUserDefaults] setObject:stateSession forKey:kMetaSelectedStateSessionKey];
		[[NSUserDefaults standardUserDefaults] synchronize];	
		
		
		if ([sessionID isEqual:_selectedSession])
			return; // it's no different, we're done.
		
		nice_release(_selectedSession);
		_selectedSession = [sessionID copy];
		
		NSLog(@"State Metadata: Changing selected session to %@", sessionID);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kStateMetaNotifySessionChange object:nil];

	}
}

/////////////////////////////////////////////////////

- (BOOL)isFeatureEnabled:(NSString *)feature {
        
    /// just use what's in the cache, since we probably just loaded this
    StatesListMetaLoader *statesList = [StatesListMetaLoader sharedStatesListMeta];

    BOOL isEnabled = NO;
    
    if (self.selectedState && feature)
        isEnabled = [statesList isFeatureEnabled:feature forStateID:self.selectedState];
    
    
    return isEnabled;
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



#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
	if (error && request) {
		debug_NSLog(@"Error loading state metadata from %@: %@", [request description], [error localizedDescription]);
		[[NSNotificationCenter defaultCenter] postNotificationName:kStateMetaNotifyError object:nil];
	}

	// We had trouble loading the metadata online, so pull it up from the one in the documents folder
	if (NO == IsEmpty([self metadataFromCache])) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kStateMetaNotifyStateLoaded object:nil];
	}
}

// Gets called whenever we've new data for a given state ... we need to parse it's sessions
- (void)reloadMetaPropertiesForStateID:(id)gotStateID {
	
	NSCParameterAssert((gotStateID != NULL));
	[[NSUserDefaults standardUserDefaults] synchronize];

	//////////// Set the selected state to the one we've just loaded  //////////////
	
	nice_release(_selectedState);
	_selectedState = [gotStateID copy];
	nice_release(_sessions);
	[self sessions];
    
    nice_release(_sessionDisplayNames);
	
	//////////// Now set the selected session ///////////
	
	BOOL sessionChanged = YES;

	NSString *previousSession = _selectedSession;
	NSString *sessionToSave = [self latestSession];	// default to the latest session available
	
	// Look to see if the user has previously selected this state, and picked a session too
	NSDictionary *tempSessionDict = [[NSUserDefaults standardUserDefaults] objectForKey:kMetaSelectedStateSessionKey];
	if (tempSessionDict) {
		NSString *savedSession = [tempSessionDict objectForKey:gotStateID];
		if (!IsEmpty(savedSession)) {
	
			if ([savedSession isEqual:previousSession])
				sessionChanged = NO;
			else 
				sessionToSave = savedSession;
		}
	}			
	
	if (sessionChanged) {
		self.selectedSession = sessionToSave;	// this does a notification for us, and saves the new setting.
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kStateMetaNotifyStateLoaded object:nil];
	
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
			if (!IsEmpty(wantedStateID) && [_loadingStates containsObject:wantedStateID]) {
				[_loadingStates removeObject:wantedStateID];
			}			
		}
		
		NSString *gotStateID = [stateMeta objectForKey:kMetaStateAbbrevKey];
				
		
		if (IsEmpty(wantedStateID) || IsEmpty(gotStateID) || NO == [wantedStateID isEqualToString:gotStateID]) {
			NSLog(@"StateMetaDataLoader: requested metadata for %@, but incoming data is for %@", wantedStateID, gotStateID);
			[self request:request didFailLoadWithError:nil];
		}
		
        self.updated = [NSDate date];
		
		if (NO == IsEmpty(gotStateID)) {
			[_metadata setObject:stateMeta forKey:gotStateID];
		
			if ([_loadingStates containsObject:gotStateID]) {
				[_loadingStates removeObject:gotStateID];
			}
			
			
			///// Write the metadata dictionary to a cache file

			NSString *localPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kStateMetaFile];
			if (![[_metadata JSONData] writeToFile:localPath atomically:YES])
				NSLog(@"StateMetadataLoader: error writing cache to file: %@", localPath);
			
			[self reloadMetaPropertiesForStateID:gotStateID];
			
			debug_NSLog(@"StateMetadata network download successful, archiving for prosperity.");
		}		
		else {
			[self request:request didFailLoadWithError:nil];
			return;
		}
	}
    else {
        NSLog(@"Errors retrieving data from Open States API");
#if DEBUG
        LOG_EXPR([request isGET]);
        LOG_EXPR([response isOK]);
        LOG_EXPR([response.body mutableObjectFromJSONData]);
        LOG_EXPR(response.body);        
#endif
    }
}

@end
