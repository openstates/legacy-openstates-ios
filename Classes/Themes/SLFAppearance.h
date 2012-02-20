//
//  SLFAppearance.h
//  Created by Greg Combs on 9/22/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

@interface SLFAppearance : NSObject

+(void)setupAppearance;

+ (UIColor *)navBarTextColor;
+ (UIColor *)menuTextColor;
+ (UIColor *)menuBackgroundColor;
+ (UIColor *)cellBackgroundDarkColor;
+ (UIColor *)cellBackgroundLightColor;
+ (UIColor *)cellTextColor;
+ (UIColor *)cellSecondaryTextColor;
+ (UIColor *)detailHeaderSeparatorColor;
+ (UIColor *)tableBackgroundLightColor;
+ (UIColor *)tableBackgroundDarkColor;
+ (UIColor *)tableSeparatorColor;
+ (UIColor *)tableSectionColor;
+ (UIColor *)accentGreenColor;
+ (UIColor *)accentBlueColor;
+ (UIColor *)accentOrangeColor;
+ (UIColor *)partyRed;
+ (UIColor *)partyBlue;
+ (UIColor *)partyGreen;
+ (UIColor *)partyWhite;
@end

BOOL SLFColorGetRGBAComponents(UIColor *color, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha);
UIColor *SLFColorWithRGBShift(UIColor *color, int offset);
UIColor *SLFColorWithRGBA(int r, int g, int b, CGFloat a);
UIColor *SLFColorWithRGB(int red,  int green, int blue);
UIColor *SLFColorWithHex(char hex);
UIFont *SLFFont(CGFloat size);
UIFont *SLFPlainFont(CGFloat size);
UIFont *SLFTitleFont(CGFloat size);
UIFont *SLFItalicFont(CGFloat size);
extern NSString * const SLFAppearanceBoldFontName;
extern NSString * const SLFAppearancePlainFontName;
extern NSString * const SLFAppearanceItalicsFontName;
extern NSString * const SLFAppearanceTitleFontName;
