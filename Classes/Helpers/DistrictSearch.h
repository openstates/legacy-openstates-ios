//
//  DistrictSearchOperation.h
//  Created by Gregory Combs on 9/1/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

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
