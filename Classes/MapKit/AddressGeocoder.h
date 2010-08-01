//
//  AddressGeocoder.h
//  Test
//
//  Created by Bill Dudney on 5/15/09.
//  Copyright 2009 Gala Factory Software LLC. All rights reserved.
//
//
//  Licensed with the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AddressGeocoder : NSObject {
}

+ (CLLocationCoordinate2D)locationOfAddress:(NSDictionary *)address;

@end
