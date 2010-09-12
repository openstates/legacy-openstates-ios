//
//	LegislatorMasterCellView.h
//
//	Created by Gregory Combs on 8/30/10
//	Copyright Like Thought, LLC. All rights reserved.
//	THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import <UIKit/UIKit.h>

extern const CGFloat kLegislatorMasterCellViewWidth;
extern const CGFloat kLegislatorMasterCellViewHeight;

@class LegislatorObj;
@interface LegislatorMasterCellView : UIView

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *tenure;
@property (nonatomic, retain) LegislatorObj *legislator;
@property (nonatomic) BOOL useDarkBackground;
@property (nonatomic) BOOL highlighted;
@property (nonatomic, retain) UIImage *questionImage;

@property (nonatomic) CGFloat sliderValue;
@property (nonatomic) CGFloat sliderMin;
@property (nonatomic) CGFloat sliderMax;

@end
