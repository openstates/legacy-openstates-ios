//
//	LegislatorMasterCellView.h
//	New Image
//
//	Created by Gregory Combs on 8/9/10
//	Copyright Like Thought, LLC. All rights reserved.
//	THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import <UIKit/UIKit.h>

extern const CGFloat kLegislatorCellViewWidth;
extern const CGFloat kLegislatorCellViewHeight;

@class LegislatorObj;

@interface MyView : UIView
{
}

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *tenure;
@property (nonatomic) CGFloat sliderValue;
@property (nonatomic, retain) LegislatorObj *legislator;
@property (nonatomic) BOOL useDarkBackground;
@property (nonatomic, retain) UIImage *photo;
@property (nonatomic) BOOL highlighted;
@end
