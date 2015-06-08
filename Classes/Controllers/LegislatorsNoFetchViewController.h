//
//  LegislatorsNoFetchViewController.h
//  Created by Greg Combs on 1/18/12.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "NoFetchViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SVGeocoder.h"

@interface LegislatorsNoFetchViewController : NoFetchViewController <SVGeocoderDelegate>
@property (nonatomic,retain) CLLocationManager *locationManager;
- (id)initWithState:(SLFState *)newState usingGeolocation:(BOOL)usingGeolocation;
@end
