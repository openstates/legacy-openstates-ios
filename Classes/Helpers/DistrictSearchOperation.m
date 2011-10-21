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
@property (assign) CLLocationCoordinate2D searchCoordinate;
@property (nonatomic,copy) DistrictSearchSuccessWithResultsBlock onSuccessWithResults;
@property (nonatomic,copy) DistrictSearchFailureWithMessageAndFailOptionBlock onFailureWithMessageAndFailOption;
@end

@implementation DistrictSearchOperation
@synthesize searchCoordinate;
@synthesize onSuccessWithResults = _onSuccessWithResults;
@synthesize onFailureWithMessageAndFailOption = _onFailureWithMessageAndFailOption;

- (void)searchForCoordinate:(CLLocationCoordinate2D)aCoordinate successBlock:(DistrictSearchSuccessWithResultsBlock)successBlock failureBlock:(DistrictSearchFailureWithMessageAndFailOptionBlock)failureBlock {
    self.onSuccessWithResults = successBlock;
    self.onFailureWithMessageAndFailOption = failureBlock;
    searchCoordinate = aCoordinate;
    RKClient * osClient = [[SLFRestKitManager sharedRestKit] openStatesClient];
    if (NO == [osClient isNetworkAvailable]) {
        if (failureBlock)
            failureBlock(NSLocalizedString(@"Cannot geolocate legislative districts because Internet service is unavailable.", @""), DistrictSearchOperationShowAlert);
        return;
    }
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys: SUNLIGHT_APIKEY, @"apikey",
                                 [NSNumber numberWithDouble:aCoordinate.longitude], @"long", [NSNumber numberWithDouble:aCoordinate.latitude], @"lat", nil];
    [osClient get:@"/legislators/geo" queryParams:queryParams delegate:self];    
}

+ (DistrictSearchOperation *)searchOperationForCoordinate:(CLLocationCoordinate2D)aCoordinate successBlock:(DistrictSearchSuccessWithResultsBlock)successBlock failureBlock:(DistrictSearchFailureWithMessageAndFailOptionBlock)failureBlock {
    DistrictSearchOperation *op = [[[DistrictSearchOperation alloc] init] autorelease];
    [op searchForCoordinate:aCoordinate successBlock:successBlock failureBlock:failureBlock];
    return op;
}


- (void) dealloc {
    RKClient * osClient = [[SLFRestKitManager sharedRestKit] openStatesClient];
    [osClient.requestQueue cancelRequestsWithDelegate:self];
    Block_release(_onSuccessWithResults);
    Block_release(_onFailureWithMessageAndFailOption);
    [super dealloc];
}

- (void)setOnSuccessWithResults:(DistrictSearchSuccessWithResultsBlock)onSuccessWithResults {
    if (_onSuccessWithResults) {
        Block_release(_onSuccessWithResults);
        _onSuccessWithResults = nil;
    }
    _onSuccessWithResults = Block_copy(onSuccessWithResults);
}

- (void)setOnFailureWithMessageAndFailOption:(DistrictSearchFailureWithMessageAndFailOptionBlock)onFailureWithMessageAndFailOption {
    if (_onFailureWithMessageAndFailOption) {
        Block_release(_onFailureWithMessageAndFailOption);
        _onFailureWithMessageAndFailOption = nil;
    }
    _onFailureWithMessageAndFailOption = Block_copy(onFailureWithMessageAndFailOption);
}

#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
    if (error && request) {
        RKLogError(@"Error loading search results from %@: %@", [request description], [error localizedDescription]);
    }    
    if (_onFailureWithMessageAndFailOption)
        _onFailureWithMessageAndFailOption(@"Could not find a district map with those coordinates.", DistrictSearchOperationFailOptionLog);
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
    BOOL success = NO;
    NSMutableArray *foundIDs = [NSMutableArray array];
    
    if ([request isGET] && [response isOK]) {  
        id results = [response.body mutableObjectFromJSONData];
        NSMutableArray *memberList = nil;
        
        if ([results isKindOfClass:[NSMutableArray class]])
            memberList = results;
        else if ([results isKindOfClass:[NSMutableDictionary class]])
            memberList = [NSMutableArray arrayWithObject:results];
        
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
    }
    
    if (!success) {
        RKLogError(@"Request = %@", request);
        RKLogError(@"Response = %@", response);
        if (_onFailureWithMessageAndFailOption)
            _onFailureWithMessageAndFailOption(@"Could not find a district map with those coordinates.", DistrictSearchOperationFailOptionLog);
        return;
    }
    if (_onSuccessWithResults)
        _onSuccessWithResults(foundIDs);
}

@end
