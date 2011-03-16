//
//  BillMetadataLoader.h
//  TexLege
//
//  Created by Gregory Combs on 3/16/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import <RestKit/RestKit.h>

#define kBillMetadataFile @"BillMetadata.json"
#define kBillMetadataPath @"BillMetadata"

#define kBillMetadataNotifyError	@"BILL_METADATA_ERROR"
#define kBillMetadataNotifyLoaded	@"BILL_METADATA_LOADED"

@interface BillMetadataLoader : NSObject <RKRequestDelegate> {
	NSMutableDictionary *_metadata;
	BOOL isFresh;
}
+ (BillMetadataLoader *)sharedBillMetadataLoader;
- (void)loadMetadata:(id)sender;

@property (nonatomic,readonly) NSDictionary *metadata;
@property (nonatomic) BOOL isFresh;

@end

