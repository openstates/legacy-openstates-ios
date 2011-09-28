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

+(void)setupTheme;

+ (UIColor *)menuTextColor;
+ (UIColor *)menuBackgroundColor;
+ (UIColor *)cellBackgroundDarkColor;
+ (UIColor *)cellBackgroundLightColor;
+ (UIColor *)cellTextColor;
+ (UIColor *)tableBackgroundColor;
+ (UIColor *)tableSeparatorColor;
+ (UIColor *)tableSectionColor;
+ (UIColor *)partyRed;
+ (UIColor *)partyBlue;
+ (UIColor *)partyGreen;

+ (UIFont *)boldTen;
+ (UIFont *)boldTwelve;
+ (UIFont *)boldFourteen;
+ (UIFont *)boldFifteen;
+ (UIFont *)boldEighteen;

@end

