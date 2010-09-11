//
//	CommitteeMemberCellView.h
//	LegislatorMasterCellView
//
//	Created by Gregory Combs on 9/10/10
//	Copyright Like Thought, LLC. All rights reserved.
//	THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import <UIKit/UIKit.h>

extern const CGFloat kCommitteeMemberCellViewWidth;
extern const CGFloat kCommitteeMemberCellViewHeight;

@class LegislatorObj;
@interface CommitteeMemberCellView : UIView
{
}

@property (retain, nonatomic) LegislatorObj *legislator;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *tenure;

@property (copy, nonatomic) NSString *party;
@property (copy, nonatomic) NSString *rank;
@property (copy, nonatomic) NSString *district;

@property (nonatomic) CGFloat sliderValue;
@property (nonatomic) CGFloat sliderMin;
@property (nonatomic) CGFloat sliderMax;

@property (retain, nonatomic) UIImage *questionImage;
@property (nonatomic) BOOL highlighted;

@end
