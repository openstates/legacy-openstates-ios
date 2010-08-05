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
#import "TexLegeTheme.h"

@interface LegislatorMasterTableViewCell (Private)

@end


@implementation LegislatorMasterTableViewCell

@synthesize leg_photoView, leg_titleLab, leg_partyDistLab, leg_tenureLab, leg_nameLab, leg_sliderViewPlaceHolder, leg_sliderView;
@synthesize legislator, backgroundLight, backgroundDark, detailColor, typeColor;

- (void)awakeFromNib {
	self.backgroundDark = [TexLegeTheme backgroundDark];
	self.backgroundLight = [TexLegeTheme backgroundLight];
	self.detailColor = [TexLegeTheme textDark];
	self.typeColor = [TexLegeTheme accent];
	//self.accessoryView = [TexLegeTheme disclosureLabel:NO];
	self.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]] autorelease];
	self.selectionStyle = UITableViewCellSelectionStyleBlue;	
	
	self.leg_titleLab.highlightedTextColor = self.leg_partyDistLab.highlightedTextColor = self.leg_tenureLab.highlightedTextColor = self.leg_nameLab.highlightedTextColor = [TexLegeTheme backgroundLight];
	
	self.leg_titleLab.textColor = self.leg_partyDistLab.textColor = self.typeColor;
	self.leg_tenureLab.textColor = [TexLegeTheme textLight];
	self.leg_nameLab.textColor = self.detailColor;
	self.leg_nameLab.font = [TexLegeTheme boldFifteen];
	
	self.leg_titleLab.font = self.leg_partyDistLab.font = [TexLegeTheme boldTwelve];
	self.leg_tenureLab.font = [TexLegeTheme boldTwelve];
	
}


/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
*/

- (BOOL)useDarkBackground {
	return useDarkBackground;
}

- (void)setUseDarkBackground:(BOOL)flag
{
	if (self.selected || self.highlighted)
		return;

	useDarkBackground = flag;
		
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

- (void)dealloc {
	self.leg_photoView = nil;
	self.leg_titleLab = self.leg_partyDistLab = self.leg_tenureLab = self.leg_nameLab = nil;
	self.leg_sliderViewPlaceHolder = self.leg_sliderView = nil;
	self.legislator = nil;
	self.backgroundDark = self.backgroundLight = self.typeColor = self.detailColor = nil;
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
		[self.leg_sliderView setSliderValue:self.legislator.partisan_index.floatValue animated:NO];
	}
	
}



@end
