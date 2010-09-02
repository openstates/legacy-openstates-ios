//
//  LegislatorMasterTableViewCell.h
//  TexLege
//
//  Created by Gregory Combs on 6/28/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LegislatorObj;
@class StaticGradientSliderView;

@interface LegislatorMasterTableViewCell : UITableViewCell {
	BOOL useDarkBackground;
}

@property BOOL useDarkBackground;

@property (nonatomic,retain) IBOutlet UIView *disclosureView;
@property (nonatomic,retain) IBOutlet UIImageView *leg_photoView;
@property (nonatomic,retain) IBOutlet UILabel *leg_titleLab;
@property (nonatomic,retain) IBOutlet UILabel *leg_tenureLab;
@property (nonatomic,retain) IBOutlet UILabel *leg_nameLab;
@property (nonatomic,retain) IBOutlet UIView	*leg_sliderViewPlaceHolder;
@property (nonatomic,retain) IBOutlet StaticGradientSliderView *leg_sliderView;

@property (nonatomic,retain) UIColor *backgroundLight;
@property (nonatomic,retain) UIColor *backgroundDark;
@property (nonatomic,retain) UIColor *detailColor;
@property (nonatomic,retain) UIColor *typeColor;

@property (nonatomic,retain) LegislatorObj *legislator;

- (void)setupWithLegislator:(LegislatorObj *)newLegislator;
@end
