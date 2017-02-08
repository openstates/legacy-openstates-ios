//
//  DistrictSearchOperation.m
//  Created by Gregory Combs on 9/1/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "DistrictSearch.h"
#import "SLFDataModels.h"
#import "SLFRestKitManager.h"
#import <SLFRestKit/JSONKit.h>
#import "SLFReachable.h"
#import "APIKeys.h"
#import "SLFLog.h"

@interface DistrictSearch()
@property (assign) CLLocationCoordinate2D searchCoordinate;
@property (nonatomic,copy) DistrictSearchSuccessWithResultsBlock onSuccessWithResults;
@property (nonatomic,copy) DistrictSearchFailureWithMessageAndFailOptionBlock onFailureWithMessageAndFailOption;
- (NSArray *)boundaryIDsFromSearchResults:(id)results;
@end

@implementation DistrictSearch
@synthesize searchCoordinate;
@synthesize onSuccessWithResults = _onSuccessWithResults;
@synthesize onFailureWithMessageAndFailOption = _onFailureWithMessageAndFailOption;

- (void)searchForCoordinate:(CLLocationCoordinate2D)aCoordinate successBlock:(DistrictSearchSuccessWithResultsBlock)successBlock failureBlock:(DistrictSearchFailureWithMessageAndFailOptionBlock)failureBlock {
    self.onSuccessWithResults = successBlock;
    self.onFailureWithMessageAndFailOption = failureBlock;
    searchCoordinate = aCoordinate;

    RKClient * client = [[SLFRestKitManager sharedRestKit] openStatesClient];
    if (NO == [client isNetworkReachable]) {
        if (failureBlock)
            failureBlock(NSLocalizedString(@"Cannot geolocate legislative districts because Internet service is unavailable.", @""), DistrictSearchShowAlert);
        return;
    }
    
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys: SUNLIGHT_APIKEY, @"apikey", [NSNumber numberWithDouble:aCoordinate.longitude], @"long", [NSNumber numberWithDouble:aCoordinate.latitude], @"lat", @"boundary_id,district,chamber,state", @"fields", nil];
    [client get:@"/legislators/geo" queryParams:queryParams delegate:self];
}

+ (DistrictSearch *)districtSearchForCoordinate:(CLLocationCoordinate2D)aCoordinate successBlock:(DistrictSearchSuccessWithResultsBlock)successBlock failureBlock:(DistrictSearchFailureWithMessageAndFailOptionBlock)failureBlock {
    DistrictSearch *op = [[DistrictSearch alloc] init];
    [op searchForCoordinate:aCoordinate successBlock:successBlock failureBlock:failureBlock];
    return op;
}

- (void) dealloc {
    RKClient *client = [[SLFRestKitManager sharedRestKit] openStatesClient];
    [client.requestQueue cancelRequestsWithDelegate:self];
}

- (void)setOnSuccessWithResults:(DistrictSearchSuccessWithResultsBlock)onSuccessWithResults {
    if (_onSuccessWithResults) {
        _onSuccessWithResults = nil;
    }
    _onSuccessWithResults = [onSuccessWithResults copy];
}

- (void)setOnFailureWithMessageAndFailOption:(DistrictSearchFailureWithMessageAndFailOptionBlock)onFailureWithMessageAndFailOption {
    if (_onFailureWithMessageAndFailOption) {
        _onFailureWithMessageAndFailOption = nil;
    }
    _onFailureWithMessageAndFailOption = [onFailureWithMessageAndFailOption copy];
}

#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
    BOOL success = NO;
    NSArray *foundIDs = nil;
    if (response && [response isOK]) {  
        id results = [response.body objectFromJSONData];
        @try {
            foundIDs = [self boundaryIDsFromSearchResults:results];
            success = foundIDs.count > 0;
        }
        @catch (NSException *exception) {
            os_log_error([SLFLog common], "Exception in district search: %s{public}", exception.description);
        }
    }
    
    if (!success) {
        os_log_error([SLFLog common], "District Search request failure -- %s{public} | response = %d", request.URL.absoluteString, response.statusCode);
        if (_onFailureWithMessageAndFailOption)
            _onFailureWithMessageAndFailOption(@"Could not find a district map with those coordinates.", DistrictSearchFailOptionLog);
        return;
    }
    if (_onSuccessWithResults)
        _onSuccessWithResults(foundIDs);
}

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
    if (error && request) {
        os_log_error([SLFLog common], "Error loading search results from %s{public}: %s{public}", request.URL.absoluteString, error.localizedDescription);
    }    
    if (_onFailureWithMessageAndFailOption)
        _onFailureWithMessageAndFailOption(@"Could not find a district map with those coordinates.", DistrictSearchFailOptionLog);
}


- (NSArray *)boundaryIDsFromSearchResults:(id)results {
    NSMutableArray *foundIDs = [NSMutableArray array];
    NSMutableArray *boundaryList = nil;
    if ([results isKindOfClass:[NSMutableArray class]])
        boundaryList = results;
    else if ([results isKindOfClass:[NSMutableDictionary class]])
        boundaryList = [NSMutableArray arrayWithObject:results];
    for (NSMutableDictionary *boundary in boundaryList) {
        NSString *boundaryID = boundary[@"boundary_id"];
        if (SLFTypeIsNull(boundaryID))
            continue;
        [foundIDs addObject:boundaryID];
    }
    return foundIDs;
}

@end
