//
//  DistrictMapSearchOperation.h
//  TexLege
//
//  Created by Gregory Combs on 9/1/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
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

@interface DistrictMapSearchOperation : NSOperation 
{
    __weak  NSObject <DistrictMapSearchOperationDelegate> *delegate;
	
}
@property (assign) NSObject <DistrictMapSearchOperationDelegate> *delegate;
@property (retain) NSManagedObjectContext * managedObjectContext;
@property (retain) NSMutableArray *foundDistricts;
@property (assign) CLLocationCoordinate2D searchCoordinate;
- (id) initWithDelegate:(id<DistrictMapSearchOperationDelegate>)newDelegate coordinate:(CLLocationCoordinate2D)aCoordinate;

@end
