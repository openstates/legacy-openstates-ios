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
@synthesize legislator, useDarkBackground;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
*/

- (void)setUseDarkBackground:(BOOL)flag
{
    if (flag != useDarkBackground || !self.backgroundView)
    {
        useDarkBackground = flag;
		
        NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:useDarkBackground ? @"DarkBackground" : @"LightBackground" ofType:@"png"];
        UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
        self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.frame = self.bounds;
    }
}

- (void)dealloc {
	self.leg_photoView = self.leg_titleLab = self.leg_partyDistLab = self.leg_tenureLab = self.leg_nameLab = nil;
	self.leg_sliderViewPlaceHolder = self.leg_sliderView = nil;
	self.legislator = nil;
	
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
		[self.leg_sliderView addToPlaceholder:self.leg_sliderViewPlaceHolder];
		self.leg_sliderView.usesSmallStar = YES;
		//self.leg_sliderView.sliderValue = self.legislator.partisan_index.floatValue;
		[self.leg_sliderView setSliderValue:self.legislator.partisan_index.floatValue animated:NO];
	}
	
}



@end
