//
//  SLFAppearance.h
//  Created by Greg Combs on 9/22/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

@interface SLFAppearance : NSObject

+(void)setupAppearance;

+ (UIColor *)menuSelectedCellColor;
+ (UIColor *)menuTextColor;
+ (UIColor *)menuBackgroundColor;
+ (UIColor *)cellBackgroundDarkColor;
+ (UIColor *)cellBackgroundLightColor;
+ (UIColor *)cellTextColor;
+ (UIColor *)cellSecondaryTextColor;
+ (UIColor *)tableBackgroundLightColor;
+ (UIColor *)tableBackgroundDarkColor;
+ (UIColor *)tableSeparatorColor;
+ (UIColor *)tableSectionColor;
+ (UIColor *)accentGreenColor;
+ (UIColor *)accentBlueColor;
+ (UIColor *)partyRed;
+ (UIColor *)partyBlue;
+ (UIColor *)partyGreen;
@end

UIColor *SLFColorWithRGBShift(UIColor *color, int offset);
UIColor *SLFColorWithRGBA(int r, int g, int b, CGFloat a);
UIColor *SLFColorWithRGB(int red,  int green, int blue);
UIColor *SLFColorWithHex(char hex);
UIFont *SLFFont(CGFloat size);
UIFont *SLFTitleFont(CGFloat size);
UIFont *SLFItalicFont(CGFloat size);
extern NSString * const SLFAppearanceFontName;
extern NSString * const SLFAppearanceItalicsFontName;
extern NSString * const SLFAppearanceTitleFontName;
