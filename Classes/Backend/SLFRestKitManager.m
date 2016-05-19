//
//  SLFRestKitManager.m
//  Created by Gregory Combs on 8/2/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFRestKitManager.h"
#import "SLFMappingsManager.h"
#import "SLFDataModels.h"
#import "SLFObjectCache.h"
#import "SLFAlertView.h"
#import "SLFGlobal.h"
#import <SLFRestKit/RKManagedObjectStore.h>

NSString * const kAPP_DB_PREFIX = @"SLFData";
NSString * const kAPP_DB_NAME = @"SLFData.sqlite";
NSString * const kAPP_MOMD_NAME = @"SLFData.momd";
NSString * const kSEED_DB_NAME = @"SLFDataSeed";

NSURL * kOPENSTATES_BASE_URL;
NSURL * kTRANSPARENCY_BASE_URL;

#define OPENSTATES_BASE_URL		kOPENSTATES_BASE_URL
#define TRANSPARENCY_BASE_URL   kTRANSPARENCY_BASE_URL

@interface SLFRestKitManager()
@property (nonatomic,strong) RKRequestQueue *preloadQueue;
- (RKManagedObjectStore *)attemptLoadObjectStoreAndFlushIfNeeded;
@end

@implementation SLFRestKitManager

+ (void)initialize
{
    [super initialize];
    kOPENSTATES_BASE_URL = [NSURL URLWithString:@"http://openstates.org/api/v1"];
    kTRANSPARENCY_BASE_URL = [NSURL URLWithString:@"http://transparencydata.com/api/1.0"];
}

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

        RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:kOPENSTATES_BASE_URL];
        objectManager.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
        
        RKManagedObjectStore *objectStore = [self attemptLoadObjectStoreAndFlushIfNeeded];        
        objectManager.objectStore = objectStore;  
        [RKObjectManager setSharedManager:objectManager];

        SLFObjectCache *cache = [[SLFObjectCache alloc] init];
        objectStore.managedObjectCache = cache;
        
        SLFMappingsManager *mapper = [[SLFMappingsManager alloc] init];
        [mapper registerMappings];
        
        _transClient = [[RKClient alloc] initWithBaseURL:kTRANSPARENCY_BASE_URL];
        _openStatesClient = [[RKClient alloc] initWithBaseURL:kOPENSTATES_BASE_URL];
    }
    return self;
}

- (void)dealloc
{
    [_transClient.requestQueue cancelAllRequests];
    [_openStatesClient.requestQueue cancelAllRequests];
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    if (_preloadQueue) {
        [_preloadQueue cancelAllRequests];
    }
}


#pragma mark -

- (Class)modelClassFromResourcePath:(NSString *)resourcePath
{
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

- (void)preloadResourcesForState:(SLFState *)state options:(SLFPreloadResourceOptions)options
{
    if (!state || options == SLFPreloadResourceNone)
        return;

    if (_preloadQueue == NULL)
    {
        _preloadQueue = [RKRequestQueue newRequestQueueWithName:@"PreLoadData"];
        _preloadQueue.delegate = self;
        _preloadQueue.concurrentRequestsLimit = 2;
        _preloadQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    }

    NSTimeInterval timeout = SLF_HOURS_TO_SECONDS(48);
    NSString *resourcePath = nil;
    NSMutableDictionary *queryParameters = [@{@"apikey": SUNLIGHT_APIKEY, @"stateID": state.stateID} mutableCopy];
    RKPathMatcher *matcher = [RKPathMatcher matcherWithPattern:@"/:entity/:stateID?apikey=:apikey"];

    if (options & SLFPreloadResourceMetadata)
    {
        queryParameters[@"entity"] = @"metadata";
        resourcePath = [matcher pathFromObject:queryParameters];
        [_preloadQueue addRequest:[self objectLoaderForResourcePath:resourcePath delegate:self withTimeout:timeout]];
    }

    if (options & SLFPreloadResourceBoundaries)
    {
        queryParameters[@"entity"] = @"districts";
        resourcePath = [matcher pathFromObject:queryParameters];
        [_preloadQueue addRequest:[self objectLoaderForResourcePath:resourcePath delegate:self withTimeout:timeout]];
    }

    matcher = [RKPathMatcher matcherWithPattern:@"/:entity?state=:stateID&apikey=:apikey"];

    if (options & SLFPreloadResourceEvents)
    {
        queryParameters[@"entity"] = @"events";
        resourcePath = [matcher pathFromObject:queryParameters];
        [_preloadQueue addRequest:[self objectLoaderForResourcePath:resourcePath delegate:self withTimeout:SLF_HOURS_TO_SECONDS(1)]];
    }

    if (options & SLFPreloadResourceCommittees)
    {
        queryParameters[@"entity"] = @"committees";
        resourcePath = [matcher pathFromObject:queryParameters];
        [_preloadQueue addRequest:[self objectLoaderForResourcePath:resourcePath delegate:self withTimeout:timeout]];
    }

    if (options & SLFPreloadResourceLegislators)
    {
        queryParameters[@"entity"] = @"legislators";
        resourcePath = [[matcher pathFromObject:queryParameters] stringByAppendingString:@"&active=true"];
        [_preloadQueue addRequest:[self objectLoaderForResourcePath:resourcePath delegate:self withTimeout:timeout]];
    }

    [_preloadQueue start];
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
        NSString *path = [[NSBundle mainBundle] pathForResource:kAPP_DB_PREFIX ofType:@"momd"];
        //NSAssert(path != NULL, @"Unable to determine path to RestKit resource model");
        NSURL *momURL = [NSURL fileURLWithPath:path];
        NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
//        objectStore = [[RKManagedObjectStore alloc] initWithStoreFilename:kAPP_DB_NAME storeType:NSSQLiteStoreType inDirectory:nil usingSeedDatabaseName:nil combinedObjectModel:mom delegate:self];
        objectStore = [[RKManagedObjectStore alloc] initWithStoreFilename:kAPP_DB_NAME inDirectory:nil usingSeedDatabaseName:nil managedObjectModel:mom delegate:self];

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
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        NSString *storeFilePath = [basePath stringByAppendingPathComponent:kAPP_DB_NAME];
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
    if (SLFTypeNonEmptyStringOrNil(errorText))
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
    if (SLFTypeNonEmptyStringOrNil(message))
        [SLFAlertView showWithTitle:NSLocalizedString(@"Network Data Error",@"") message:message buttonTitle:NSLocalizedString(@"Cancel",@"")];
}

@end
