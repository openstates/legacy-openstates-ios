//
//  SLFRestKitManager.m
//  StatesLege
//
//  Created by Gregory Combs on 8/2/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "SLFRestKitManager.h"
#import "SLFMappingsManager.h"
#import "LocalyticsSession.h"
#import "SLFAlertView.h"

@implementation SLFRestKitManager
@synthesize boundaryManager;

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
        self.boundaryManager = [RKObjectManager objectManagerWithBaseURL:BOUNDARY_SERVICE_URL];
        
        // Enable automatic network activity indicator management
        [RKRequestQueue sharedQueue].showsNetworkActivityIndicatorWhenBusy = YES;
        
        // Initialize object store    
        RKManagedObjectStore *objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:APP_DB_NAME];
        objectManager.objectStore = objectStore;
        self.boundaryManager.objectStore = objectStore;
        
        [RKObjectManager setSharedManager:objectManager];
        
        SLFMappingsManager *mapper = [[SLFMappingsManager alloc] init];
        [mapper registerMappingsWithProvider:objectManager.mappingProvider];
        [mapper registerMappingsWithProvider:self.boundaryManager.mappingProvider];
        [mapper release];
    }
    return self;
}

- (void)dealloc {
    self.boundaryManager = nil;
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

#pragma mark -
#pragma mark Common Alerts

+ (void) showFailureAlertWithRequest:(RKRequest *)request error:(NSError *)error {

    NSString *errorDesc = [error localizedDescription];
    if (!errorDesc)
        errorDesc = @"";
    
    NSLog(@"RestKit Error -");
    NSLog(@"    request: %@", request);
    NSLog(@"    loadData: %@", errorDesc);

    [SLFAlertView showWithTitle:NSLocalizedStringFromTable(@"Error During Update", @"AppAlerts", @"") 
                        message:[NSString stringWithFormat:@"%@  \n\n%@",
                                 NSLocalizedStringFromTable(@"A network or server data error occurred.", @"AppAlerts", @""),
                                 errorDesc]  
                    buttonTitle:NSLocalizedStringFromTable(@"Cancel", @"StandardUI", @"")];
    
}


@end
