//
//  SLFRestKitManager.h
//  Created by Gregory Combs on 8/2/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@class SLFState;
@interface SLFRestKitManager : NSObject <RKObjectLoaderDelegate, RKRequestQueueDelegate, RKManagedObjectStoreDelegate>
+ (SLFRestKitManager *)sharedRestKit;
+ (void)showFailureAlertWithRequest:(RKRequest *)request error:(NSError *)error;
+ (NSString *)logFailureMessageForRequest:(RKRequest *)request error:(NSError *)error;
- (void)loadObjectsAtResourcePath:(NSString *)pathToLoad delegate:(id<RKObjectLoaderDelegate>)delegate withTimeout:(NSTimeInterval)timeoutSeconds;
- (void)preloadObjectsForState:(SLFState *)state;
- (RKObjectLoader *)objectLoaderForResourcePath:(NSString *)pathToLoad delegate:(id<RKObjectLoaderDelegate>)delegate withTimeout:(NSTimeInterval)timeoutSeconds;
@property (nonatomic,retain) RKClient *transClient;
@property (nonatomic,retain) RKClient *openStatesClient;
@end

#define SEED_DB_NAME @"SLFDataSeed.sqlite"
#define APP_DB_NAME @"SLFData.sqlite"
#define APP_MOMD_NAME @"SLFData"

