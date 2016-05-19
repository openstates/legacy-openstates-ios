//
//  SLFRestKitManager.h
//  Created by Gregory Combs on 8/2/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <SLFRestKit/RestKit.h>
#import <SLFRestKit/CoreData.h>

/**
 *  A bitmask to specify which resources (if any) to preload upon selecting a state from the menu
 */
typedef NS_OPTIONS(NSUInteger, SLFPreloadResourceOptions) {

    /**
     *  Don't preload any resources.
     */
    SLFPreloadResourceNone = 0,

    /**
     *  Preload the new state's metadata.
     */
    SLFPreloadResourceMetadata = 1 << 1,

    /**
     *  Preload the state's legislators. @note: *Very* desirable.
     */
    SLFPreloadResourceLegislators = 1 << 2,

    /**
     *  Preload the state's committees. @note: desirable, particularly when used in conjunction with preloading legislators. 
     *  @see SLFPreloadResourceLegislators
     */
    SLFPreloadResourceCommittees = 1 << 3,

    /**
     *  Preload the state's district boundary geometry for maps.
     *  @warning This is an expensive operation that can tax the server and the client.
     */
    SLFPreloadResourceBoundaries = 1 << 4,

    /**
     *  Preload the state's calendar events (like committee meetings).
     *  @note Not all states support the events resource.
     */
    SLFPreloadResourceEvents = 1 << 5,

    /**
     *  Preload the minimal recommended resources for a state (metadata, legislators, and committees).
     */
    SLFPreloadMinimalResources = (SLFPreloadResourceMetadata | SLFPreloadResourceLegislators | SLFPreloadResourceCommittees),

    /**
     *  Preload all the available resources for the state.
     *  @warning See caveats for SLFPreloadResourceBoundaries, SLFPreloadResourceEvents
     */
    SLFPreloadAllResources = (SLFPreloadResourceMetadata | SLFPreloadResourceLegislators | SLFPreloadResourceCommittees | SLFPreloadResourceBoundaries | SLFPreloadResourceEvents),
};

@class SLFState;

@interface SLFRestKitManager : NSObject <RKObjectLoaderDelegate, RKRequestQueueDelegate, RKManagedObjectStoreDelegate>

+ (SLFRestKitManager *)sharedRestKit;
+ (void)showFailureAlertWithRequest:(RKRequest *)request error:(NSError *)error;
+ (NSString *)logFailureMessageForRequest:(RKRequest *)request error:(NSError *)error;
- (void)loadObjectsAtResourcePath:(NSString *)pathToLoad delegate:(id<RKObjectLoaderDelegate>)delegate withTimeout:(NSTimeInterval)timeoutSeconds;
- (void)preloadResourcesForState:(SLFState *)state options:(SLFPreloadResourceOptions)options;
- (RKObjectLoader *)objectLoaderForResourcePath:(NSString *)pathToLoad delegate:(id<RKObjectLoaderDelegate>)delegate withTimeout:(NSTimeInterval)timeoutSeconds;

@property (nonatomic,strong) RKClient *transClient;
@property (nonatomic,strong) RKClient *openStatesClient;

@end

extern NSURL * kOPENSTATES_BASE_URL;
extern NSURL * kTRANSPARENCY_BASE_URL;
extern NSString * const kAPP_DB_PREFIX;
extern NSString * const kAPP_DB_NAME;
extern NSString * const kAPP_MOMD_NAME;
extern NSString * const kSEED_DB_NAME;

