//
//	PartisanScaleView.h
//	
//
//	Created by  on 9/6/10
//	Copyright Like Thought, LLC. All rights reserved.
//	THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
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
