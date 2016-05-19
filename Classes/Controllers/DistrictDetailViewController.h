//
//  DistrictDetailViewController.h
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <SLFRestKit/RestKit.h>
#import "MapViewController.h"

@class SLFDistrict;
@interface DistrictDetailViewController : MapViewController <RKObjectLoaderDelegate, SLFPerstentActionsProtocol>

@property (nonatomic,retain) SLFDistrict *upperDistrict;
@property (nonatomic,retain) SLFDistrict *lowerDistrict;
@property (nonatomic,assign) Class resourceClass;

- (id)initWithDistrictMapID:(NSString *)objID;
@end
