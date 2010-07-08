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
	UIImage *emptyImage = [[UIImage alloc] init]; // should we autorelease??????
	[self.sliderControl setMinimumTrackImage:emptyImage forState:UIControlStateNormal];
	[self.sliderControl setMaximumTrackImage:emptyImage forState:UIControlStateNormal];
	[self.sliderControl setThumbImage:[UIImage imageNamed:@"slider_star_big.png"] forState:UIControlStateNormal];
	[emptyImage release], emptyImage = nil;	
}


/*
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self prepareUI];
    }
    return self;
}
*/

- (void)awakeFromNib {
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


@end
