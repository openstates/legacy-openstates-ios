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

#import "DistrictSearch.h"
#import "SLFDataModels.h"
#import "SLFRestKitManager.h"
#import "JSONKit.h"
#import "SLFReachable.h"

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

#define USE_OPENSTATES_GEOSEARCH 0  // need a more direct route to the boundary IDs than what's available in Open States right now

- (void)searchForCoordinate:(CLLocationCoordinate2D)aCoordinate successBlock:(DistrictSearchSuccessWithResultsBlock)successBlock failureBlock:(DistrictSearchFailureWithMessageAndFailOptionBlock)failureBlock {
    self.onSuccessWithResults = successBlock;
    self.onFailureWithMessageAndFailOption = failureBlock;
    searchCoordinate = aCoordinate;
#if USE_OPENSTATES_GEOSEARCH
    RKClient * client = [[SLFRestKitManager sharedRestKit] openStatesClient];
#else
    RKClient * client = [[SLFRestKitManager sharedRestKit] boundaryClient];
#endif
    if (NO == [client isNetworkReachable]) {
        if (failureBlock)
            failureBlock(NSLocalizedString(@"Cannot geolocate legislative districts because Internet service is unavailable.", @""), DistrictSearchShowAlert);
        return;
    }
    
#if USE_OPENSTATES_GEOSEARCH
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys: SUNLIGHT_APIKEY, @"apikey", [NSNumber numberWithDouble:aCoordinate.longitude], @"long", [NSNumber numberWithDouble:aCoordinate.latitude], @"lat", nil];
    [client get:@"/legislators/geo" queryParams:queryParams delegate:self];
#else
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys: SUNLIGHT_APIKEY, @"apikey", [NSString stringWithFormat:@"%lf,%lf", aCoordinate.latitude, aCoordinate.longitude], @"contains", @"sldu,sldl", @"sets", nil];
   [client get:@"/boundary" queryParams:queryParams delegate:self];
#endif
}

+ (DistrictSearch *)districtSearchForCoordinate:(CLLocationCoordinate2D)aCoordinate successBlock:(DistrictSearchSuccessWithResultsBlock)successBlock failureBlock:(DistrictSearchFailureWithMessageAndFailOptionBlock)failureBlock {
    DistrictSearch *op = [[[DistrictSearch alloc] init] autorelease];
    [op searchForCoordinate:aCoordinate successBlock:successBlock failureBlock:failureBlock];
    return op;
}

- (void) dealloc {
#if USE_OPENSTATES_GEOSEARCH
    RKClient *client = [[SLFRestKitManager sharedRestKit] openStatesClient];
#else
    RKClient *client = [[SLFRestKitManager sharedRestKit] boundaryClient];
#endif
    [client.requestQueue cancelRequestsWithDelegate:self];
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

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
    BOOL success = NO;
    NSArray *foundIDs = nil;
    if (response && [response isOK]) {  
        id results = [response.body objectFromJSONData];
        @try {
            foundIDs = [self boundaryIDsFromSearchResults:results];
            success = !IsEmpty(foundIDs);
        }
        @catch (NSException *exception) {
            RKLogError(@"%@: %@", [exception name], [exception reason]);
        }
    }
    
    if (!success) {
        RKLogError(@"Request = %@", request);
        RKLogError(@"Response = %@", response);
        if (_onFailureWithMessageAndFailOption)
            _onFailureWithMessageAndFailOption(@"Could not find a district map with those coordinates.", DistrictSearchFailOptionLog);
        return;
    }
    if (_onSuccessWithResults)
        _onSuccessWithResults(foundIDs);
}

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
    if (error && request) {
        RKLogError(@"Error loading search results from %@: %@", [request description], [error localizedDescription]);
    }    
    if (_onFailureWithMessageAndFailOption)
        _onFailureWithMessageAndFailOption(@"Could not find a district map with those coordinates.", DistrictSearchFailOptionLog);
}


#if USE_OPENSTATES_GEOSEARCH
- (NSArray *)boundaryIDsFromSearchResults:(id)results {
    NSMutableArray *foundIDs = [NSMutableArray array];
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
        if (legislator)
            [foundIDs addObject:[legislator districtID]];
    }
    return foundIds;
}
#else
- (NSArray *)boundaryIDsFromSearchResults:(id)results {
    NSAssert(results && [results isKindOfClass:[NSDictionary class]], @"Invalid search results, expected a dictionary, got something else");
    return [results valueForKeyPath:@"objects.slug"];
}
#endif

@end
