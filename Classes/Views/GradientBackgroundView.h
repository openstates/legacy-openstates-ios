//
//  GradientBackgroundView.h
//  Created by Greg Combs on 9/29/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


@interface GradientBackgroundView : UIView
- (void)loadLayerAndGradientColors;
- (void)loadLayerAndGradientWithColors:(NSArray *)colors;
@end

@class CAGradientLayer;
@interface GradientInnerShadowView : UIView 
@property (nonatomic,retain) CAGradientLayer *gradient;
@end

