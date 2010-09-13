//
//  CustomAnnotationView.m
//  TexLege
//
//  Created by Gregory Combs on 9/7/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "CustomAnnotation.h"
#import "TexLegeMapPins.h"

@interface CustomAnnotation (Private)

- (void)annotationChanged_:(NSNotification *)notification;

@end

@implementation CustomAnnotationView

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kCustomAnnotationAddressChangeNotificationKey object:self.annotation];	

	[super dealloc];
}


- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
		
		
		self.animatesDrop = YES;
		self.opaque = NO;
		self.draggable = YES;
		
		if (![annotation isKindOfClass:[CustomAnnotation class]])  
			return self;
		
		CustomAnnotation *customAnnotation = (CustomAnnotation *)annotation;

		self.canShowCallout = YES;

		NSInteger pinColorIndex = [[customAnnotation pinColorIndex] integerValue];
		if (pinColorIndex >= TexLegePinAnnotationColorBlue) {
			UIImage *pinImage = [TexLegeMapPins imageForPinColorIndex:pinColorIndex status:TexLegePinAnnotationStatusHead];
			UIImageView *pinHead = [[UIImageView alloc] initWithImage:pinImage];
			[self addSubview:pinHead];
			[pinHead release];
		}
		else
			self.pinColor = pinColorIndex;


		UIImage *anImage = [customAnnotation image];
		if (anImage) {
			UIImageView *iconView = [[UIImageView alloc] initWithImage:anImage];
			self.leftCalloutAccessoryView = iconView;
			[iconView release];
		}			
	
		//self.image = [TexLegeMapPins imageForPinColorIndex:TexLegePinAnnotationColorBlue status:TexLegePinAnnotationStatusNormal];
		//self.image = [UIImage imageNamed:@"Pin.png"];
		//self.centerOffset = CGPointMake(8, -14);
		//self.calloutOffset = CGPointMake(-8, 0);
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(annotationChanged_:) name:kCustomAnnotationAddressChangeNotificationKey object:annotation];
	}
	return self;
}

- (void)annotationChanged_:(NSNotification *)notification {
	[self setNeedsDisplay];
}
	
@end
