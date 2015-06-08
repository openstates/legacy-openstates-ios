//
//  DistrictSearchOperation.h
//  Created by Gregory Combs on 9/1/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <MapKit/MapKit.h>
#import <RestKit/RestKit.h>

typedef enum {
    DistrictSearchFailOptionLog,
    DistrictSearchShowAlert,
    DistrictSearchFailOptionCount
} DistrictSearchFailOption;

typedef void(^DistrictSearchSuccessWithResultsBlock)(NSArray *results);
typedef void(^DistrictSearchFailureWithMessageAndFailOptionBlock)(NSString *message, DistrictSearchFailOption failOption);

@interface DistrictSearch : NSObject <RKRequestDelegate> {
}

- (void)searchForCoordinate:(CLLocationCoordinate2D)coordinate
               successBlock:(DistrictSearchSuccessWithResultsBlock)successBlock
               failureBlock:(DistrictSearchFailureWithMessageAndFailOptionBlock)failureBlock;

+ (DistrictSearch *)districtSearchForCoordinate:(CLLocationCoordinate2D)coordinate
               successBlock:(DistrictSearchSuccessWithResultsBlock)successBlock
               failureBlock:(DistrictSearchFailureWithMessageAndFailOptionBlock)failureBlock;

@end
