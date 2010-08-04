//
//  LegislatorMasterTableViewCell.m
//  TexLege
//
//  Created by Gregory Combs on 6/28/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "LegislatorMasterTableViewCell.h"
#import "StaticGradientSliderView.h"

#import "LegislatorObj.h"
#import "UtilityMethods.h"

@interface LegislatorMasterTableViewCell (Private)

@end


@implementation LegislatorMasterTableViewCell

@synthesize leg_photoView, leg_titleLab, leg_partyDistLab, leg_tenureLab, leg_nameLab, leg_sliderViewPlaceHolder, leg_sliderView;
@synthesize legislator, backgroundLight, backgroundDark;

- (void)awakeFromNib {
	//self.backgroundDark = [UIColor colorWithRed:0.592f green:0.596f blue:0.608f alpha:1.0];
	//self.backgroundLight = [UIColor colorWithRed:0.675f green:0.678f blue:0.686f alpha:1.0];
	self.backgroundDark = [UIColor colorWithRed:0.855f green:0.914f blue:0.886f alpha:1.0];
	self.backgroundLight = [UIColor colorWithRed:0.981f green:0.984f blue:0.984f alpha:1.0];;
	//UIColor *detailColor = [UIColor colorWithRed:0.293f green:0.337f blue:0.384f alpha:1.0];
	//UIColor *typeColor = [UIColor colorWithRed:0.592f green:0.631f blue:0.651f alpha:1.0];

}


/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
*/

// DARK middle:  151, 152, 155
// LIGHT middle: 172, 173, 175

- (BOOL)useDarkBackground {
	return useDarkBackground;
}

- (void)setUseDarkBackground:(BOOL)flag
{
    //if (flag != useDarkBackground || !self.backgroundView)
    {
        useDarkBackground = flag;
		
        //NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:useDarkBackground ? @"DarkBackground" : @"LightBackground" ofType:@"png"];
        //UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
        //self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
        //self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //self.backgroundView.frame = self.bounds;
		
		UIColor *labelBGColor = (useDarkBackground) ? self.backgroundDark : self.backgroundLight;
		self.backgroundColor = labelBGColor;
		self.backgroundView.backgroundColor = labelBGColor;
		
		self.leg_photoView.backgroundColor = labelBGColor;
		self.leg_titleLab.backgroundColor = labelBGColor;
		self.leg_partyDistLab.backgroundColor = labelBGColor;
		self.leg_tenureLab.backgroundColor = labelBGColor;
		self.leg_nameLab.backgroundColor = labelBGColor;
		self.leg_sliderViewPlaceHolder.backgroundColor = labelBGColor;
		self.leg_sliderView.backgroundColor = labelBGColor;
    }	
}

- (void)dealloc {
	self.leg_photoView = nil;
	self.leg_titleLab = self.leg_partyDistLab = self.leg_tenureLab = self.leg_nameLab = nil;
	self.leg_sliderViewPlaceHolder = self.leg_sliderView = nil;
	self.legislator = nil;
	self.backgroundDark = self.backgroundLight = nil;
    [super dealloc];
}


- (void) setupWithLegislator:(LegislatorObj *)newLegislator {
	if (newLegislator == nil)
		return;
	self.legislator = newLegislator;
	
	self.leg_photoView.image = [UtilityMethods poorMansImageNamed:self.legislator.photo_name];
	self.leg_titleLab.text = self.legislator.legtype_name;
	self.leg_nameLab.text = [self.legislator legProperName];
	self.leg_partyDistLab.text = [self.legislator districtPartyString];
	self.leg_tenureLab.text = [self.legislator tenureString];
	
	if (self.leg_sliderView == nil)
		self.leg_sliderView = [StaticGradientSliderView newSliderViewWithOwner:self];
	if (self.leg_sliderView) {
		[self.leg_sliderView addToPlaceholder:self.leg_sliderViewPlaceHolder withLegislator:self.legislator];
		self.leg_sliderView.usesSmallStar = YES;
		//self.leg_sliderView.sliderValue = self.legislator.partisan_index.floatValue;
		[self.leg_sliderView setSliderValue:self.legislator.partisan_index.floatValue animated:NO];
	}
	
}



@end
