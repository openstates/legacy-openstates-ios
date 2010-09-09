//
//  TexLegeMapPins.h
//  TexLege
//
//  Created by Gregory Combs on 9/7/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

enum {
    TexLegePinAnnotationColorRed = 0,
    TexLegePinAnnotationColorGreen,
    TexLegePinAnnotationColorPurple,
	// end compatibility with MKPinAnnotation colors
	TexLegePinAnnotationColorBlue = 99
};
typedef NSUInteger TexLegePinAnnotationColor;


enum {
    TexLegePinAnnotationStatusNormal = 0,
    TexLegePinAnnotationStatusDown1,
    TexLegePinAnnotationStatusDown2,
	TexLegePinAnnotationStatusDown3,
	TexLegePinAnnotationStatusFloating,
	TexLegePinAnnotationStatusPressed,
	//
	TexLegePinAnnotationStatusHead = 99
	
};
typedef NSUInteger TexLegePinAnnotationStatus;



@interface TexLegeMapPins : NSObject {

}

+ (UIImage *)imageForMapAnnotation:(id <MKAnnotation>)annotation status:(NSInteger)status;
+ (UIImage *)imageForPinColorIndex:(NSInteger)index status:(NSInteger)status;
+ (NSString *)imageFileForPinColorIndex:(NSInteger)index status:(NSInteger)status;
@end
