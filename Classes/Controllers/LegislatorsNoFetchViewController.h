//
//  LegislatorsNoFetchViewController.h
//  Created by Greg Combs on 1/18/12.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "NoFetchViewController.h"
@import CoreLocation;

@interface LegislatorsNoFetchViewController : NoFetchViewController<CLLocationManagerDelegate>
- (instancetype)initWithState:(SLFState *)newState usingGeolocation:(BOOL)usingGeolocation;
@property (nonatomic,strong) CLLocationManager *locationManager;
@end
