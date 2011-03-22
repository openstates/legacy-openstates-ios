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
static NSString *osApiKey =			@"apikey=350284d0c6af453b9b56f6c1c7fea1f9";
static NSString *osApiKeyKey =		@"apikey";
static NSString *osApiKeyValue =	@"350284d0c6af453b9b56f6c1c7fea1f9";

static NSString *transApiBaseURL =	@"http://transparencydata.com/api/1.0";

static NSString *vsApiBaseURL =		@"http://api.votesmart.org";
static NSString *vsApiKey =			@"key=5fb3b476c47fcb8a21dc2ec22ca92cbb&stateId=TX&o=JSON";

@interface OpenLegislativeAPIs : NSObject {
	RKClient *osApiClient;	
}
+ (OpenLegislativeAPIs *)sharedOpenLegislativeAPIs;
@property (nonatomic, retain) RKClient *osApiClient;

- (void)queryOpenStatesBillWithID:(NSString *)billID session:(NSString *)session delegate:(id)sender;


@end