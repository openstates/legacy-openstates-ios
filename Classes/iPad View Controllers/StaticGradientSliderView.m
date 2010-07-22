//
//  StaticGradientSliderView.m
//  TexLege
//
//  Created by Gregory Combs on 6/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "StaticGradientSliderView.h"
#import "LegislatorObj.h"
#import "PartisanIndexStats.h"

@interface StaticGradientSliderView (Private)

- (void)prepareUI;
- (void) setBackgroundOffset;

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
	
	[self setBackgroundOffset];
}

- (void) setBackgroundOffset {	
	CGFloat thumbWidth = self.sliderControl.currentThumbImage.size.width;
	CGRect sliderRect = self.sliderControl.bounds;
	CGRect backgroundRect = self.gradientImage.bounds;
	backgroundRect.origin.x = sliderRect.origin.x + (thumbWidth/2);
	backgroundRect.size.width = sliderRect.size.width - thumbWidth;
	
	[self.gradientImage setBounds:backgroundRect];
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
	[self setSliderValue:newVal animated:YES];
}

- (void)setSliderValue:(float)newVal animated:(BOOL)isAnimated {
	if (newVal == 0.0) {
		NSString *imageString = (self.usesSmallStar) ? @"Slider_Question.png" : @"Slider_Question_big.png";
		[self.sliderControl setThumbImage:[UIImage imageNamed:imageString] forState:UIControlStateNormal];
		[self setAlpha:0.5];
	}
	[self.sliderControl setValue:newVal animated:isAnimated];
	//[self.sliderControl setNeedsDisplay];	// GREG, do we need this???
	NSLog(@"Min: %f   Max: %f", self.sliderControl.minimumValue, self.sliderControl.maximumValue);
	NSLog(@"Value: %f", newVal);

}

- (void)addToPlaceholder:(UIView *)placeholder withLegislator:(LegislatorObj *)legislator {
	if (placeholder) {
		CGRect placeholderRect = placeholder.bounds;
		[placeholder addSubview:self];
		self.frame = placeholderRect;
	}
	[self setLegislator:legislator];
}

+ (StaticGradientSliderView *) newSliderViewWithOwner:(id)owner {
	NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"StaticGradientSliderView" owner:owner options:NULL];
	for (id suspect in objects)
		if ([suspect isKindOfClass:[StaticGradientSliderView class]]) {
			return suspect;
		}
	return nil;
}

- (void) setLegislator:(LegislatorObj *)legislator {
	if (legislator) {
		PartisanIndexStats *indexStats = [PartisanIndexStats sharedPartisanIndexStats];
		
		CGFloat minSlider = [[indexStats minPartisanIndexUsingLegislator:legislator] floatValue];
		CGFloat maxSlider = [[indexStats maxPartisanIndexUsingLegislator:legislator] floatValue];
		[self.sliderControl setMinimumValue:minSlider];
		[self.sliderControl setMaximumValue:maxSlider];
	}}


@end
