//
//  DistrictSearchOperation.h
//  Created by Gregory Combs on 9/1/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <MapKit/MapKit.h>
#import <RestKit/RestKit.h>


typedef enum {
    DistrictSearchOperationFailOptionLog,
    DistrictSearchOperationShowAlert,
    DistrictSearchOperationFailOptionCount
} DistrictSearchOperationFailOption;

@class DistrictSearchOperation;

@protocol DistrictSearchOperationDelegate
- (void)districtSearchOperationDidFinishSuccessfully:(DistrictSearchOperation *)op;

- (void)districtSearchOperationDidFail:(DistrictSearchOperation *)op 
                             errorMessage:(NSString *)errorMessage 
                                   option:(DistrictSearchOperationFailOption)failOption;
@end

typedef void(^DistrictSearchBlock)(void);

@interface DistrictSearchOperation : NSObject <RKRequestDelegate>
{
    __weak  NSObject <DistrictSearchOperationDelegate> *delegate;
    CLLocationCoordinate2D searchCoordinate;
    NSArray *searchIDs;
    NSMutableArray *foundIDs;
}
@property (assign) NSObject <DistrictSearchOperationDelegate> *delegate;
@property (assign) CLLocationCoordinate2D searchCoordinate;
@property (retain) NSMutableArray *foundIDs;

- (void)searchForCoordinate:(CLLocationCoordinate2D)aCoordinate 
                   delegate:(NSObject <DistrictSearchOperationDelegate>*)aDelegate;

/* Future Development
 + (void)searchForCoordinate:(CLLocationCoordinate2D)coordinate
               successBlock:(DistrictSearchBlock)successBlock
               failureBlock:(DistrictSearchBlock)failureBlock;

*/
@end
