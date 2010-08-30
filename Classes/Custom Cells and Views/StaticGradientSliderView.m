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
#import "UtilityMethods.h"
#import "ImageCache.h"

@interface StaticGradientSliderView (Private)

- (void) setBackgroundOffset;

@end

@implementation StaticGradientSliderView
@synthesize sliderControl, gradientImage;

- (id)initWithFrame:(CGRect)aRect {
	if (self = [super initWithFrame:aRect]) 
	{
		if (aRect.size.height == 0.f)
			aRect.size.height = 24.0f;
		if (aRect.size.width == 0.f)
			aRect.size.width = 300.0f;
		
		self.frame = aRect;
		
		self.contentMode = UIViewContentModeCenter;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		self.autoresizesSubviews = self.clearsContextBeforeDrawing = YES;
		self.userInteractionEnabled = self.clipsToBounds = self.multipleTouchEnabled = NO;
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];

		if (self.gradientImage) {
			self.gradientImage = nil;
		}
		
		//self.gradientImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TexasGradient"]];
		self.gradientImage = [[[UIImageView alloc] initWithFrame:CGRectMake(12.0, 6.0, 276.0, 14.0)] autorelease];
		self.gradientImage.image = [UIImage imageNamed:@"TexasGradient.png"];

		//self.gradientImage.frame = CGRectMake(12.0, 6.0, 276.0, 14.0);
		self.gradientImage.autoresizesSubviews = self.gradientImage.clearsContextBeforeDrawing = YES;
		self.gradientImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		self.gradientImage.clearsContextBeforeDrawing = YES;
		self.gradientImage.contentMode = UIViewContentModeScaleToFill;
		self.gradientImage.clipsToBounds = self.gradientImage.multipleTouchEnabled = self.gradientImage.userInteractionEnabled = NO;
		self.gradientImage.opaque = NO;
		self.gradientImage.backgroundColor = [UIColor clearColor];
		self.gradientImage.highlighted = NO;

		if (self.sliderControl)
			self.sliderControl = nil;
		
		self.sliderControl = [[[UISlider alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 23.0)] autorelease];
		self.sliderControl.autoresizesSubviews = YES;
		self.sliderControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		
		self.sliderControl.clipsToBounds = self.sliderControl.multipleTouchEnabled = self.sliderControl.userInteractionEnabled = NO;
		self.sliderControl.clearsContextBeforeDrawing = YES;
		self.sliderControl.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		self.sliderControl.contentMode = UIViewContentModeScaleAspectFill;
		self.sliderControl.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
		self.sliderControl.continuous = YES;
		self.sliderControl.opaque = NO;
		self.sliderControl.backgroundColor = [UIColor clearColor];
		self.sliderControl.maximumValue = 1.250;
		self.sliderControl.minimumValue = -1.250;
		self.sliderControl.value = 0.005;
		self.sliderControl.highlighted = YES;
		self.sliderControl.selected = YES;
		//self.sliderControl.enabled = NO;
		
		//self.usesSmallStar = (![UtilityMethods isIPadDevice]);
		m_usesSmallStar = NO;
		self.usesSmallStar = YES;	// This forces it to initialize the first time
		
		UIImage *emptyImage = [[UIImage allocWithZone:[self zone]] init]; // should we autorelease??????
		[self.sliderControl setMinimumTrackImage:emptyImage forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected & UIControlStateDisabled];
		[self.sliderControl setMaximumTrackImage:emptyImage forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected & UIControlStateDisabled];
		[emptyImage release], emptyImage = nil;	
		
		
		[self addSubview:self.gradientImage];
		[self addSubview:self.sliderControl];
		
	}
	return self;
}

- (void)setBackgroundColor:(UIColor *)color {
	[super setBackgroundColor:color];
	self.gradientImage.backgroundColor = color;
	self.opaque = self.gradientImage.opaque = (![color isEqual:[UIColor clearColor]]);
}

- (void) setUsesSmallStar:(BOOL)isSmall {
	if (isSmall != m_usesSmallStar) {
		NSString *starString = (isSmall) ? @"slider_star.png" : @"slider_star_big.png";
		UIImage *starImage = [UIImage imageNamed:starString];
		[self.sliderControl setThumbImage:starImage forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected & UIControlStateDisabled];
		m_usesSmallStar = isSmall;
		
		[self setBackgroundOffset];
	}
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

- (void)dealloc {
	if (self.gradientImage)
		self.gradientImage.image = nil;

	self.sliderControl = nil;
	self.gradientImage = nil;
    [super dealloc];
}

- (float)sliderValue {	
	return self.sliderControl.value;
}

- (void)setSliderValue:(float)newVal {
	[self setSliderValue:newVal animated:YES];
}

- (void)setSliderValue:(float)newVal animated:(BOOL)isAnimated {
	if (newVal == 0.0f) {
		NSString *imageString = (self.usesSmallStar) ? @"Slider_Question.png" : @"Slider_Question_big.png";
		UIImage *questionImage = [UIImage imageNamed:imageString];
		[self.sliderControl setThumbImage:questionImage forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected & UIControlStateDisabled];
		[self setAlpha:0.5f];
	}
	else {
		[self setUsesSmallStar:m_usesSmallStar];
		[self setAlpha:1.0f];
	}

	[self.sliderControl setValue:newVal animated:isAnimated];
	//[self.sliderControl setNeedsDisplay];	// GREG, do we need this???
	//debug_NSLog(@"Min: %f   Max: %f", self.sliderControl.minimumValue, self.sliderControl.maximumValue);
	//debug_NSLog(@"Value: %f", newVal);

}

- (void)addToPlaceholder:(UIView *)placeholder {
	if (placeholder) {
		CGRect placeholderRect = placeholder.bounds;
		[placeholder addSubview:self];
		self.frame = placeholderRect;
	}
}

- (void) setLegislator:(LegislatorObj *)legislator {
	if (legislator) {
		PartisanIndexStats *indexStats = [PartisanIndexStats sharedPartisanIndexStats];
		
		CGFloat minSlider = [[indexStats minPartisanIndexUsingLegislator:legislator] floatValue];
		CGFloat maxSlider = [[indexStats maxPartisanIndexUsingLegislator:legislator] floatValue];
		[self.sliderControl setMinimumValue:minSlider];
		[self.sliderControl setMaximumValue:maxSlider];
	}
}


@end
