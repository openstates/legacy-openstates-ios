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

@implementation OpenLegislativeAPIs
SYNTHESIZE_SINGLETON_FOR_CLASS(OpenLegislativeAPIs);
@synthesize osApiClient, transApiClient, osMetadata=_osMetadata;

- (id)init {
	if (self=[super init]) {
		_currentSession = nil;
		_osMetadata = nil;
		isFresh = NO;
		updated = nil;
		osApiClient = [[RKClient clientWithBaseURL:osApiBaseURL] retain];
		transApiClient = [[RKClient clientWithBaseURL:transApiBaseURL] retain];
		
		[self currentSession];
	}
	return self;
}

- (void)dealloc {
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];

	if (updated)
		[updated release], updated = nil;
	if (_osMetadata)
		[_osMetadata release], _osMetadata = nil;
	if (_currentSession)
		[_currentSession release], _currentSession = nil;
	if (osApiClient)
		[osApiClient release], osApiClient = nil;
	if (transApiClient)
		[transApiClient release], transApiClient = nil;

	[super dealloc];
}

- (void)queryOpenStatesBillWithID:(NSString *)billID session:(NSString *)session delegate:(id)sender {
	if (IsEmpty(billID) || IsEmpty(session) || !sender || !osApiClient)
		return;
	NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:osApiKeyValue, @"apikey",nil];
	NSString *queryString = [NSString stringWithFormat:@"/bills/tx/%@/%@",session, [billID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[osApiClient get:queryString queryParams:queryParams delegate:sender];	
}

- (NSString *)currentSession {
	if (IsEmpty(_currentSession) || !isFresh || !updated || ([[NSDate date] timeIntervalSinceDate:updated] > (3600*24))) {	// if we're over a day old, let's refresh
		isFresh = NO;
		if (_currentSession)
			[_currentSession release];
		_currentSession = [OPENAPIS_DEFAULT_SESSION retain];
		
		NSDictionary *queryParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:osApiKeyValue, @"apikey",nil];
		[osApiClient get:@"/metadata/tx" queryParams:queryParams delegate:self];	
	}
	return _currentSession;
}

#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
	if (error && request) {
		debug_NSLog(@"OpenLegislativeAPIs - Error loading from %@: %@", [request description], [error localizedDescription]);
		//[[NSNotificationCenter defaultCenter] postNotificationName:kCalendarEventsNotifyError object:nil];
	}
	
	isFresh = NO;
	NSLog(@"OpenLegislativeAPIs -- Failed to obtain current legislative session, defaulting to: %@", _currentSession);
	//[[NSNotificationCenter defaultCenter] postNotificationName:kCalendarEventsNotifyLoaded object:nil];
}


- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
	if ([request isGET] && [response isOK]) {  
		// Success! Let's take a look at the data  
		if (_osMetadata)
			[_osMetadata release];

		_osMetadata = [[response.body mutableObjectFromJSONData] retain];
		if (IsEmpty(_osMetadata))
			return;
			
		NSMutableDictionary *sessions = [_osMetadata objectForKey:@"session_details"];
		
//		NSLog(@"%@", sessions);
		
		NSString *maxdate = @"1969-01-01 00:00:00";
		NSString *maxsession = nil;
		for (NSString *sessionKey in [sessions allKeys]) {
			NSDictionary *session = [sessions objectForKey:sessionKey];
			NSString *startDate = [session objectForKey:@"start_date"];
			if ([startDate compare:maxdate] == NSOrderedDescending) {
				maxdate = startDate;
				maxsession = sessionKey;
			}
		}
		if (maxsession) {
			if (_currentSession)
				[_currentSession release];
			_currentSession = [maxsession retain];	
			isFresh = TRUE;
			if (updated)
				[updated release];
			updated = [[NSDate date] retain];
		}
	}
}

@end
