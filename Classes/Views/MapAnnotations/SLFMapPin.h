//
//  SLFMapPin.h
//  Created by Gregory Combs on 9/7/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
// This work is licensed under the BSD-3 License included with this source
// distribution.

#import <MapKit/MapKit.h>

typedef NS_ENUM(UInt8, SLFMapPinColor) {
    SLFMapPinColorRed = 0,
    SLFMapPinColorGreen,
    SLFMapPinColorPurple,
    SLFMapPinColorBlue = 99
};

UIColor * SLFMapPinTintColorForColorIndex(SLFMapPinColor pinColorIndex);
