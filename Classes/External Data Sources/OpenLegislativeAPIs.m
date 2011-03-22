//
//  OpenLegislativeAPIs.m
//  TexLege
//
//  Created by Gregory Combs on 3/21/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "OpenLegislativeAPIs.h"
#import "UtilityMethods.h"

@implementation OpenLegislativeAPIs
SYNTHESIZE_SINGLETON_FOR_CLASS(OpenLegislativeAPIs);
@synthesize osApiClient;

- (id)init {
	if (self=[super init]) {
		osApiClient = [[RKClient clientWithBaseURL:osApiBaseURL] retain];

	}
	return self;
}

- (void)dealloc {
	if (osApiClient)
		[osApiClient release], osApiClient = nil;

	[super dealloc];
}

- (void)queryOpenStatesBillWithID:(NSString *)billID session:(NSString *)session delegate:(id)sender {
	if (IsEmpty(billID) || IsEmpty(session) || !sender)
		return;
	NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:osApiKeyValue, osApiKeyKey,nil];
	NSString *queryString = [NSString stringWithFormat:@"/bills/tx/%@/%@",session, [billID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[[[OpenLegislativeAPIs sharedOpenLegislativeAPIs] osApiClient] get:queryString queryParams:queryParams delegate:sender];	
}

@end
