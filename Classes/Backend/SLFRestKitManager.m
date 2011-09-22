//
//  SLFRestKitManager.m
//  Created by Gregory Combs on 8/2/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

#import "SLFRestKitManager.h"
#import "SLFMappingsManager.h"
#import "SLFDataModels.h"
#import "SLFObjectCache.h"

#define OPENSTATES_BASE_URL		@"http://openstates.org/api/v1"

@implementation SLFRestKitManager

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
        RKLogConfigureByName("RestKit/Network", RKLogLevelCritical);
        RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelWarning);
        RKLogConfigureByName("RestKit/CoreData", RKLogLevelDebug);

        RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:OPENSTATES_BASE_URL];
        objectManager.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
        
        RKManagedObjectStore *objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:APP_DB_NAME];
        objectManager.objectStore = objectStore;        
        [RKObjectManager setSharedManager:objectManager];

        SLFObjectCache *cache = [[SLFObjectCache alloc] init];
        objectStore.managedObjectCache = cache;
        [cache release];
        
        SLFMappingsManager *mapper = [[SLFMappingsManager alloc] init];
        [mapper registerMappings];
        [mapper release];
        
    }
    return self;
}


- (void)dealloc {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    if (__preloadQueue) {
        [__preloadQueue cancelAllRequests];
        [__preloadQueue release];
        __preloadQueue = nil;
    }
    [super dealloc];
}


#pragma mark -

- (Class)modelClassFromResourcePath:(NSString *)resourcePath {
    NSAssert(resourcePath != NULL, @"Resource path must not be NULL");
    NSCharacterSet *delimiters = [NSCharacterSet characterSetWithCharactersInString:@"/?"];
    NSArray *pathComponents = [resourcePath componentsSeparatedByCharactersInSet:delimiters];
    NSCParameterAssert(pathComponents && [pathComponents count]>1);
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


- (RKObjectLoader *)objectLoaderForResourcePath:(NSString *)pathToLoad {
    NSCParameterAssert(pathToLoad != NULL);
    RKLogDebug(@"Loading data at path: %@", pathToLoad);
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    RKObjectLoader * loader = [objectManager objectLoaderWithResourcePath:pathToLoad delegate:self];
    Class theClass = [self modelClassFromResourcePath:pathToLoad];
    loader.objectMapping = (RKObjectMapping *)[objectManager.mappingProvider objectMappingForClass:theClass];
    loader.method = RKRequestMethodGET;
    return loader;
}

- (void)loadObjectsAtResourcePath:(NSString *)pathToLoad delegate:(id<RKObjectLoaderDelegate>)delegate {
    RKObjectLoader *loader = [self objectLoaderForResourcePath:pathToLoad];
    loader.delegate = delegate;
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

    NSString *resourcePath = nil;
    NSMutableDictionary *queryParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys: SUNLIGHT_APIKEY, @"apikey", state.stateID, @"stateID", nil];
    RKPathMatcher *matcher = [RKPathMatcher matcherWithPattern:@"/:entity/:stateID?apikey=:apikey"];
    
    [queryParameters setObject:@"metadata" forKey:@"entity"];
    resourcePath = [matcher pathFromObject:queryParameters];
    [__preloadQueue addRequest:[self objectLoaderForResourcePath:resourcePath]];

    [queryParameters setObject:@"districts" forKey:@"entity"];
    resourcePath = [matcher pathFromObject:queryParameters];
    [__preloadQueue addRequest:[self objectLoaderForResourcePath:resourcePath]];
    
    matcher = [RKPathMatcher matcherWithPattern:@"/:entity?state=:stateID&apikey=:apikey"];

    [queryParameters setObject:@"committees" forKey:@"entity"];
    resourcePath = [matcher pathFromObject:queryParameters];
    [__preloadQueue addRequest:[self objectLoaderForResourcePath:resourcePath]];

    [queryParameters setObject:@"legislators" forKey:@"entity"];
    resourcePath = [[matcher pathFromObject:queryParameters] stringByAppendingString:@"&active=true"];
    [__preloadQueue addRequest:[self objectLoaderForResourcePath:resourcePath]];
    
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


#pragma mark -
#pragma mark Common Alerts

+ (void) showFailureAlertWithRequest:(RKRequest *)request error:(NSError *)error {
    NSString *errorDesc = [error localizedDescription];
    if (!errorDesc)
        errorDesc = @"";
    RKLogError(@"RestKit Error -");
    RKLogError(@"    request: %@", request);
    RKLogError(@"    loadData: %@", errorDesc);
}


@end
