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
#import "SLFAlertView.h"
#import "StateMetaLoader.h"
#import "TableDataSourceProtocol.h"

#define OPENSTATES_BASE_URL		@"http://openstates.sunlightlabs.com/api/v1"

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
        objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
        
        RKManagedObjectStore *objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:APP_DB_NAME];
        objectManager.objectStore = objectStore;        
        [RKObjectManager setSharedManager:objectManager];

        SLFObjectCache *cache = [[SLFObjectCache alloc] init];
        objectStore.managedObjectCache = cache;
        [cache release];
        
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

- (NSString *)rootKeyPathOfResourcePath:(NSString *)resourcePath {
    NSAssert(resourcePath != NULL, @"Resource path must not be NULL");
    NSCharacterSet *delimiters = [NSCharacterSet characterSetWithCharactersInString:@"/?"];
    NSArray *pathComponents = [resourcePath componentsSeparatedByCharactersInSet:delimiters];
    NSCParameterAssert(pathComponents && [pathComponents count]>1);
    NSString *keyPath = [pathComponents objectAtIndex:1];
    return keyPath;
}


- (void)loadObjectsAtResourcePath:(NSString *)pathToLoad delegate:(id<RKObjectLoaderDelegate>)delegate {
    NSCParameterAssert(pathToLoad != NULL);
    RKLogDebug(@"Loading data at path: %@", pathToLoad);
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:pathToLoad delegate:delegate block:^(RKObjectLoader* loader) {
        NSString *mappedKeyPath = [self rootKeyPathOfResourcePath:pathToLoad];
        loader.objectMapping = [objectManager.mappingProvider mappingForKeyPath:mappedKeyPath];
      //loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:self.resourceClass];
    }];
}


- (void)preloadObjectsForState:(SLFState *)state {
    if (!state)
        return;
    NSString *resourcePath = nil;
    NSMutableDictionary *queryParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys: SUNLIGHT_APIKEY, @"apikey", state.stateID, @"stateID", nil];
    RKPathMatcher *matcher = [RKPathMatcher matcherWithPattern:@"/:entity/:stateID?apikey=:apikey"];
    
    [queryParameters setObject:@"metadata" forKey:@"entity"];
    resourcePath = [matcher pathFromObject:queryParameters];
    [self loadObjectsAtResourcePath:resourcePath delegate:self];

    [queryParameters setObject:@"districts" forKey:@"entity"];
    resourcePath = [matcher pathFromObject:queryParameters];
    [self loadObjectsAtResourcePath:resourcePath delegate:self];
    
    matcher = [RKPathMatcher matcherWithPattern:@"/:entity?state=:stateID&apikey=:apikey"];

    [queryParameters setObject:@"committees" forKey:@"entity"];
    resourcePath = [matcher pathFromObject:queryParameters];
    [self loadObjectsAtResourcePath:resourcePath delegate:self];

    [queryParameters setObject:@"legislators" forKey:@"entity"];
    resourcePath = [[matcher pathFromObject:queryParameters] stringByAppendingString:@"&active=true"];
    [self loadObjectsAtResourcePath:resourcePath delegate:self];
}


- (void)stateChanged:(NSNotification *)notification {
    SLFState *state = [[StateMetaLoader sharedStateMeta] selectedState];
    if (!state)
        return;
    [self preloadObjectsForStateID:state.abbreviation];
}


- (NSArray *)registeredDataModels {
    return [[[[[RKObjectManager sharedManager] objectStore] managedObjectModel] entitiesByName] allKeys];
}


- (void) resetSavedDatabase:(id)sender {
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] objectStore];
  //[objectStore deletePersistantStoreUsingSeedDatabaseName:SEED_DB_NAME];
    [objectStore deletePersistantStore];
    [objectStore save];
    for (NSString *className in [self registeredDataModels]) {
        NSString *notification = [NSString stringWithFormat:@"RESTKIT_LOADED_%@", [className uppercaseString]];
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
    }
}


#pragma mark -
#pragma mark RKObjectLoaderDelegate methods


- (void)objectLoaderDidFinishLoading:(RKObjectLoader*)objectLoader {
    RKLogDebug(@"Object Loader Finished: %@", objectLoader.resourcePath);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataError object:self];
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
