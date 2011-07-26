//
//  StatesListMetaLoader.m
//  Created by Gregory Combs on 7/19/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "StatesListMetaLoader.h"

#import "StateMetaLoader.h"
#import "JSONKit.h"
#import "UtilityMethods.h"
#import "TexLegeReachability.h"
#import "OpenLegislativeAPIs.h"
#import "TexLegeLibrary.h"
#import "NSDate+Helper.h"
#import "LoadingCell.h"

#define kStatesListCacheFile            @"StateMetaReadyList.json"
#define kStatesListDefaultsKey          @"all_ready_states"

@interface StatesListMetaLoader()
- (void)loadStatesListFromCache;
@end


@implementation StatesListMetaLoader
@synthesize states;
@synthesize updated;
@synthesize loadingStatus;

+ (id)sharedStatesListMeta
{
	static dispatch_once_t pred;
	static StatesListMetaLoader *foo = nil;
	
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}



- (id)init {
	if ((self=[super init])) {
        isLoading = NO;

        [[TexLegeReachability sharedTexLegeReachability] addObserver:self 
														  forKeyPath:@"openstatesConnectionStatus" 
															 options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) 
															 context:nil];
        
        [OpenLegislativeAPIs sharedOpenLegislativeAPIs];

            //Pull our cached list or from the app bundle
        [self loadStatesListFromCache];

	}
	return self;
}

- (void)dealloc {
    [[TexLegeReachability sharedTexLegeReachability] removeObserver:self forKeyPath:@"openstatesConnectionStatus"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
    
    self.updated = nil;
    nice_release(states);   // "self.states = nil;"  might try and do a load again...
    
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
	if (!IsEmpty(keyPath)) {
		if ([keyPath isEqualToString:@"openstatesConnectionStatus"]) {
			
			/*
             if ([change valueForKey:NSKeyValueChangeKindKey] == NSKeyValueChangeSetting) {
             id newVal = [change valueForKey:NSKeyValueChangeNewKey];
             }*/
			
			if ([TexLegeReachability openstatesReachable])
                [self downloadStatesList];
			else if (self.loadingStatus != LOADING_NO_NET) {
				self.loadingStatus = LOADING_NO_NET;
				[[NSNotificationCenter defaultCenter] postNotificationName:kStateMetaNotifyError object:nil];	
			}
		}
	}	
}

- (BOOL)isFeatureEnabled:(NSString *)feature forStateID:(NSString *)stateID {
    
    BOOL isEnabled = NO;
    
    NSCParameterAssert( (NO == IsEmpty(states)) && (NO == IsEmpty(stateID)) && (NO == IsEmpty(feature)) );
        
    NSDictionary *stateInfo = [self.states findWhereKeyPath:@"abbreviation" equals:stateID];
    if (stateInfo) {
        
        NSArray *features = [stateInfo objectForKey:@"feature_flags"];
        if (features && [features containsObject:feature]) {
            isEnabled = YES;
        }
    }
        
    return isEnabled;
}

- (BOOL)isFresh {
	// if we're over a half-hour old, it's time to refresh
	return (self.updated && ([[NSDate date] timeIntervalSinceDate:updated] < (3600*24)));    // under a day old
}


- (NSMutableArray *)states    {
    
    BOOL doLoad = [TexLegeReachability openstatesReachable];
    
    if ( (self.isFresh) &&			// IF we've updated recently **AND**
        (isLoading || states)       // we're already loading OR we have valid info for the list of states
       )
    {
        doLoad = NO;
    }
        
    if (doLoad) { 
        
        debug_NSLog(@"StatesListMeta is stale, need to refresh");
        
        [self downloadStatesList];
        
    }
    
	if (IsEmpty(states)) { // while we download, let's grab what we need from cache, temporarily
        
        [self loadStatesListFromCache];
        
    }
    
    return states;
}



- (void)loadStatesListFromCache {
	
	NSString *localPath = [[UtilityMethods applicationCachesDirectory] stringByAppendingPathComponent:kStatesListCacheFile];
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	if (NO == [fileManager fileExistsAtPath:localPath]) {
        
        // no cache yet, ... we need to get it from our app's bundle
        localPath = [[NSBundle mainBundle] pathForResource:@"StateMetaReadyList" ofType:@"json"];    
        
        // If we wanted to copy our default file to the cache location, we'd do this...
        // [fileManager copyItemAtPath:defaultStorePath toPath:storePath error:&error];
	}    
    
    NSData *jsonFile = [NSData dataWithContentsOfFile:localPath];
    
    if (jsonFile) {
        self.states = [jsonFile mutableObjectFromJSONData];  
    }
    
}


- (void)downloadStatesList {
    
	if (isLoading == YES)	// we're already working on it
		return;
	
	if ([TexLegeReachability openstatesReachable]) {
        isLoading = YES;
		self.loadingStatus = LOADING_ACTIVE;
        
        RKClient *osApiClient = [[OpenLegislativeAPIs sharedOpenLegislativeAPIs] osApiClient];
        NSDictionary *queryParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY, @"apikey",nil];
        
        RKRequest *request = [osApiClient get:@"/metadata/" queryParams:queryParams delegate:self];	
        if (request) {
            request.userData = kStatesListDefaultsKey;
            [request send];
        }
        
        
    }
    else if (self.loadingStatus != LOADING_NO_NET) {
		self.loadingStatus = LOADING_NO_NET;
		[[NSNotificationCenter defaultCenter] postNotificationName:kStatesListErrorKey object:nil];	
	}	
    
}


#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
    
	if (error && request) {
		debug_NSLog(@"Error loading state metadata from %@: %@", [request description], [error localizedDescription]);
	}
    
    isLoading = NO;

        // We had trouble loading the metadata online, so pull it up from the one in the documents folder
    
    [self loadStatesListFromCache];
    
    if (self.loadingStatus != LOADING_NO_NET) {
		self.loadingStatus = LOADING_NO_NET;
		[[NSNotificationCenter defaultCenter] postNotificationName:kStateMetaNotifyError object:nil];
	}    

}


- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
    
    isLoading = NO;
    
	if ([request isGET] && [response isOK]) {  
        
        self.loadingStatus = LOADING_IDLE;

		if (NO == [request.resourcePath hasPrefix:@"/metadata"]) 
			return;
		
        if (!request.userData || NO == [request.userData isEqual:kStatesListDefaultsKey]) {
            return;
        }
        
        ////// we've requested and received a list of all the available states, do something. //////
                
        id tempList = [response.body mutableObjectFromJSONData];
        
        if (!tempList || NO == [tempList isKindOfClass:[NSMutableArray class]] || IsEmpty(tempList))
            return;        
                
        self.updated = [NSDate date];
        
        LOG_EXPR(tempList);

        [self setStates:tempList];
        
        NSString *localPath = [[UtilityMethods applicationCachesDirectory] stringByAppendingPathComponent:kStatesListCacheFile];
        if (![response.body writeToFile:localPath atomically:YES]) {
            NSLog(@"StateListLoader: error writing cache to file: %@", localPath);
        }
		        
    }        
    else {
        NSLog(@"Errors retrieving data from Open States API");
        LOG_EXPR([request isGET]);
        LOG_EXPR([response isOK]);
        LOG_EXPR([response.body mutableObjectFromJSONData]);
        LOG_EXPR(response.body);        
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kStatesListLoadedKey object:nil];

}

@end