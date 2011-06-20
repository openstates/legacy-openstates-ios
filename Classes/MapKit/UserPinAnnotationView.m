//
//  CustomAnnotationView.m
//  TexLege
//
//  Created by Gregory Combs on 9/7/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "UserPinAnnotationView.h"
#import "UserPinAnnotation.h"
#import "TexLegeMapPins.h"

@interface UserPinAnnotationView (Private)

- (void)annotationChanged_:(NSNotification *)notification;

@end

@implementation UserPinAnnotationView

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];	

	[super dealloc];
}


- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
		
		
		self.animatesDrop = YES;
		self.opaque = NO;
		self.draggable = YES;
		
		if (![annotation isKindOfClass:[UserPinAnnotation class]])  
			return self;
		
		UserPinAnnotation *customAnnotation = (UserPinAnnotation *)annotation;

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
	
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(annotationChanged_:) name:kUserPinAnnotationAddressChangeKey object:annotation];
	}
	return self;
}

- (void)annotationChanged_:(NSNotification *)notification {
	[self setNeedsDisplay];
}
	
// MKPinAnnotationView+ZIndexFix
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self.superview bringSubviewToFront:self];
	[super touchesBegan:touches withEvent:event];
}

@end
