//
//  LegislatorMasterTableViewCell.h
//  Created by Gregory Combs on 6/28/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
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
