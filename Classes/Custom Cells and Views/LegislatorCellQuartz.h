//
//	LegislatorMasterTableViewCell.h
//  Created by Gregory Combs on 8/29/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
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
