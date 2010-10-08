//
//  TexLegeTheme.h
//  TexLege
//
//  Created by Gregory Combs on 8/4/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TexLegeTheme : NSObject

+ (UIFont *)boldTen;
+ (UIFont *)boldTwelve;
+ (UIFont *)boldFourteen;
+ (UIFont *)boldFifteen;
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
