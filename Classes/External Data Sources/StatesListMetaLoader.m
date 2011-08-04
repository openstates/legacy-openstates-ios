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
#import "SLFState.h"

#import "UtilityMethods.h"
#import "TexLegeReachability.h"
#import "LoadingCell.h"


@implementation StatesListMetaLoader
@synthesize resourcePath;
@synthesize resourceClass;
@synthesize states;
@synthesize updated;
@synthesize loadingStatus;

+ (id)sharedStatesLoader
{
	static dispatch_once_t pred;
	static StatesListMetaLoader *foo = nil;
	
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}



- (id)init {
	if ((self=[super init])) {
        isLoading = NO;

        self.resourceClass = [SLFState class];
        self.resourcePath = @"/metadata/";

        [[TexLegeReachability sharedTexLegeReachability] addObserver:self 
														  forKeyPath:@"openstatesConnectionStatus" 
															 options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) 
															 context:nil];
        
        // Load statuses from core data
        [self loadDataFromDataStore];
        [self loadData];
        
	}
	return self;
}

- (void)dealloc {
    [[TexLegeReachability sharedTexLegeReachability] removeObserver:self forKeyPath:@"openstatesConnectionStatus"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
    
    self.updated = nil;
    self.resourcePath = nil;
    
    nice_release(states);
    
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
                [self loadData];
			else if (self.loadingStatus != LOADING_NO_NET) {
				self.loadingStatus = LOADING_NO_NET;
				[[NSNotificationCenter defaultCenter] postNotificationName:kStatesListErrorKey object:nil];	
			}
		}
	}	
}

- (BOOL)isFeatureEnabled:(NSString *)feature forStateID:(NSString *)stateID {
    
    BOOL isEnabled = NO;
    
    NSCParameterAssert( (NO == IsEmpty(states)) && (NO == IsEmpty(stateID)) && (NO == IsEmpty(feature)) );
        
    SLFState *stateInfo = [SLFState findFirstByAttribute:@"abbreviation" withValue:stateID];
    if (stateInfo) {
        if (stateInfo.featureFlags && [stateInfo.featureFlags containsObject:feature]) {
            isEnabled = YES;
        }
    }
        
    return isEnabled;
}

- (BOOL)isFresh {
	// if we're over a half-hour old, it's time to refresh
	return (self.updated && ([[NSDate date] timeIntervalSinceDate:updated] < (3600*24)));    // under a day old
}


- (NSArray *)states    {
    
    BOOL doLoad = [TexLegeReachability openstatesReachable];
    
    if ( (self.isFresh) &&			// IF we've updated recently **AND**
        (isLoading || states)       // we're already loading OR we have valid info for the list of states
       )
    {
        doLoad = NO;
    }
        
    if (doLoad) { 
        
        RKLogDebug(@"StatesListMeta is stale, need to refresh");
        
        [self loadData];
        
    }
    
	if (IsEmpty(states)) { // while we download, let's grab what we need from cache, temporarily
        
        [self loadDataFromDataStore];
        
    }
    
    return states;
}


- (void)loadDataFromDataStore {
    self.states = nil;
	NSFetchRequest* request = [SLFState fetchRequest];
	NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
	self.states = [SLFState objectsWithFetchRequest:request];
}


- (void)loadData {
    
    if (isLoading == YES)	// we're already working on it
		return;

    if ([TexLegeReachability openstatesReachable]) {
        isLoading = YES;
		self.loadingStatus = LOADING_ACTIVE;
        
        // Load the object model via RestKit	
        RKObjectManager* objectManager = [RKObjectManager sharedManager];
        
        RKObjectMapping* stateMapping = [objectManager.mappingProvider objectMappingForClass:self.resourceClass];
        
        
        NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                     SUNLIGHT_APIKEY, @"apikey",
                                     nil];
        NSString *newPath = [self.resourcePath appendQueryParams:queryParams];
        
        [objectManager loadObjectsAtResourcePath:newPath objectMapping:stateMapping delegate:self];
    }
    else if (self.loadingStatus != LOADING_NO_NET) {
		self.loadingStatus = LOADING_NO_NET;
		[[NSNotificationCenter defaultCenter] postNotificationName:kStatesListErrorKey object:nil];	
	}	    
}



#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    
    if (error && objectLoader) {
		RKLogError(@"Error loading state metadata from %@: %@", [objectLoader description], [error localizedDescription]);
	}
    
    isLoading = NO;
    
    // We had trouble loading the metadata online, so pull it up from the one in the documents folder
    
    [self loadDataFromDataStore];
    
    if (self.loadingStatus != LOADING_NO_NET) {
		self.loadingStatus = LOADING_NO_NET;
		[[NSNotificationCenter defaultCenter] postNotificationName:kStatesListErrorKey object:nil];
	}      
}


- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    isLoading = NO;
    self.loadingStatus = LOADING_IDLE;
    self.updated = [NSDate date];

    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
	self.states = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    RKLogDebug(@"%d States", [objects count]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kStatesListLoadedKey object:nil];

}


@end