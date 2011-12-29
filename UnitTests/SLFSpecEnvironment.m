// The following is practically verbatim of RestKit's RKSpecEnvironment.

#import "SLFSpecEnvironment.h"
#import "APIKeys.h"
#import <RestKit/CoreData/NSManagedObject+ActiveRecord.h>
#import "SLFObjectCache.h"

BOOL IsEmpty(NSObject * thing) {
    return thing == nil
    || ([[NSNull null] isEqual:thing])
    || ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)] && [(NSArray *)thing count] == 0);
}

NSString* SLFSpecMIMETypeForFixture(NSString* fileName);

NSString* SLFSpecGetBaseURL(void) {    
    #ifdef OPENSTATES_BASE_URL
    return OPENSTATES_BASE_URL;
    #else
    return @"http://openstates.org/api/v1";
    #endif
}

RKClient* SLFSpecNewClient(void) {    
    RKClient* client = [RKClient clientWithBaseURL:SLFSpecGetBaseURL()];
    [RKClient setSharedClient:client];    
    [client release];
    client.requestQueue.suspended = NO;
    return client;
}

RKObjectManager* SLFSpecNewObjectManager(void) {
    RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:SLFSpecGetBaseURL()];
    [RKObjectManager setSharedManager:objectManager];
    [RKClient setSharedClient:objectManager.client];
    
        // This allows the manager to determine state.
        //[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    
    return objectManager;
}

RKManagedObjectStore* SLFSpecNewManagedObjectStore(void) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    RKManagedObjectStore* store = [RKManagedObjectStore objectStoreWithStoreFilename:@"StatesLegeSpecs.sqlite" inDirectory:libraryPath usingSeedDatabaseName:nil managedObjectModel:nil delegate:nil];
    [store deletePersistantStore];
    RKObjectManager* objectManager = SLFSpecNewObjectManager();
    objectManager.objectStore = store;
    return store;
}

void SLFSpecRestKitEnvironment(void) {
    RKObjectManager* manager = SLFSpecNewObjectManager();
    NSCAssert(manager, @"Failed to create an object manager.");
    RKManagedObjectStore* store = SLFSpecNewManagedObjectStore();
    NSCAssert(store, @"Failed to create a managed object store.");
    manager.objectStore = store;
    NSManagedObjectContext* context = [store managedObjectContext];
    NSCAssert(context, @"Failed to find a shared managed object context.");
    SLFObjectCache *cache = [[SLFObjectCache alloc] init];
    store.managedObjectCache = cache;
    [cache release];
}

void SLFSpecClearCacheDirectory(void) {
    NSError* error = nil;
    NSString* cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:cachePath error:&error];
    if (success) {
        RKLogInfo(@"Cleared cache directory...");
        success = [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success) {
            RKLogError(@"Failed creation of cache path '%@': %@", cachePath, [error localizedDescription]);
        }
    } else {
        RKLogError(@"Failed to clear cache path '%@': %@", cachePath, [error localizedDescription]);
    }
}

    // Read a fixture from the app bundle
NSString* SLFSpecReadFixture(NSString* fileName) {
    NSError* error = nil;
    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
	NSString* fixtureData = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (fixtureData == nil && error) {
        [NSException raise:nil format:@"Failed to read contents of fixture '%@'. Did you add it to the app bundle? Error: %@", fileName, [error localizedDescription]];
    }
	return fixtureData;
}

NSString* SLFSpecMIMETypeForFixture(NSString* fileName) {
    NSString* extension = [[fileName pathExtension] lowercaseString];
    if ([extension isEqualToString:@"xml"]) {
        return RKMIMETypeXML;
    } else if ([extension isEqualToString:@"json"]) {
        return RKMIMETypeJSON;
    } else {
        return nil;
    }
}

id SLFSpecParseFixture(NSString* fileName) {
    NSError* error = nil;
    NSString* data = SLFSpecReadFixture(fileName);
    NSString* MIMEType = SLFSpecMIMETypeForFixture(fileName);
    id<RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:MIMEType];
    id object = [parser objectFromString:data error:&error];
    if (object == nil) {
        RKLogCritical(@"Failed to parse JSON fixture '%@'. Error: %@", fileName, [error localizedDescription]);
        return nil;
    }
    
    return object;
}

void SLFSpecSpinRunLoopWithDuration(NSTimeInterval timeInterval) {
    BOOL waiting = YES;
	NSDate* startDate = [NSDate date];
	while (waiting) {		
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
		if ([[NSDate date] timeIntervalSinceDate:startDate] > timeInterval) {
			waiting = NO;
		}
        usleep(100);
	}
}


