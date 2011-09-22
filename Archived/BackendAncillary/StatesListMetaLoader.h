//
//  StatesListMetaLoader.h
//  StatesLege
//
//  Created by Gregory Combs on 7/19/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <RestKit/RestKit.h>


@interface StatesListMetaLoader : NSObject <RKObjectLoaderDelegate> {
    BOOL    isLoading;
}

@property (nonatomic,assign)    Class            resourceClass;
@property (nonatomic,copy)      NSString       * resourcePath;
@property (nonatomic,copy)      NSArray        * states;
@property (nonatomic,retain)    NSDate         * updated;
@property (nonatomic)           NSInteger        loadingStatus;		// trigger "loading" or "error"  UI element


+ (id)sharedStatesLoader;
- (BOOL)isFeatureEnabled:(NSString *)feature forStateID:(NSString *)stateID;

- (void)loadData;
- (void)loadDataFromDataStore;

@end

#define kStatesListErrorKey             @"states_list_error"
#define kStatesListLoadedKey            @"states_list_loaded"
