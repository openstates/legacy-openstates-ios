//
//  SLFMapPin.h
//  Created by Gregory Combs on 9/7/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
// This work is licensed under the BSD-3 License included with this source
// distribution.

#import <MapKit/MapKit.h>

typedef NS_ENUM(NSUInteger, SLFMapPinColor) {
    SLFMapPinColorRed = 0,
    SLFMapPinColorGreen,
    SLFMapPinColorPurple,
    // end compatibility with MKPinAnnotation colors
    SLFMapPinColorBlue = 99
};

typedef NS_ENUM(NSUInteger, SLFMapPinStatus) {
    SLFMapPinStatusNormal = 0,
    SLFMapPinStatusDown1,
    SLFMapPinStatusDown2,
    SLFMapPinStatusDown3,
    SLFMapPinStatusFloating,
    SLFMapPinStatusPressed,
    //
    SLFMapPinStatusHead = 99
};

@interface SLFMapPin : NSObject
+ (UIImage *)imageForMapAnnotation:(id <MKAnnotation>)annotation status:(SLFMapPinStatus)status;
+ (UIImage *)imageForPinColorIndex:(SLFMapPinColor)index status:(SLFMapPinStatus)status;
+ (NSString *)imageFileForPinColorIndex:(SLFMapPinColor)index status:(SLFMapPinStatus)status;
@end
