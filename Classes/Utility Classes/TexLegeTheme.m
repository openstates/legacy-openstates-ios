//
//  TexLegeTheme.m
//  TexLege
//
//  Created by Gregory Combs on 8/4/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TexLegeTheme.h"

@implementation TexLegeTheme

+ (UIFont *)disclosureFont {
	//return [UIFont fontWithName:@"HiraKakuProN-W6" size:36.f];
	return [UIFont fontWithName:@"HiraKakuProN-W6" size:24.f];
}

+ (UIFont *)disclosureFontSmall {
	//return [UIFont fontWithName:@"HiraKakuProN-W6" size:36.f];
	return [UIFont fontWithName:@"HiraKakuProN-W6" size:18.f];
}


+ (NSString *)disclosureChar {
	//return @"\xe2\x80\xba";
	return @">";
}

+ (UILabel *)disclosureLabel:(BOOL)small {
	UILabel *lab = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 22.f, 32.f)] autorelease];
	lab.text = [TexLegeTheme disclosureChar];
	if (small)
		lab.font = [TexLegeTheme disclosureFontSmall];
	else
		lab.font = [TexLegeTheme disclosureFont];
	lab.textColor = [TexLegeTheme accent];
	lab.shadowColor = [UIColor darkGrayColor];
	lab.highlightedTextColor = [TexLegeTheme backgroundLight];
	lab.backgroundColor = [UIColor clearColor];
	lab.clearsContextBeforeDrawing = YES;

	return lab;
}

+ (UIFont *)boldTen {return [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.f];}
+ (UIFont *)boldTwelve {return [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.f];}
+ (UIFont *)boldFifteen {return [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.f];}

+ (void) logFontNames {	
	for (NSString *family in [UIFont familyNames]) {
		for (NSString *font in [UIFont fontNamesForFamilyName:family]) 
			debug_NSLog(@"Font: %@", font);
	}
}
+ (UIColor *)segmentCtl {return [UIColor colorWithRed:0.592157f green:0.631373f blue:0.65098f alpha:1.0];}
+ (UIColor *)tableBackground {return [UIColor colorWithRed:0.769f green:0.796f blue:0.82f alpha:1.0];}
+ (UIColor *)backgroundDark {return [UIColor colorWithRed:0.855f green:0.875f blue:0.886f alpha:1.0];}
+ (UIColor *)backgroundLight {return [UIColor colorWithRed:0.980f green:0.984f blue:0.984f alpha:1.0];}
+ (UIColor *)textDark {return [UIColor colorWithRed:0.263f green:0.337f blue:0.384f alpha:1.0];}		// 435662
//+ (UIColor *)textLight {return [UIColor colorWithRed:0.604f green:0.631f blue:0.651f alpha:1.0];}
+ (UIColor *)textLight {return [UIColor colorWithRed:0.553f green:0.592f blue:0.49f alpha:1.0];}		// 8D977D
+ (UIColor *)separator {return [UIColor colorWithRed:0.741f green:0.769f blue:0.792f alpha:1.0];}
+ (UIColor *)accent {return [UIColor colorWithRed:0.6f green:0.745f blue:0.353f alpha:1.0];}			// 99BE5A
+ (UIColor *)accentGreener {return [UIColor colorWithRed:0.431f green:0.643f blue:0.063f alpha:1.0];}
+ (UIColor *)navbutton {return [UIColor colorWithRed:0.137f green:0.173f blue:0.192f alpha:1.0];}
+ (UIColor *)navbar {return [UIColor colorWithRed:0.301f green:0.353f blue:0.384f alpha:1.0];}
+ (UIColor *)indexText {return [UIColor colorWithRed:0.416f green:0.451f blue:0.49f alpha:1.0];}
//+ (UIColor *)texasBlue {return [UIColor colorWithRed:0.353f green:0.553f blue:0.871f alpha:1.0];}
+ (UIColor *)texasBlue {return [UIColor colorWithRed:0.196f green:0.310f blue:0.522f alpha:1.0];}		// 324F85
+ (UIColor *)texasRed {return [UIColor colorWithRed:0.776f green:0.0f blue:0.184f alpha:1.0];}			// C6002F
+ (UIColor *)texasGreen {return [UIColor colorWithRed:0.494f green:0.569f blue:0.263f alpha:1.0];}		// 7E9143
+ (UIColor *)texasOrange {return [UIColor colorWithRed:0.8f green:0.333f blue:0.0f alpha:1.0];}		// 7E9143


@end


