//
//  SLFRestKitManager.h
//  Created by Gregory Combs on 8/2/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

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
@property (nonatomic,retain) RKClient *boundaryClient;
@end

#define SEED_DB_NAME @"SLFDataSeed.sqlite"
#define APP_DB_NAME @"SLFData.sqlite"

