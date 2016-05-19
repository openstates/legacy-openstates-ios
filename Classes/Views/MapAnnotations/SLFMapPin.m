//
//  SLFMapPin.m
//  Created by Gregory Combs on 9/7/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
// This work is licensed under the BSD-3 License included with this source
// distribution.

#import "SLFMapPin.h"

@implementation SLFMapPin

+ (NSString *)imageFileForPinColorIndex:(SLFMapPinColor)index status:(SLFMapPinStatus)status {
    
    NSString *pinColor = nil;    
    switch (index) {
        case SLFMapPinColorGreen:
            pinColor = @"Green";
            break;
        case SLFMapPinColorPurple:
            pinColor = @"Purple";
            break;
        case SLFMapPinColorBlue:
            pinColor = @"Blue";
            break;
        case SLFMapPinColorRed:
        default:
            pinColor = @"";
            break;
    }
    
    NSString *pinStatus = nil;
    switch (status) {
        case SLFMapPinStatusDown1:
            pinStatus = @"PinDown1";
            break;
        case SLFMapPinStatusDown2:
            pinStatus = @"PinDown2";
            break;
        case SLFMapPinStatusDown3:
            pinStatus = @"PinDown3";
            break;
        case SLFMapPinStatusFloating:
            pinStatus = @"PinFloating";
            break;
        case SLFMapPinStatusPressed:
            pinStatus = @"PinPressed";
            break;
        case SLFMapPinStatusHead:
            pinStatus = @"PinHead";
            break;
        case SLFMapPinStatusNormal:
        default:
            pinStatus = @"Pin";
            break;
    }
    return [NSString stringWithFormat:@"%@%@", pinStatus, pinColor];
}

+ (UIImage *)imageForPinColorIndex:(SLFMapPinColor)index status:(SLFMapPinStatus)status {
    UIImage *pinImage = nil;
    
    NSString *file = [SLFMapPin imageFileForPinColorIndex:index status:status];
    if (file)
        pinImage = [UIImage imageNamed:file];
    
    return pinImage;
}

+ (UIImage *)imageForMapAnnotation:(id <MKAnnotation>)annotation status:(SLFMapPinStatus)status {
    UIImage *image = nil;
    
    NSInteger pinColor = SLFMapPinColorGreen;
    if ([annotation respondsToSelector:@selector(pinColorIndex)]) {
        NSNumber *pinNumber = [annotation performSelector:@selector(pinColorIndex)];
        if (pinNumber)
            pinColor = [pinNumber integerValue];
    }
    
    image = [SLFMapPin imageForPinColorIndex:pinColor status:status];
    return image;
}


@end
