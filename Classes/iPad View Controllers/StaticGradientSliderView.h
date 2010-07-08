//
//  StaticGradientSliderView.h
//  TexLege
//
//  Created by Gregory Combs on 6/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StaticGradientSliderView : UIView {
	IBOutlet UIImageView *gradientImage;
	IBOutlet UISlider *sliderControl;
}

@property (nonatomic, retain) IBOutlet UIImageView *gradientImage;
@property (nonatomic, retain) IBOutlet UISlider *sliderControl;
@property (nonatomic) CGFloat sliderValue;

- (void)setSliderValue:(float)newVal animated:(BOOL)isAnimated;

@end
