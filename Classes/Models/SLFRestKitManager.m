//
//  SLFRestKitManager.m
//  StatesLege
//
//  Created by Gregory Combs on 8/2/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "SLFRestKitManager.h"
#import "SLFMappingsManager.h"
#import "SLFObjectCache.h"
#import "LocalyticsSession.h"
#import "SLFAlertView.h"
#import "SLFDataModels.h"
#import "StateMetaLoader.h"

@implementation SLFRestKitManager

+ (id)sharedRestKit
{
	static dispatch_once_t pred;
	static SLFRestKitManager *foo = nil;
	
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}


- (id)init {
    self = [super init];
    if (self) {
        // Initialize RestKit
        RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:OPENSTATES_BASE_URL];
        objectManager.client.requestQueue.suspended = NO;

        // Enable automatic network activity indicator management
        [RKRequestQueue sharedQueue].showsNetworkActivityIndicatorWhenBusy = YES;
        
        // Initialize object store    
        RKManagedObjectStore *objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:APP_DB_NAME];
       
        /*
        SLFObjectCache *cache = [[SLFObjectCache alloc] init];
        objectStore.managedObjectCache = cache;
        [cache release];
         */
        
        objectManager.objectStore = objectStore;        
        [RKObjectManager setSharedManager:objectManager];
        
        SLFMappingsManager *mapper = [[SLFMappingsManager alloc] init];
        [mapper registerMappingsWithProvider:objectManager.mappingProvider];
        [mapper release];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stateChanged:) name:kStateMetaNotifyStateLoaded object:nil];

    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark -

- (NSArray *)registeredDataModels {
    return [[[[[RKObjectManager sharedManager] objectStore] managedObjectModel] entitiesByName] allKeys];
}

- (void) resetSavedDatabase:(id)sender {
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"DATABASE_RESET"];
    
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] objectStore];
    //[objectStore deletePersistantStoreUsingSeedDatabaseName:SEED_DB_NAME];
    [objectStore deletePersistantStore];
    [objectStore save];
    
    for (NSString *className in [self registeredDataModels]) {
        NSString *notification = [NSString stringWithFormat:@"RESTKIT_LOADED_%@", [className uppercaseString]];
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
    }
}

- (void)loadObjectsAtResourcePath:(NSString *)resourcePath withClass:(Class)resourceClass {
    RKLogDebug(@"Loading data at path: %@", resourcePath);
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    RKObjectMapping* objMapping = [objectManager.mappingProvider objectMappingForClass:resourceClass];
    [objectManager loadObjectsAtResourcePath:resourcePath objectMapping:objMapping delegate:self];
}

- (void)preloadObjectsForStateID:(NSString *)stateID {
    if (!stateID)
        return;
    
    NSString *rootPath = @"/legislators/";
    NSMutableDictionary *queryParameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                            @"true", @"active",
                                            SUNLIGHT_APIKEY, @"apikey",
                                            stateID, @"state",
                                            nil];
    NSString *resourcePath = [rootPath appendQueryParams:queryParameters];
    [self loadObjectsAtResourcePath:resourcePath withClass:[SLFLegislator class]];
    
    rootPath = @"/committees/";
    [queryParameters removeObjectForKey:@"active"];
    resourcePath = [rootPath appendQueryParams:queryParameters];
    [self loadObjectsAtResourcePath:resourcePath withClass:[SLFCommittee class]];
    
    rootPath = @"/districts/";
    [queryParameters removeObjectForKey:@"state"];
    resourcePath = [[rootPath stringByAppendingFormat:@"%@/", stateID] appendQueryParams:queryParameters];
    [self loadObjectsAtResourcePath:resourcePath withClass:[SLFDistrictMap class]];
    
    rootPath = @"/metadata/";
    resourcePath = [[rootPath stringByAppendingFormat:@"%@/", stateID] appendQueryParams:queryParameters];
    [self loadObjectsAtResourcePath:resourcePath withClass:[SLFState class]];
    
    [queryParameters release];
}

- (void)stateChanged:(NSNotification *)notification {
    SLFState *state = [[StateMetaLoader sharedStateMeta] selectedState];
    if (!state)
        return;
    [self preloadObjectsForStateID:state.abbreviation];
}

#pragma mark -
#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoaderDidFinishLoading:(RKObjectLoader*)objectLoader {
        //[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataUpdated object:self];
    RKLogDebug(@"Object Loader Finished: %@", objectLoader.resourcePath);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TABLE_DATA_ERROR" object:self];
}

#pragma mark -
#pragma mark Common Alerts

+ (void) showFailureAlertWithRequest:(RKRequest *)request error:(NSError *)error {

    NSString *errorDesc = [error localizedDescription];
    if (!errorDesc)
        errorDesc = @"";
    
    RKLogError(@"RestKit Error -");
    RKLogError(@"    request: %@", request);
    RKLogError(@"    loadData: %@", errorDesc);

    [SLFAlertView showWithTitle:NSLocalizedStringFromTable(@"Error During Update", @"AppAlerts", @"") 
                        message:[NSString stringWithFormat:@"%@\n\n%@",
                                 NSLocalizedStringFromTable(@"A network or server data error occurred.", @"AppAlerts", @""),
                                 errorDesc]  
                    buttonTitle:NSLocalizedStringFromTable(@"Cancel", @"StandardUI", @"")];
    
}


@end
