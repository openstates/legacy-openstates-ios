//
//  TexLegePinAnnotationView.m
//  TexLege
//
//  Created by Gregory Combs on 9/13/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TexLegePinAnnotationView.h"
#import "DistrictMapObj.h"
#import "DistrictOfficeObj.h"
#import "TexLegeMapPins.h"

@interface TexLegePinAnnotationView (Private)
- (void)resetPinColorWithAnnotation:(id <MKAnnotation>)anAnnotation;
@end
	
@implementation TexLegePinAnnotationView


- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
		self.animatesDrop = YES;
		self.opaque = NO;
		self.draggable = NO;
		self.canShowCallout = YES;
				
		UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];			
		self.rightCalloutAccessoryView = rightButton;
		
		[self resetPinColorWithAnnotation:annotation];
		
	}
	return self;
}

- (void)resetPinColorWithAnnotation:(id <MKAnnotation>)anAnnotation {
	if (!anAnnotation || 
		(![anAnnotation isKindOfClass:[DistrictMapObj class]] && ![anAnnotation isKindOfClass:[DistrictOfficeObj class]]))  
		return;
		
	UIView *foundPinImage = nil;
	for (UIView* suspect in self.subviews) {
		if (suspect.tag == 999) {
			foundPinImage = suspect;
			break;
		}
	}
	
	if (foundPinImage)
		[foundPinImage removeFromSuperview];
	
	NSInteger pinColorIndex = MKPinAnnotationColorRed;
	if ([anAnnotation respondsToSelector:@selector(pinColorIndex)]) {
		NSNumber *pinColorNumber = [anAnnotation performSelector:@selector(pinColorIndex)];
		if (pinColorNumber)
			pinColorIndex = [pinColorNumber integerValue];
	}
		
	if (pinColorIndex < TexLegePinAnnotationColorBlue)
		
		[self setPinColor:pinColorIndex];
	else {
		UIImage *pinImage = [TexLegeMapPins imageForPinColorIndex:pinColorIndex status:TexLegePinAnnotationStatusHead];
		UIImageView *pinHead = [[UIImageView alloc] initWithImage:pinImage];
		pinHead.tag = 999;
		[self addSubview:pinHead];
		[pinHead release];
	}
	
	UIImage *anImage = [self.annotation performSelector:@selector(image)];
	if (anImage) {
		UIImageView *iconView = [[UIImageView alloc] initWithImage:anImage];
		self.leftCalloutAccessoryView = iconView;
		[iconView release];
	}
}

@end
