//
//	LegislatorMasterCellView.h
//
//  TexLege
//
//  Created by Gregory Combs on 8/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat kLegislatorMasterCellViewWidth;
extern const CGFloat kLegislatorMasterCellViewHeight;

@class LegislatorObj;
@interface LegislatorMasterCellView : UIView

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *tenure;
@property (nonatomic) BOOL useDarkBackground;
@property (nonatomic) BOOL highlighted;
@property (nonatomic, retain) UIImage *questionImage;

@property (nonatomic) CGFloat sliderValue;
@property (nonatomic) CGFloat sliderMin;
@property (nonatomic) CGFloat sliderMax;

- (void)setLegislator:(LegislatorObj *)value;

@end
