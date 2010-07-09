//
//  StaticGradientSliderView.m
//  TexLege
//
//  Created by Gregory Combs on 6/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "StaticGradientSliderView.h"

@interface StaticGradientSliderView (Private)

- (void)prepareUI;

@end

@implementation StaticGradientSliderView
@synthesize sliderControl, gradientImage;

- (void)prepareUI {
	UIImage *emptyImage = [[UIImage allocWithZone:[self zone]] init]; // should we autorelease??????
	[self.sliderControl setMinimumTrackImage:emptyImage forState:UIControlStateNormal];
	[self.sliderControl setMaximumTrackImage:emptyImage forState:UIControlStateNormal];
	[self setUsesSmallStar:NO];
	[emptyImage release], emptyImage = nil;	
}

- (void) setUsesSmallStar:(BOOL)isSmall {
	NSString *starString = (isSmall) ? @"slider_star.png" : @"slider_star_big.png";
	[self.sliderControl setThumbImage:[UIImage imageNamed:starString] forState:UIControlStateNormal];
	m_usesSmallStar = isSmall;
}

- (BOOL) usesSmallStar {
	return m_usesSmallStar;
}

- (void)awakeFromNib {
	m_usesSmallStar = NO;
	[self prepareUI];
}

- (void)dealloc {
	self.sliderControl = self.gradientImage = nil;
    [super dealloc];
}

- (float)sliderValue {	
	return self.sliderControl.value;
}

- (void)setSliderValue:(float)newVal {
	//self.sliderControl.value = newVal; 
	[self.sliderControl setValue:newVal animated:YES];
}

- (void)setSliderValue:(float)newVal animated:(BOOL)isAnimated {
	//self.sliderControl.value = newVal; 
	[self.sliderControl setValue:newVal animated:isAnimated];
}

- (void)addToPlaceholder:(UIView *)placeholder {
	if (placeholder) {
		CGRect placeholderRect = placeholder.bounds;
		[placeholder addSubview:self];
		self.frame = placeholderRect;
	}
}

+ (StaticGradientSliderView *) newSliderViewWithOwner:(id)owner {
	NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"StaticGradientSliderView" owner:owner options:NULL];
	for (id suspect in objects)
		if ([suspect isKindOfClass:[StaticGradientSliderView class]]) {
			return suspect;
		}
	return nil;
}

@end
