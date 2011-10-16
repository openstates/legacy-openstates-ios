//
//  SLFMapPins.m
//  Created by Gregory Combs on 9/7/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFMapPins.h"

@implementation SLFMapPins

+ (NSString *)imageFileForPinColorIndex:(NSInteger)index status:(NSInteger)status {
    
    NSString *pinColor = nil;    
    switch (index) {
        case SLFPinAnnotationColorGreen:
            pinColor = @"Green";
            break;
        case SLFPinAnnotationColorPurple:
            pinColor = @"Purple";
            break;
        case SLFPinAnnotationColorBlue:
            pinColor = @"Blue";
            break;
        case SLFPinAnnotationColorRed:
        default:
            pinColor = @"";
            break;
    }
    
    NSString *pinStatus = nil;
    switch (status) {
        case SLFPinAnnotationStatusDown1:
            pinStatus = @"PinDown1";
            break;
        case SLFPinAnnotationStatusDown2:
            pinStatus = @"PinDown2";
            break;
        case SLFPinAnnotationStatusDown3:
            pinStatus = @"PinDown3";
            break;
        case SLFPinAnnotationStatusFloating:
            pinStatus = @"PinFloating";
            break;
        case SLFPinAnnotationStatusPressed:
            pinStatus = @"PinPressed";
            break;
        case SLFPinAnnotationStatusHead:
            pinStatus = @"PinHead";
            break;
        case SLFPinAnnotationStatusNormal:
        default:
            pinStatus = @"Pin";
            break;
    }
    return [NSString stringWithFormat:@"%@%@", pinStatus, pinColor];
}

+ (UIImage *)imageForPinColorIndex:(NSInteger)index status:(NSInteger)status {
    UIImage *pinImage = nil;
    
    NSString *file = [SLFMapPins imageFileForPinColorIndex:index status:status];
    if (file)
        pinImage = [UIImage imageNamed:file];
    
    return pinImage;
}

+ (UIImage *)imageForMapAnnotation:(id <MKAnnotation>)annotation status:(NSInteger)status {
    UIImage *image = nil;
    
    NSInteger pinColor = SLFPinAnnotationColorGreen;
    if ([annotation respondsToSelector:@selector(pinColorIndex)]) {
        NSNumber *pinNumber = [annotation performSelector:@selector(pinColorIndex)];
        if (pinNumber)
            pinColor = [pinNumber integerValue];
    }
    
    image = [SLFMapPins imageForPinColorIndex:pinColor status:status];
    return image;
}


@end
