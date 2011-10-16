//
//  DistrictSearchOperation.m
//  Created by Gregory Combs on 9/1/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "DistrictSearchOperation.h"
#import "NSInvocation+CWVariableArguments.h"
#import "SLFDataModels.h"
#import "SLFRestKitManager.h"
#import "JSONKit.h"

@interface DistrictSearchOperation()
- (void)informDelegateOfFailureWithMessage:(NSString *)message failOption:(DistrictSearchOperationFailOption)failOption;
- (void)informDelegateOfSuccess;
@end

@implementation DistrictSearchOperation
@synthesize delegate;
@synthesize searchCoordinate, foundIDs;

- (id) init {
    if ((self = [super init])) {
        delegate = nil;
    }
    return self;
}

- (void)searchForCoordinate:(CLLocationCoordinate2D)aCoordinate 
                   delegate:(NSObject <DistrictSearchOperationDelegate>*)aDelegate {
    
    delegate = aDelegate;
    searchCoordinate = aCoordinate;
    RKClient * osClient = [[SLFRestKitManager sharedRestKit] openStatesClient];
    
    if ([osClient isNetworkAvailable]) {
        
        NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys: SUNLIGHT_APIKEY, @"apikey",
                                     [NSNumber numberWithDouble:aCoordinate.longitude], @"long",
                                     [NSNumber numberWithDouble:aCoordinate.latitude], @"lat", nil];
        [osClient get:@"/legislators/geo/" queryParams:queryParams delegate:self];    
    }
    else {
        [self informDelegateOfFailureWithMessage:@"Cannot geolocate legislative districts because Internet service is unavailable." 
                                      failOption:DistrictSearchOperationShowAlert];
    }
    

}

- (void) dealloc {
    RKClient * osClient = [[SLFRestKitManager sharedRestKit] openStatesClient];
    [osClient.requestQueue cancelRequestsWithDelegate:self];
    self.foundIDs = nil;
    delegate = nil;
    [super dealloc];
}

- (void)informDelegateOfFailureWithMessage:(NSString *)message failOption:(DistrictSearchOperationFailOption)failOption;
{
    if ([delegate respondsToSelector:@selector(districtSearchOperationDidFail:errorMessage:option:)])
    {
        NSInvocation *invocation = [NSInvocation invocationWithTarget:delegate 
                                                             selector:@selector(districtSearchOperationDidFail:errorMessage:option:) 
                                                      retainArguments:YES, self, message, failOption];
        [invocation invokeOnMainThreadWaitUntilDone:YES];
    } 
}

- (void)informDelegateOfSuccess
{
    if ([delegate respondsToSelector:@selector(districtSearchOperationDidFinishSuccessfully:)])
    {
        [delegate performSelectorOnMainThread:@selector(districtSearchOperationDidFinishSuccessfully:) 
                                   withObject:self 
                                waitUntilDone:NO];
    }
}


#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
    if (error && request) {
        RKLogError(@"Error loading search results from %@: %@", [request description], [error localizedDescription]);
    }    
    
    self.foundIDs = nil;
    [self informDelegateOfFailureWithMessage:@"Could not find a district map with those coordinates." 
                                  failOption:DistrictSearchOperationFailOptionLog];
    
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
    if ([request isGET] && [response isOK]) {  
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
            NSString *legID = [member objectForKey:@"leg_id"];
            
            if (IsEmpty(legID))
                continue;
            
            SLFLegislator *legislator = [SLFLegislator findFirstByAttribute:@"legID" withValue:legID];
            if (legislator) {
                [foundIDs addObject:[legislator districtID]];
                success = YES;
            }
        }
        
        if (success) {
            [self informDelegateOfSuccess];
        }
    }
    
    [self informDelegateOfFailureWithMessage:@"Could not find a district map with those coordinates." failOption:DistrictSearchOperationFailOptionLog];

}

@end
