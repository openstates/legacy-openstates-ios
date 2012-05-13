//
//  SLFRestKitManager.m
//  Created by Gregory Combs on 8/2/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

#import "SLFRestKitManager.h"
#import "SLFMappingsManager.h"
#import "SLFDataModels.h"
#import "SLFObjectCache.h"
#import "SLFAlertView.h"
#import <RestKit/CoreData/CoreData.h>

#define OPENSTATES_BASE_URL		@"http://openstates.org/api/v1"
#define TRANSPARENCY_BASE_URL   @"http://transparencydata.com/api/1.0"
#define BOUNDARY_BASE_URL       @"http://pentagon.sunlightlabs.net/1.0"

@interface SLFRestKitManager()
@property (nonatomic,retain) RKRequestQueue *preloadQueue;
- (RKManagedObjectStore *)attemptLoadObjectStoreAndFlushIfNeeded;
@end

@implementation SLFRestKitManager
@synthesize transClient;
@synthesize openStatesClient;
@synthesize boundaryClient;
@synthesize preloadQueue = __preloadQueue;

+ (SLFRestKitManager *)sharedRestKit
{
	static dispatch_once_t pred;
	static SLFRestKitManager *foo = nil;
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}


- (id)init {
    self = [super init];
    if (self) {
        RKLogConfigureByName("RestKit/Network", RKLogLevelInfo);
        RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelWarning);
        RKLogConfigureByName("RestKit/CoreData", RKLogLevelInfo);
        RKLogConfigureByName("RestKit/UI", RKLogLevelInfo);

        RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:OPENSTATES_BASE_URL];
        objectManager.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
        
        RKManagedObjectStore *objectStore = [self attemptLoadObjectStoreAndFlushIfNeeded];        
        objectManager.objectStore = objectStore;  
        [RKObjectManager setSharedManager:objectManager];

        SLFObjectCache *cache = [[SLFObjectCache alloc] init];
        objectStore.managedObjectCache = cache;
        [cache release];
        
        SLFMappingsManager *mapper = [[SLFMappingsManager alloc] init];
        [mapper registerMappings];
        [mapper release];        
        
        self.transClient = [RKClient clientWithBaseURL:TRANSPARENCY_BASE_URL];
        self.openStatesClient = [RKClient clientWithBaseURL:OPENSTATES_BASE_URL];
        self.boundaryClient = [RKClient clientWithBaseURL:BOUNDARY_BASE_URL];
    }
    return self;
}

- (void)dealloc {
    [self.transClient.requestQueue cancelAllRequests];
    self.transClient = nil;
    [self.openStatesClient.requestQueue cancelAllRequests];
    self.openStatesClient = nil;
    [self.boundaryClient.requestQueue cancelAllRequests];
    self.boundaryClient = nil;
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    if (__preloadQueue) {
        [__preloadQueue cancelAllRequests];
    }
    self.preloadQueue = nil;
    [super dealloc];
}


#pragma mark -

- (Class)modelClassFromResourcePath:(NSString *)resourcePath {
    NSAssert(resourcePath != NULL, @"Resource path must not be NULL");
    NSCharacterSet *delimiters = [NSCharacterSet characterSetWithCharactersInString:@"/?"];
    NSArray *pathComponents = [resourcePath componentsSeparatedByCharactersInSet:delimiters];
    NSParameterAssert(pathComponents && [pathComponents count]>1);
    NSString *keyPath = [pathComponents objectAtIndex:1];
    Class theClass = nil;
    if ([keyPath isEqualToString:@"metadata"])
        theClass = [SLFState class];
    else if ([keyPath isEqualToString:@"legislators"])
        theClass = [SLFLegislator class];
    else if ([keyPath isEqualToString:@"districts"])
        theClass = [SLFDistrict class];
    else if ([keyPath isEqualToString:@"committees"])
        theClass = [SLFCommittee class];
    else if ([keyPath isEqualToString:@"events"])
        theClass = [SLFEvent class];
    else if ([keyPath isEqualToString:@"bills"])
        theClass = [SLFBill class];
    NSAssert(theClass != NULL, @"Something went wrong ... couldn't find the right class.");
    return theClass;
}


- (RKObjectLoader *)objectLoaderForResourcePath:(NSString *)pathToLoad delegate:(id<RKObjectLoaderDelegate>)delegate withTimeout:(NSTimeInterval)timeoutSeconds {
    NSParameterAssert(pathToLoad != NULL);
    RKLogDebug(@"Loading data at path: %@", pathToLoad);
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    RKObjectLoader * loader = [objectManager objectLoaderWithResourcePath:pathToLoad delegate:delegate];
    Class theClass = [self modelClassFromResourcePath:pathToLoad];
    loader.objectMapping = (RKObjectMapping *)[objectManager.mappingProvider objectMappingForClass:theClass];
    loader.method = RKRequestMethodGET;
    loader.cacheTimeoutInterval = timeoutSeconds;
    loader.URLRequest.timeoutInterval = 30;
    return loader;
}

- (void)loadObjectsAtResourcePath:(NSString *)pathToLoad delegate:(id<RKObjectLoaderDelegate>)delegate withTimeout:(NSTimeInterval)timeoutSeconds {
    RKObjectLoader *loader = [self objectLoaderForResourcePath:pathToLoad delegate:delegate withTimeout:timeoutSeconds];
    [loader send];
}

- (void)preloadObjectsForState:(SLFState *)state {
    if (!state)
        return;

    if (__preloadQueue == NULL) {
        __preloadQueue = [RKRequestQueue newRequestQueueWithName:@"PreLoadData"];
        __preloadQueue.delegate = self;
        __preloadQueue.concurrentRequestsLimit = 2;
        __preloadQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    }

    NSTimeInterval timeout = SLF_HOURS_TO_SECONDS(48);
    NSString *resourcePath = nil;
    NSMutableDictionary *queryParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys: SUNLIGHT_APIKEY, @"apikey", state.stateID, @"stateID", nil];
    RKPathMatcher *matcher = [RKPathMatcher matcherWithPattern:@"/:entity/:stateID?apikey=:apikey"];
    
    [queryParameters setObject:@"metadata" forKey:@"entity"];
    resourcePath = [matcher pathFromObject:queryParameters];
    [__preloadQueue addRequest:[self objectLoaderForResourcePath:resourcePath delegate:self withTimeout:timeout]];

    [queryParameters setObject:@"districts" forKey:@"entity"];
    resourcePath = [matcher pathFromObject:queryParameters];
    [__preloadQueue addRequest:[self objectLoaderForResourcePath:resourcePath delegate:self withTimeout:timeout]];
    
    matcher = [RKPathMatcher matcherWithPattern:@"/:entity?state=:stateID&apikey=:apikey"];

/*
    [queryParameters setObject:@"events" forKey:@"entity"];
    resourcePath = [matcher pathFromObject:queryParameters];
    [__preloadQueue addRequest:[self objectLoaderForResourcePath:resourcePath delegate:self withTimeout:SLF_HOURS_TO_SECONDS(1)]];
*/
    
    [queryParameters setObject:@"committees" forKey:@"entity"];
    resourcePath = [matcher pathFromObject:queryParameters];
    [__preloadQueue addRequest:[self objectLoaderForResourcePath:resourcePath delegate:self withTimeout:timeout]];

    [queryParameters setObject:@"legislators" forKey:@"entity"];
    resourcePath = [[matcher pathFromObject:queryParameters] stringByAppendingString:@"&active=true"];
    [__preloadQueue addRequest:[self objectLoaderForResourcePath:resourcePath delegate:self withTimeout:timeout]];
    
    [__preloadQueue start];
    
}


#pragma mark -
#pragma mark RKObjectLoaderDelegate methods


- (void)objectLoaderDidFinishLoading:(RKObjectLoader*)objectLoader {
    RKLogDebug(@"Object Loader Finished: %@", objectLoader.resourcePath);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
}

#pragma mark - RKManagedObjectStoreDelegate

- (void)managedObjectStore:(RKManagedObjectStore *)objectStore didFailToCreatePersistentStoreCoordinatorWithError:(NSError *)error {
    RKLogError(@"Failed to create the persistent store coordinator: %@", error);
}

- (void)managedObjectStore:(RKManagedObjectStore *)objectStore didFailToDeletePersistentStore:(NSString *)storePath error:(NSError *)error {
    RKLogError(@"Failed to delete the Core Data store file: %@", error);
}

- (RKManagedObjectStore *)attemptLoadObjectStore {
    RKManagedObjectStore *objectStore = nil;
    @try {
        NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
        objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:APP_DB_NAME usingSeedDatabaseName:nil managedObjectModel:mom delegate:self];
    }
    @catch (NSException *exception) {
        RKLogError(@"An exception ocurred while attempting to load/build the Core Data store file: %@", exception);
    }
    return objectStore;
}

- (RKManagedObjectStore *)attemptLoadObjectStoreAndFlushIfNeeded {
    RKManagedObjectStore *objectStore = [self attemptLoadObjectStore];
    if (!objectStore) {
        RKLogWarning(@"Attempting to delete and recreate the Core Data store file.");
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        NSString *storeFilePath = [basePath stringByAppendingPathComponent:APP_DB_NAME];
        NSURL* storeUrl = [NSURL fileURLWithPath:storeFilePath];
        NSError* error = nil;
        @try {
            if (![[NSFileManager defaultManager] removeItemAtPath:storeUrl.path error:&error]) {
                [self managedObjectStore:objectStore didFailToDeletePersistentStore:storeFilePath error:error];
            }
        }
        @catch (NSException *exception) {
            RKLogError(@"An exception ocurred while attempting to delete the Core Data store file: %@", exception);
        }
        objectStore = [self attemptLoadObjectStore];
    }
    return objectStore;
}

#pragma mark -
#pragma mark Common Alerts

+ (NSString *)logFailureMessageForRequest:(RKRequest *)request error:(NSError *)error {
    NSString *message = NSLocalizedString(@"Network Data Error",@"");
    NSString *errorText = (error) ? [error localizedDescription] : @"";
    if (!IsEmpty(errorText))
        message = [errorText stringByReplacingOccurrencesOfString:SUNLIGHT_APIKEY withString:@"<APIKEY>"];
    RKLogError(@"RestKit Error -");
    if (request)
        RKLogError(@"    resourcePath: %@", request.resourcePath);
    RKLogError(@"    request URL: %@", request.URL);
    RKLogError(@"    error: %@", message);
    return message;
}

+ (void)showFailureAlertWithRequest:(RKRequest *)request error:(NSError *)error {
    NSString *message = [SLFRestKitManager logFailureMessageForRequest:request error:error];
    if (!IsEmpty(message))
        [SLFAlertView showWithTitle:NSLocalizedString(@"Network Data Error",@"") message:message buttonTitle:NSLocalizedString(@"Cancel",@"")];
}

@end
