//
//  TexLegeTheme.h
//  Created by Gregory Combs on 8/4/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <Foundation/Foundation.h>

@interface TexLegeTheme : NSObject

+ (UIFont *)boldTen;
+ (UIFont *)boldTwelve;
+ (UIFont *)boldFourteen;
+ (UIFont *)boldFifteen;
+ (UIFont *)boldEighteen;
+ (void) logFontNames;	
+ (UIFont *)disclosureFontSmall;
+ (UIFont *)disclosureFont;
+ (NSString *)disclosureChar;
+ (UILabel *)disclosureLabel:(BOOL)small;
	
+ (UIColor *)tableBackground;
+ (UIColor *)backgroundLight;
+ (UIColor *)backgroundDark;
+ (UIColor *)textDark;
+ (UIColor *)textLight;
+ (UIColor *)indexText;
+ (UIColor *)separator;
+ (UIColor *)accent;
+ (UIColor *)accentGreener;
+ (UIColor *)navbar;
+ (UIColor *)navbutton;
+ (UIColor *)segmentCtl;
+ (UIColor *)texasBlue;
+ (UIColor *)texasRed;
+ (UIColor *)texasGreen;
+ (UIColor *)texasOrange;

@end
