/*
 *  OpenLegislativeAPIs.h
 *  TexLege
 *
 *  Created by Gregory Combs on 3/18/11.
 *  Copyright 2011 Gregory S. Combs. All rights reserved.
 *
 */

#import "SynthesizeSingleton.h"
#import <RestKit/RestKit.h>

static NSString *osApiBaseURL =		@"http://openstates.sunlightlabs.com/api/v1";
static NSString *osApiKeyValue =	@"350284d0c6af453b9b56f6c1c7fea1f9";

static NSString *transApiBaseURL =	@"http://transparencydata.com/api/1.0";

static NSString *vsApiBaseURL =		@"http://api.votesmart.org";
static NSString *vsApiKey =			@"5fb3b476c47fcb8a21dc2ec22ca92cbb";	// for "key" ... you'll want to add "&stateId=TX&o=JSON" too...

@interface OpenLegislativeAPIs : NSObject <RKRequestDelegate> {
	RKClient *osApiClient;	
	RKClient *transApiClient;
	RKClient *vsApiClient;
	NSString *_currentSession;
	NSMutableDictionary *_osMetadata;
	NSDate *updated;
	BOOL isFresh;
}
+ (OpenLegislativeAPIs *)sharedOpenLegislativeAPIs;
@property (nonatomic, retain) RKClient *osApiClient;
@property (nonatomic, retain) RKClient *transApiClient;
@property (nonatomic, retain) RKClient *vsApiClient;
@property (nonatomic, readonly) NSString *currentSession;
@property (nonatomic, readonly) NSMutableDictionary *osMetadata;

- (void)queryOpenStatesBillWithID:(NSString *)billID session:(NSString *)session delegate:(id)sender;


@end