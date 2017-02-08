//
//  SLFMapPin.m
//  Created by Gregory Combs on 9/7/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
// This work is licensed under the BSD-3 License included with this source
// distribution.

#import "SLFMapPin.h"

UIColor * SLFMapPinTintColorForColorIndex(SLFMapPinColor pinColorIndex)
{
    UIColor *tintColor = nil;

    switch (pinColorIndex)
    {
        case SLFMapPinColorRed:
            tintColor = [MKPinAnnotationView redPinColor];
            break;
        case SLFMapPinColorGreen:
            tintColor = [MKPinAnnotationView greenPinColor];
            break;
        case SLFMapPinColorBlue:
            tintColor = [UIColor blueColor];
            break;
        case SLFMapPinColorPurple:
        default:
            tintColor = [MKPinAnnotationView purplePinColor];
            break;
    }
    return tintColor;
}
