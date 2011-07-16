//
//  DistrictMapSearchOperation.h
//  Created by Gregory Combs on 9/1/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <RestKit/RestKit.h>

	
typedef enum {
    DistrictMapSearchOperationFailOptionLog,
    DistrictMapSearchOperationShowAlert,
    
	DistrictMapSearchOperationFailOptionCount
} DistrictMapSearchOperationFailOption;

@class DistrictMapSearchOperation;

@protocol DistrictMapSearchOperationDelegate
- (void)districtMapSearchOperationDidFinishSuccessfully:(DistrictMapSearchOperation *)op;

- (void)districtMapSearchOperationDidFail:(DistrictMapSearchOperation *)op 
							 errorMessage:(NSString *)errorMessage 
								   option:(DistrictMapSearchOperationFailOption)failOption;
@end

@interface DistrictMapSearchOperation : NSObject <RKRequestDelegate>
{
    __weak  NSObject <DistrictMapSearchOperationDelegate> *delegate;
	CLLocationCoordinate2D searchCoordinate;
	NSArray *searchIDs;
	NSMutableArray *foundIDs;
}
@property (assign) NSObject <DistrictMapSearchOperationDelegate> *delegate;
@property (assign) CLLocationCoordinate2D searchCoordinate;

@property (retain) NSMutableArray *foundIDs;

- (void)searchForCoordinate:(CLLocationCoordinate2D)aCoordinate 
				   delegate:(NSObject <DistrictMapSearchOperationDelegate>*)aDelegate;

@end
