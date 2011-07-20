//
//  StatesListMetaLoader.h
//  StatesLege
//
//  Created by Gregory Combs on 7/19/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <RestKit/RestKit.h>


@interface StatesListMetaLoader : NSObject <RKRequestDelegate> {
    BOOL    isLoading;
}

@property (nonatomic,retain)    NSMutableArray     * states;
@property (nonatomic,retain)    NSDate             * updated;
@property (nonatomic)           NSInteger            loadingStatus;		// trigger "loading" or "error"  UI element


- (void)downloadStatesList;

@end

#define kStatesListErrorKey             @"states_list_error"
#define kStatesListLoadedKey            @"states_list_loaded"
