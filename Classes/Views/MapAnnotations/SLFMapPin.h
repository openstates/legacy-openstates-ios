//
//  SLFMapPin.h
//  Created by Gregory Combs on 9/7/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <MapKit/MapKit.h>

enum {
    SLFMapPinColorRed = 0,
    SLFMapPinColorGreen,
    SLFMapPinColorPurple,
    // end compatibility with MKPinAnnotation colors
    SLFMapPinColorBlue = 99
};
typedef NSUInteger SLFMapPinColor;


enum {
    SLFMapPinStatusNormal = 0,
    SLFMapPinStatusDown1,
    SLFMapPinStatusDown2,
    SLFMapPinStatusDown3,
    SLFMapPinStatusFloating,
    SLFMapPinStatusPressed,
    //
    SLFMapPinStatusHead = 99
    
};
typedef NSUInteger SLFMapPinStatus;

@interface SLFMapPin : NSObject {
}

+ (UIImage *)imageForMapAnnotation:(id <MKAnnotation>)annotation status:(NSInteger)status;
+ (UIImage *)imageForPinColorIndex:(NSInteger)index status:(NSInteger)status;
+ (NSString *)imageFileForPinColorIndex:(NSInteger)index status:(NSInteger)status;
@end
