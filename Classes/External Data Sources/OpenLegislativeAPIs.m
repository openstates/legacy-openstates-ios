//
//  OpenLegislativeAPIs.m
//  TexLege
//
//  Created by Gregory Combs on 3/21/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "OpenLegislativeAPIs.h"
#import "UtilityMethods.h"
#import <RestKit/Support/JSON/JSONKit/JSONKit.h>
#import "NSDate+Helper.h"
#import "StateMetaLoader.h"


@implementation OpenLegislativeAPIs
@synthesize osApiClient, transApiClient, vsApiClient, tloApiClient;

+ (id)sharedOpenLegislativeAPIs
{
	static dispatch_once_t pred;
	static OpenLegislativeAPIs *foo = nil;
	
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}


- (id)init {
	if ((self=[super init])) {
		osApiClient = [[RKClient clientWithBaseURL:osApiBaseURL] retain];
		transApiClient = [[RKClient clientWithBaseURL:transApiBaseURL] retain];
		vsApiClient = [[RKClient clientWithBaseURL:vsApiBaseURL] retain];
		tloApiClient = [[RKClient clientWithBaseURL:tloApiBaseURL] retain];
	}
	return self;
}

- (void)dealloc {
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];

	if (osApiClient)
		[osApiClient release], osApiClient = nil;
	if (transApiClient)
		[transApiClient release], transApiClient = nil;
	if (vsApiClient)
		[vsApiClient release], vsApiClient = nil;
	if (tloApiClient)
		[tloApiClient release], tloApiClient = nil;

	[super dealloc];
}

- (void)queryOpenStatesBillWithID:(NSString *)billID session:(NSString *)session delegate:(id)sender {
	StateMetaLoader *meta = [StateMetaLoader sharedStateMeta];

	if (!session && !IsEmpty(meta.currentSession)) {
		session = meta.currentSession;
	}
	
	if (IsEmpty(billID) || IsEmpty(session) || !sender || !osApiClient)
		return;
	NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY, @"apikey",nil];
	NSString *queryString = [NSString stringWithFormat:@"/bills/%@/%@/%@", meta.selectedState, session, [billID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[osApiClient get:queryString queryParams:queryParams delegate:sender];	
}

@end
