/*
 *  OpenLegislativeAPIs.h
 *  TexLege
 *
 *  Created by Gregory Combs on 3/18/11.
 *  Copyright 2011 Gregory S. Combs. All rights reserved.
 *
 */

#import <RestKit/RestKit.h>

static NSString *osApiHost =		@"openstates.sunlightlabs.com";
static NSString *osApiBaseURL =		@"http://openstates.sunlightlabs.com/api/v1";
static NSString *transApiBaseURL =	@"http://transparencydata.com/api/1.0";
static NSString *vsApiBaseURL =		@"http://api.votesmart.org";
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