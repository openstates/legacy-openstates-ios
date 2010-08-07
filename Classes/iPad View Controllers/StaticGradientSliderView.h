//
//  StaticGradientSliderView.h
//  TexLege
//
//  Created by Gregory Combs on 6/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LegislatorObj;
@interface StaticGradientSliderView : UIView {
	IBOutlet UIImageView *gradientImage;
	IBOutlet UISlider *sliderControl;
	
@private
	BOOL	m_usesSmallStar;
}

@property (nonatomic, retain) IBOutlet UIImageView *gradientImage;
@property (nonatomic, retain) IBOutlet UISlider *sliderControl;
@property (nonatomic) CGFloat sliderValue;
@property (readwrite) BOOL usesSmallStar;		// defaults to big star, not small star

- (void)setSliderValue:(float)newVal animated:(BOOL)isAnimated;
- (void)addToPlaceholder:(UIView *)placeholder;
- (void)setLegislator:(LegislatorObj *)legislator;

@end
