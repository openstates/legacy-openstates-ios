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
#import "SLFState.h"

#import "UtilityMethods.h"


@implementation StateMetaLoader
@synthesize resourcePath;
@synthesize resourceClass;
@synthesize selectedState;
@synthesize features;
@synthesize defaultFeatures;

@synthesize isFresh;
@synthesize updated;
@synthesize needsStateSelection;
@synthesize selectedSession = _selectedSession;

+ (id)sharedStateMeta
{
	static dispatch_once_t pred;
	static StateMetaLoader *foo = nil;
	
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}


- (id)initWithStateID:(NSString *)objID {
    if ((self = [super init])) {
        
        _sessions = nil;
        _sessionDisplayNames = nil;
		_selectedSession = nil;
        isLoading = NO;
        needsStateSelection = YES;
        
        self.defaultFeatures = [NSArray arrayWithObjects:
                                NSLocalizedStringFromTable(@"Legislators", @"StandardUI", @""),
                                NSLocalizedStringFromTable(@"Committees", @"StandardUI", @""),
                                NSLocalizedStringFromTable(@"Bills", @"StandardUI", @""),
                                NSLocalizedStringFromTable(@"District Maps", @"StandardUI", @""),
                                nil];
        
        self.features = self.defaultFeatures;
        
        self.resourceClass = [SLFState class];
        
        if (IsEmpty(objID)) {
            [[NSUserDefaults standardUserDefaults] synchronize];
            objID = [[NSUserDefaults standardUserDefaults] objectForKey:kMetaSelectedStateKey];
        }
        
        if (IsEmpty(objID)) {
            self.resourcePath = @"/metadata/";
        } else {
            self.resourcePath = [NSString stringWithFormat:@"/metadata/%@/", objID];            
            needsStateSelection = NO;
            [self setSelectedStateWithID:objID];
            
            NSDictionary *tempSessionDict = [[NSUserDefaults standardUserDefaults] objectForKey:kMetaSelectedStateSessionKey];
            if (tempSessionDict) {
                NSString *tempSession = [tempSessionDict objectForKey:objID];
                if (!IsEmpty(tempSession)) {
                    _selectedSession = [tempSession copy];
                }
            }
        }
        
        [self loadData];
        
    }
    return self;
}

- (id)init {
    return ([self initWithStateID:nil]);
}

- (void)dealloc {
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
	self.updated = nil;
    
	nice_release(_selectedSession);
	nice_release(_sessions);
    nice_release(_sessionDisplayNames);
    
    self.defaultFeatures = nil;
    self.features = nil;
	self.selectedState = nil;
    self.resourcePath = nil;
	[super dealloc];
}



- (BOOL)isFresh {
	// if we're over a half-hour old, it's time to refresh
	return (self.updated && ([[NSDate date] timeIntervalSinceDate:updated] < (3600*24)));    // under a day old
}


- (void)setSelectedState:(SLFState *)newObj {
	[selectedState release];
	selectedState = [newObj retain];
	
	if (selectedState) {
		//self.title = newObj.name;
        self.resourcePath = RKMakePathWithObject(@"/metadata/(abbreviation)/", newObj);
		[self loadData];
	}
}

- (void)setSelectedStateWithID:(NSString *)stateID {
	
	if (NO == IsEmpty(stateID)) {
		
		RKLogWarning(@"State Metadata: Changing state to %@", stateID);
        
		[[NSUserDefaults standardUserDefaults] setObject:stateID forKey:kMetaSelectedStateKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
        self.selectedState = [SLFState findFirstByAttribute:@"abbreviation" withValue:stateID];
	}
}

- (NSArray *)sessions {
	
	if (NO == IsEmpty(_sessions))
		return _sessions;
	
	nice_release(_sessions);
	_sessions = [[NSMutableArray alloc] init];
    	
	for (NSDictionary *term in self.selectedState.terms) {
		for (NSString *session in [term objectForKey:@"sessions"]) {
			if (!IsEmpty(session)) {
				[_sessions addObject:session];
            }
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


- (NSDictionary *)findSessionDisplayNames {
    
    if (IsEmpty(self.sessions))
        return nil;
    
    nice_release(_sessionDisplayNames);
    _sessionDisplayNames = [[NSMutableDictionary alloc] init];
    
    NSInteger index = 0;
    
    for (NSString *aSession in self.sessions) {
        
        NSString *temp = [self.selectedState displayNameForSession:aSession];
        
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
		
		NSDictionary *stateSession = [NSDictionary dictionaryWithObject:sessionID forKey:self.selectedState.abbreviation];
		[[NSUserDefaults standardUserDefaults] setObject:stateSession forKey:kMetaSelectedStateSessionKey];
		[[NSUserDefaults standardUserDefaults] synchronize];	
		
		
		if ([sessionID isEqual:_selectedSession])
			return; // it's no different, we're done.
		
		nice_release(_selectedSession);
		_selectedSession = [sessionID copy];
		
		RKLogWarning(@"State Metadata: Changing selected session to %@", sessionID);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kStateMetaNotifySessionChange object:nil];
        
	}
}

/////////////////////////////////////////////////////

- (BOOL)isFeatureEnabled:(NSString *)feature {
    
    return [self.selectedState isFeatureEnabled:feature];
    
}



- (void)loadData {
	if (!self.resourcePath)
		return;
	
    NSString *stateID = self.selectedState.abbreviation;
    if (IsEmpty(stateID) || isLoading)	// we're already working on it
		return;
    
    isLoading = YES;
    
    // Load the object model via RestKit	
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    RKObjectMapping* objMapping = [objectManager.mappingProvider objectMappingForClass:self.resourceClass];
    
	NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
								 SUNLIGHT_APIKEY, @"apikey",
								 nil];
	NSString *newPath = [self.resourcePath appendQueryParams:queryParams];
	
    [objectManager loadObjectsAtResourcePath:newPath objectMapping:objMapping delegate:self];

}


#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    
    isLoading = NO;
    
    if (error && objectLoader) {
        RKLogError(@"Error loading state metadata from %@: %@", [objectLoader description], [error localizedDescription]);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kStateMetaNotifyError object:nil];
}


- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    
    isLoading = NO;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
	[selectedState release];
	selectedState = [object retain];
    
    self.updated = [NSDate date];
        
    if (selectedState.featureFlags) {
        NSMutableArray *newFeatures = [[NSMutableArray alloc] initWithArray:self.defaultFeatures];
        
        if ([selectedState.featureFlags containsObject:@"events"]) {
            [newFeatures addObject:NSLocalizedStringFromTable(@"Events", @"StandardUI", @"")];
        }
        
        self.features = newFeatures;
        [newFeatures release];
    }
    
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
		NSString *savedSession = [tempSessionDict objectForKey:selectedState.abbreviation];
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

@end
