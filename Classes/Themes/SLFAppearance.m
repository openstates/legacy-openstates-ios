//
//  SLFAppearance.m
//  Created by Greg Combs on 9/22/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFAppearance.h"

@implementation SLFAppearance

// http://chir.ag/projects/name-that-color                                                              Formerly known as...
+ (UIColor *)riverBed {return [UIColor colorWithRed:0.301f green:0.353f blue:0.384f alpha:1.0];}        // "Navbar"
+ (UIColor *)loblolly {return [UIColor colorWithRed:0.769f green:0.796f blue:0.82f alpha:1.0];}         // "TableView Background"
+ (UIColor *)loblollyLight {return [UIColor colorWithRed:0.852f green:0.852 blue:0.852f alpha:1.0];}    // "Table separator"
+ (UIColor *)celery {return [UIColor colorWithRed:0.6f green:0.745f blue:0.353f alpha:1.0];}            // "Accent"
+ (UIColor *)christi {return [UIColor colorWithRed:0.431f green:0.643f blue:0.063f alpha:1.0];}         // "Accent Greener"
+ (UIColor *)doveGray {return [UIColor colorWithRed:0.416f green:0.451f blue:0.49f alpha:1.0];}         // "Index Text Font"
+ (UIColor *)fiord {return [UIColor colorWithRed:0.263f green:0.337f blue:0.384f alpha:1.0];}           // "Text Dark"
+ (UIColor *)battleshipGray {return [UIColor colorWithRed:0.553f green:0.592f blue:0.49f alpha:1.0];}   // "Text Light"
+ (UIColor *)iron {return [UIColor colorWithRed:0.855f green:0.875f blue:0.886f alpha:1.0];}            // "Table Cell Dark"
+ (UIColor *)blackHaze {return [UIColor colorWithRed:0.980f green:0.984f blue:0.984f alpha:1.0];}       // "Table Cell Light"

+ (UIColor *)chambray {return [UIColor colorWithRed:0.196f green:0.310f blue:0.522f alpha:1.0];}
+ (UIColor *)monza {return [UIColor colorWithRed:0.776f green:0.0f blue:0.184f alpha:1.0];}
+ (UIColor *)sycamore {return [UIColor colorWithRed:0.494f green:0.569f blue:0.263f alpha:1.0];}

+ (UIColor *)burntOrange {return [UIColor colorWithRed:0.788 green:0.282 blue:0.008 alpha:1.000];}
+ (UIColor *)loafer {return [UIColor colorWithRed:0.949 green:0.961 blue:0.886 alpha:1.000];}
+ (UIColor *)spanishWhite {return [UIColor colorWithRed:0.910 green:0.824 blue:0.737 alpha:1.000];}
+ (UIColor *)flamingPea {return [UIColor colorWithRed:0.882 green:0.353 blue:0.165 alpha:1.000];}
+ (UIColor *)gimblet {return [UIColor colorWithRed:0.647 green:0.706 blue:0.388 alpha:1.000];}
+ (UIColor *)acapulco {return [UIColor colorWithRed:0.455 green:0.682 blue:0.647 alpha:1.000];}
+ (UIColor *)moonMist {return [UIColor colorWithRed:0.855 green:0.863 blue:0.788 alpha:1.000];}         // "Table Cell Dark"
+ (UIColor *)whiteRock {return [UIColor colorWithRed:0.914 green:0.918 blue:0.839 alpha:1.000];}        // "Table Cell Light"
+ (UIColor *)armadillo {return [UIColor colorWithRed:0.310 green:0.282 blue:0.263 alpha:1.000];}        // "Text Dark"
+ (UIColor *)graniteGreen {return [UIColor colorWithRed:0.569 green:0.565 blue:0.510 alpha:1.000];}
+ (UIColor *)kangaroo {return [UIColor colorWithRed:0.800 green:0.808 blue:0.749 alpha:1.000];}

+ (UIColor *)menuTextColor {return [[self class] burntOrange];}
+ (UIColor *)tableTextColor {return [[self class] armadillo];}
+ (UIColor *)menuBackgroundColor {return [[self class] kangaroo];}
+ (UIColor *)cellBackgroundDarkColor {return [[self class] moonMist];}
+ (UIColor *)cellBackgroundLightColor {return [[self class] whiteRock];}
+ (UIColor *)cellTextColor {return [[self class] armadillo];}
+ (UIColor *)tableSeparatorColor {return [[self class] spanishWhite];}
+ (UIColor *)tableSectionColor {return [[self class] acapulco];}
+ (UIColor *)tableBackgroundColor {return [[self class] loafer];}
+ (UIColor *)partyRed {return [[self class] monza];}
+ (UIColor *)partyBlue {return [[self class] chambray];}
+ (UIColor *)partyGreen {return [[self class] sycamore];}


#define FONTNAME @"HelveticaNeue-Bold"
+ (UIFont *)boldTen {return [UIFont fontWithName:FONTNAME size:10.f];}
+ (UIFont *)boldTwelve {return [UIFont fontWithName:FONTNAME size:12.f];}
+ (UIFont *)boldFourteen {return [UIFont fontWithName:FONTNAME size:14.f];}
+ (UIFont *)boldFifteen {return [UIFont fontWithName:FONTNAME size:15.f];}
+ (UIFont *)boldEighteen {return [UIFont fontWithName:FONTNAME size:18.f];}

+ (void)setupTheme {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    [[[UIApplication sharedApplication] keyWindow] setBackgroundColor:[UIColor blackColor]];
    if (![UINavigationBar respondsToSelector:@selector(appearance)]) {
        RKLogError(@"Application themes use iOS 5 methods.  This device has iOS %@.", [[UIDevice currentDevice] systemVersion]);
        return;
    }
    [[UINavigationBar appearance] setTintColor:[[self class] flamingPea]];
    [[UIToolbar appearance] setTintColor:[[self class] flamingPea]];
    [[UISearchBar appearance] setTintColor:[[self class] acapulco]];
    [[UISegmentedControl appearance] setTintColor:[[self class] gimblet]];
    
    [[UITableViewCell appearance] setFont:[[self class] boldFifteen]];
}

@end
