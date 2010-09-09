//
//  TexLegeMapPins.m
//  TexLege
//
//  Created by Gregory Combs on 9/7/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TexLegeMapPins.h"


@implementation TexLegeMapPins

+ (NSString *)imageFileForPinColorIndex:(NSInteger)index status:(NSInteger)status {
	
	NSString *pinColor = nil;	
	switch (index) {
		case TexLegePinAnnotationColorGreen:
			pinColor = @"Green";
			break;
		case TexLegePinAnnotationColorPurple:
			pinColor = @"Purple";
			break;
		case TexLegePinAnnotationColorBlue:
			pinColor = @"Blue";
			break;
		case TexLegePinAnnotationColorRed:
		default:
			pinColor = @"";
			break;
	}
	
	NSString *pinStatus = nil;
	switch (status) {
		case TexLegePinAnnotationStatusDown1:
			pinStatus = @"PinDown1";
			break;
		case TexLegePinAnnotationStatusDown2:
			pinStatus = @"PinDown2";
			break;
		case TexLegePinAnnotationStatusDown3:
			pinStatus = @"PinDown3";
			break;
		case TexLegePinAnnotationStatusFloating:
			pinStatus = @"PinFloating";
			break;
		case TexLegePinAnnotationStatusPressed:
			pinStatus = @"PinPressed";
			break;
		case TexLegePinAnnotationStatusHead:
			pinStatus = @"PinHead";
			break;
		case TexLegePinAnnotationStatusNormal:
		default:
			pinStatus = @"Pin";
			break;
	}
	
	NSString *pinFile = [NSString stringWithFormat:@"%@%@.png", pinStatus, pinColor];
	return pinFile;
}

+ (UIImage *)imageForPinColorIndex:(NSInteger)index status:(NSInteger)status {
	UIImage *pinImage = nil;
	
	NSString *file = [TexLegeMapPins imageFileForPinColorIndex:index status:status];
	if (file)
		pinImage = [UIImage imageNamed:file];
	
	return pinImage;
}

+ (UIImage *)imageForMapAnnotation:(id <MKAnnotation>)annotation status:(NSInteger)status {
	UIImage *image = nil;
	
	NSInteger pinColor = TexLegePinAnnotationColorGreen;
	if ([annotation respondsToSelector:@selector(pinColorIndex)]) {
		NSNumber *pinNumber = [annotation performSelector:@selector(pinColorIndex)];
		if (pinNumber)
			pinColor = [pinNumber integerValue];
	}
	
	image = [TexLegeMapPins imageForPinColorIndex:pinColor status:status];
	return image;
}


@end
