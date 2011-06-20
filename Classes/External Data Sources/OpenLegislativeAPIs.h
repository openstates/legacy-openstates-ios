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

// ********** WARNING *************
// Don't be tempted to put these in a .strings file like ... [UtilityMethods texLegeStringWithKeyPath:@"ExternalURLs.nimspWeb"]
// Doing so will inadvertenly expose our API keys if a user modifies the file to point to their own server
// ... Granted, they could probably just disassemble the app and get these (and any other) static strings, but lets not make it easy

static NSString *osApiHost =		@"openstates.sunlightlabs.com";
static NSString *osApiBaseURL =		@"http://openstates.sunlightlabs.com/api/v1";
static NSString *osApiKeyValue =	@"350284d0c6af453b9b56f6c1c7fea1f9";

static NSString *transApiBaseURL =	@"http://transparencydata.com/api/1.0";

static NSString *vsApiBaseURL =		@"http://api.votesmart.org";
static NSString *vsApiKey =			@"5fb3b476c47fcb8a21dc2ec22ca92cbb";	// for "key" ... you'll want to add "&stateId=TX&o=JSON" too...

static NSString *tloApiHost =		@"www.legis.state.tx.us";
static NSString *tloApiBaseURL =	@"http://www.legis.state.tx.us";

@interface OpenLegislativeAPIs : NSObject <RKRequestDelegate> {
	RKClient *osApiClient;	
	RKClient *transApiClient;
	RKClient *vsApiClient;
	RKClient *tloApiClient;
}
+ (OpenLegislativeAPIs *)sharedOpenLegislativeAPIs;
@property (nonatomic, retain) RKClient *osApiClient;
@property (nonatomic, retain) RKClient *transApiClient;
@property (nonatomic, retain) RKClient *vsApiClient;
@property (nonatomic, retain) RKClient *tloApiClient;

- (void)queryOpenStatesBillWithID:(NSString *)billID session:(NSString *)session delegate:(id)sender;


@end