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
//  Color names by:
//  http://chir.ag/projects/name-that-color 

#import "SLFAppearance.h"
#import <RestKit/RestKit.h>

NSString * const SLFAppearanceFontName = @"HelveticaNeue-Bold";
NSString * const SLFAppearanceTitleFontName = @"BlairMdITC TT";

#define APP_OPEN_STATES_THEME 1
#define APP_OLD_SUNLIGHT_THEME 2
#define APP_BLUISH_THEME 3 
#define APP_APPEARANCE_THEME APP_OPEN_STATES_THEME

UIColor *SLFColorWithRGB(int r, int g, int b) {
    return [UIColor colorWithRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:1.0];
}
UIColor *SLFColorWithHex(char hex) {
    return SLFColorWithRGB(((hex&0xFF0000)>>16),((hex&0x00FF00)>>8),(hex&0x0000FF));
}

#define vendColor(r, g, b) static UIColor *ret; if (ret == nil) ret = [SLFColorWithRGB(r,g,b) retain]; return ret
#define vendColorHex(v) vendColor(((v&0xFF0000)>>16),((v&0x00FF00)>>8),(v&0x0000FF))

UIFont *SLFFont(CGFloat size) {
    return [UIFont fontWithName:SLFAppearanceFontName size:size];
}

UIFont *SLFTitleFont(CGFloat size) {
    return [UIFont fontWithName:SLFAppearanceTitleFontName size:size];
}

UIFont *SLFItalicFont(CGFloat size) {
    return [UIFont fontWithName:@"Georgia-Italic" size:size];
}

@implementation SLFAppearance

    // http://chir.ag/projects/name-that-color 


#if APP_APPEARANCE_THEME == APP_OPEN_STATES_THEME

+ (id)crail             {vendColor(186,87,67);}       //  vendColorHex(0xBA5743)
+ (id)tarawera          {vendColor(10,63,76);}        //  vendColorHex(0x0A3F4C)
+ (id)gimlet            {vendColor(166,183,101);}     //  vendColorHex(0xA6B765)

+ (UIColor *)partyRed {return [[self class] crail];}
+ (UIColor *)partyBlue {return [[self class] tarawera];}
+ (UIColor *)partyGreen {return [[self class] gimlet];}

+ (id)moonMist          {vendColor(227,227,215);}     //  vendColorHex(0xE3E3D7)  ...
+ (id)whiteRock         {vendColor(240,240,226);}     //  vendColorHex(0xF0F0E2)  ...
+ (id)westar            {vendColor(227,227,219);}     //  vendColorHex(0xE3E3DB)  ...
+ (id)acapulco          {vendColor(117,177,165);}     //  vendColorHex(0x75AFA5)  ...
+ (id)greenWhite        {vendColor(238,238,229);}     //  vendColorHex(0xEEEEE5)  ...
+ (id)springWood        {vendColor(245,245,237);}     //  vendColorHex(0xF5F5ED)  ...
+ (id)bitter            {vendColor(126,128,116);}     //  vendColorHex(0x7E8074)  ...
+ (id)zambezi           {vendColor(95,88,88);}        //  vendColorHex(0x5F5858)  ...
+ (id)bandicoot         {vendColor(116,117,107);}     //  vendColorHex(0x74756B)  ...
+ (id)kangaroo          {vendColor(197,199,190);}     //  vendColorHex(0xC5C7BE)  ...
+ (id)chicago           {vendColor(92,94,85);}        //  vendColorHex(0x5C5E55)

+ (UIFont *)accentGreenColor {return [[self class] gimlet];}
+ (UIFont *)accendBlueColor {return [[self class] acapulco];}

+ (UIFont *)navBarTextColor {return [[self class] springWood];}
+ (UIColor *)menuSelectedCellColor {return [[self class] chicago];}
+ (UIColor *)menuTextColor {return [[self class] kangaroo];}
+ (UIColor *)tableSectionColor {return [[self class] zambezi];}
+ (UIColor *)menuBackgroundColor {return [[self class] bitter];}
+ (UIColor *)cellBackgroundDarkColor {return [[self class] greenWhite];}
+ (UIColor *)cellBackgroundLightColor {return [[self class] springWood];}
+ (UIColor *)cellTextColor {return [[self class] zambezi];}
+ (UIColor *)cellSecondaryTextColor {return [[self class] bandicoot];}
+ (UIColor *)tableSeparatorColor {return [[self class] westar];}
+ (UIColor *)tableBackgroundDarkColor {return [[self class] moonMist];}
+ (UIColor *)tableBackgroundLightColor {return [[self class] whiteRock];}

+ (void)setupAppearance {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    [[[UIApplication sharedApplication] keyWindow] setBackgroundColor:[UIColor blackColor]];
    if (![UINavigationBar respondsToSelector:@selector(appearance)]) {
        RKLogError(@"Application themes use iOS 5 methods.  This device has iOS %@.", [[UIDevice currentDevice] systemVersion]);
        return;
    }
    [[UINavigationBar appearance] setTintColor:[[self class] bandicoot]];
    [[UISegmentedControl appearance] setTintColor:[[self class] bandicoot]];
    [[UISearchBar appearance] setTintColor:[[self class] bandicoot]];
    [[UIToolbar appearance] setTintColor:[[self class] acapulco]];
}

#else

+ (id)chambray          {vendColor(50,79,133);}       //  vendColorHex(0x324F85)
+ (id)monza             {vendColor(198,0,47);}        //  vendColorHex(0xC6002F)
+ (id)sycamore          {vendColor(126,145,67);}      //  vendColorHex(0x7E9143)
+ (id)burntOrange       {vendColor(201,72,2);}        //  vendColorHex(0xC94802)

+ (UIColor *)partyRed {return [[self class] monza];}
+ (UIColor *)partyBlue {return [[self class] chambray];}
+ (UIColor *)partyGreen {return [[self class] sycamore];}

#endif


#if APP_APPEARANCE_THEME == APP_OLD_SUNLIGHT_THEME

    + (id)eagle             {vendColor(179,182,161);}     //  vendColorHex(0xB3B6A1)
    + (id)loafer            {vendColor(242,245,226);}     //  vendColorHex(0xF2F5E2)
    + (id)spanishWhite      {vendColor(232,210,188);}     //  vendColorHex(0xE8D2BC)
    + (id)flamingPea        {vendColor(225,90,42);}       //  vendColorHex(0xE15A2A)
    + (id)gimblet           {vendColor(165,183,100);}     //  vendColorHex(0xA5B764)
    + (id)acapulco          {vendColor(116,174,165);}     //  vendColorHex(0x74AEA5)
    + (id)moonMist          {vendColor(218,220,201);}     //  vendColorHex(0xDADCC9)
    + (id)whiteRock         {vendColor(233,234,214);}     //  vendColorHex(0xE9EAD6)
    + (id)graniteGreen      {vendColor(145,144,130);}     //  vendColorHex(0x919082)
    + (id)kangaroo          {vendColor(204,206,191);}     //  vendColorHex(0xCCCEBF)
    + (id)masala            {vendColor(70,69,68);}        //  vendColorHex(0x464544)
    + (id)flint             {vendColor(111,106,102);}     //  vendColorHex(0x6F6A66)

    + (id)tuscany           {vendColor(191,82,41);}       //  vendColorHex(0xBF5229)
    + (id)ochre             {vendColor(211,110,40);}      //  vendColorHex(0xD36E28)

    + (UIColor *)menuSelectedTextColor {return [[self class] acapulco];}
    + (UIColor *)menuTextColor {return [[self class] flamingPea];}
    + (UIColor *)tableSectionColor {return [[self class] flamingPea];}
    + (UIColor *)menuBackgroundColor {return [[self class] kangaroo];}
    + (UIColor *)cellBackgroundDarkColor {return [[self class] moonMist];}
    + (UIColor *)cellBackgroundLightColor {return [[self class] whiteRock];}
    + (UIColor *)cellTextColor {return [[self class] masala];}
    + (UIColor *)cellSecondaryTextColor {return [[self class] flint];}
    + (UIColor *)tableSeparatorColor {return [[self class] spanishWhite];}
    + (UIColor *)tableBackgroundDarkColor {return [[self class] eagle];}
    + (UIColor *)tableBackgroundLightColor {return [[self class] loafer];}

    + (void)setupAppearance {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
        [[[UIApplication sharedApplication] keyWindow] setBackgroundColor:[UIColor blackColor]];
        if (![UINavigationBar respondsToSelector:@selector(appearance)]) {
            RKLogError(@"Application themes use iOS 5 methods.  This device has iOS %@.", [[UIDevice currentDevice] systemVersion]);
            return;
        }
        [[UINavigationBar appearance] setTintColor:[[self class] graniteGreen]];
        [[UISegmentedControl appearance] setTintColor:[[self class] graniteGreen]];
        [[UISearchBar appearance] setTintColor:[[self class] graniteGreen]];
        [[UIToolbar appearance] setTintColor:[[self class] acapulco]];
    }
#endif


#if APP_APPEARANCE_THEME == APP_BLUISH_THEME
    // Bluish Theme mimics Jonno Riekwei's interface at http://365psd.com/day/70/
    + (id)plum              {vendColor(113,40,105);}      //  vendColorHex(0x712869)
    + (id)riverBed          {vendColor(77,90,98);}        //  vendColorHex(0x4D5A62)
    + (id)loblolly          {vendColor(196,203,209);}     //  vendColorHex(0xC4CBD1)
    + (id)loblollyLight     {vendColor(217,217,217);}     //  vendColorHex(0xD9D9D9)
    + (id)celery            {vendColor(153,190,90);}      //  vendColorHex(0x99BE5A)
    + (id)towerGray         {vendColor(173,183,191);}     //  vendColorHex(0xADB7BF)
    + (id)fiord             {vendColor(67,86,98);}        //  vendColorHex(0x435662)
    + (id)battleshipGray    {vendColor(141,151,125);}     //  vendColorHex(0x8D977D)
    + (id)iron              {vendColor(218,223,226);}     //  vendColorHex(0xDADFE2)
    + (id)blackHaze         {vendColor(250,251,251);}     //  vendColorHex(0xFAFBFB)
    + (id)outerSpace        {vendColor(50,60,67);}        //  vendColorHex(0x323C43)
    + (id)nevada            {vendColor(95,108,117);}      //  vendColorHex(0x5F6C75)

    + (UIColor *)menuSelectedTextColor {return [UIColor whiteColor];}
    + (UIColor *)menuTextColor {return [[self class] loblollyLight];}
    + (UIColor *)menuBackgroundColor {return [[self class] plum];}
    + (UIColor *)cellBackgroundDarkColor {return [[self class] iron];}
    + (UIColor *)cellBackgroundLightColor {return [[self class] blackHaze];}
    + (UIColor *)cellTextColor {return [[self class] fiord];}
    + (UIColor *)cellSecondaryTextColor {return [[self class] battleshipGray];}
    + (UIColor *)tableSeparatorColor {return [[self class] loblollyLight];}
    + (UIColor *)tableSectionColor {return [[self class] towerGray];}
    + (UIColor *)tableBackgroundDarkColor {return [[self class] outerSpace];}
    + (UIColor *)tableBackgroundLightColor {return [[self class] nevada];}

    + (void)setupAppearance {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
        [[[UIApplication sharedApplication] keyWindow] setBackgroundColor:[UIColor blackColor]];
        if (![UINavigationBar respondsToSelector:@selector(appearance)]) {
            RKLogError(@"Application themes use iOS 5 methods.  This device has iOS %@.", [[UIDevice currentDevice] systemVersion]);
            return;
        }
        [[UINavigationBar appearance] setTintColor:[[self class] riverBed]];
        [[UIToolbar appearance] setTintColor:[[self class] riverBed]];
        [[UISearchBar appearance] setTintColor:[[self class] celery]];
        [[UISegmentedControl appearance] setTintColor:[[self class] celery]];
    }

#endif

@end
