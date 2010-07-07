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
/*
- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
	
	self.leg_photoView.backgroundColor = backgroundColor;
	self.leg_titleLab.backgroundColor = backgroundColor;
	self.leg_partyDistLab.backgroundColor = backgroundColor;
	self.leg_tenureLab.backgroundColor = backgroundColor;
	self.leg_nameLab.backgroundColor = backgroundColor;
	self.leg_sliderViewPlaceHolder.backgroundColor = backgroundColor;
	self.leg_sliderView.backgroundColor = backgroundColor;	
}
*/
- (void)dealloc {
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
	
	if (self.leg_sliderView == nil) {
		NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"StaticGradientSliderView" owner:self options:NULL];
		for (id suspect in objects) {
			if ([suspect isKindOfClass:[StaticGradientSliderView class]]) {
				self.leg_sliderView = suspect;
			}
		}
	}
	if (self.leg_sliderView) {
		CGRect sliderViewFrame = self.leg_sliderViewPlaceHolder.frame;
		[self.leg_sliderView setFrame:sliderViewFrame];
		[self.leg_sliderView.sliderControl setThumbImage:[UIImage imageNamed:@"slider_star.png"] forState:UIControlStateNormal];

		self.leg_sliderView.sliderControl.value = self.legislator.partisan_index.floatValue;
		[self.contentView addSubview:self.leg_sliderView];
	}
	
}



@end
