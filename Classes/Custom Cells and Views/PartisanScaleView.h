//
//	PartisanScaleView.h
//
//  TexLege
//
//  Created by Gregory Combs on 8/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat kPartisanScaleViewWidth;
extern const CGFloat kPartisanScaleViewHeight;

@interface PartisanScaleView : UIView
@property (nonatomic) BOOL highlighted;
@property (nonatomic) BOOL showUnknown;

@property (nonatomic) CGFloat sliderValue;
@property (nonatomic) CGFloat sliderMin;
@property (nonatomic) CGFloat sliderMax;
@property (nonatomic,retain) UIImage *questionImage;


@end
