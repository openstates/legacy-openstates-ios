//
//  DistrictMapSearchOperation.m
//  Created by Gregory Combs on 9/1/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "DistrictMapSearchOperation.h"
#import "NSInvocation+CWVariableArguments.h"
#import "DistrictMapObj+MapKit.h"
#import "OpenLegislativeAPIs.h"
#import "TexLegeReachability.h"
#import "LegislatorObj.h"
#import "JSONKit.h"
#import "UtilityMethods.h"

@interface DistrictMapSearchOperation()
- (void)informDelegateOfFailureWithMessage:(NSString *)message failOption:(DistrictMapSearchOperationFailOption)failOption;
- (void)informDelegateOfSuccess;
@end

@implementation DistrictMapSearchOperation
@synthesize delegate;
@synthesize searchCoordinate, foundIDs;

- (id) init {
	if ((self = [super init])) {
		delegate = nil;
	}
	return self;
}

- (void)searchForCoordinate:(CLLocationCoordinate2D)aCoordinate 
				   delegate:(NSObject <DistrictMapSearchOperationDelegate>*)aDelegate {
	
	delegate = aDelegate;
	searchCoordinate = aCoordinate;
	
	if ([TexLegeReachability openstatesReachable]) {
		
		NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
									 SUNLIGHT_APIKEY, @"apikey",
									 [NSNumber numberWithDouble:aCoordinate.longitude], @"long",
									 [NSNumber numberWithDouble:aCoordinate.latitude], @"lat",
									 nil];
		
		RKClient *osApiClient = [[OpenLegislativeAPIs sharedOpenLegislativeAPIs] osApiClient];
		[osApiClient get:@"/legislators/geo/" queryParams:queryParams delegate:self];	
	}
	else {
		[self informDelegateOfFailureWithMessage:@"Cannot geolocate legislative districts because Internet service is unavailable." 
									  failOption:DistrictMapSearchOperationShowAlert];
	}
	

}

- (void) dealloc {
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];

	self.foundIDs = nil;
	delegate = nil;
	[super dealloc];
}

- (void)informDelegateOfFailureWithMessage:(NSString *)message failOption:(DistrictMapSearchOperationFailOption)failOption;
{
    if ([delegate respondsToSelector:@selector(districtMapSearchOperationDidFail:errorMessage:option:)])
    {
        NSInvocation *invocation = [NSInvocation invocationWithTarget:delegate 
                                                             selector:@selector(districtMapSearchOperationDidFail:errorMessage:option:) 
                                                      retainArguments:YES, self, message, failOption];
        [invocation invokeOnMainThreadWaitUntilDone:YES];
    } 
}

- (void)informDelegateOfSuccess
{
    if ([delegate respondsToSelector:@selector(districtMapSearchOperationDidFinishSuccessfully:)])
    {
        [delegate performSelectorOnMainThread:@selector(districtMapSearchOperationDidFinishSuccessfully:) 
                                   withObject:self 
                                waitUntilDone:NO];
    }
}


#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
	if (error && request) {
		debug_NSLog(@"Error loading search results from %@: %@", [request description], [error localizedDescription]);
	}	
	
	self.foundIDs = nil;

	[self informDelegateOfFailureWithMessage:@"Could not find a district map with those coordinates." 
								  failOption:DistrictMapSearchOperationFailOptionLog];
	
}

// Handling GET /BillMetadata.json  
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
	
	if ([request isGET] && [response isOK]) {  
		// Success! Let's take a look at the data  
		
		
		id results = [response.body mutableObjectFromJSONData];
		NSMutableArray *memberList = nil;
		
		if ([results isKindOfClass:[NSMutableArray class]])
			memberList = results;
		
		else if ([results isKindOfClass:[NSMutableDictionary class]])
			memberList = [NSMutableArray arrayWithObject:results];
						
								
		nice_release(foundIDs);
		foundIDs = [[NSMutableArray alloc] init];
		
		BOOL success = NO;
		
		for (NSMutableDictionary *member in memberList) {
			
			NSString *legeID = [member objectForKey:@"leg_id"];
			
			if (IsEmpty(legeID))
				continue;
			
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.openstatesID == %@", legeID];
			LegislatorObj *legislator = [LegislatorObj objectWithPredicate:predicate];
			if (legislator) {
				[foundIDs addObject:legislator.districtMap.districtMapID];
				success = YES;

			}
				
		}
		
		if (success) {
			[self informDelegateOfSuccess];
		}
	}
	
	[self informDelegateOfFailureWithMessage:@"Could not find a district map with those coordinates." failOption:DistrictMapSearchOperationFailOptionLog];

}
	

@end
