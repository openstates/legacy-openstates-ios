//
//	LegislatorMasterTableViewCell.h
//	New Image
//
//	Created by Gregory Combs on 8/8/10
//	Copyright Like Thought, LLC. All rights reserved.
//	THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import <UIKit/UIKit.h>

extern const CGFloat kLegislatorTableViewCellWidth;
extern const CGFloat kLegislatorTableViewCellHeight;

@interface LegislatorCellQuartz : UIView
{
	NSString *title;
	NSString *name;
	UIColor *background;
	UIColor *textDark;
	UIColor *textLight;
	UIColor *accent;
	NSString *tenure;
	UIColor *texasRed;
	UIColor *texasBlue;
	CGFloat sliderValue;
}

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *name;
@property (retain, nonatomic) UIColor *background;
@property (retain, nonatomic) UIColor *textDark;
@property (retain, nonatomic) UIColor *textLight;
@property (retain, nonatomic) UIColor *accent;
@property (copy, nonatomic) NSString *tenure;
@property (retain, nonatomic) UIColor *texasRed;
@property (retain, nonatomic) UIColor *texasBlue;
@property (nonatomic) CGFloat sliderValue;

@end
