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
#import <RestKit/RestKit.h>

#define APP_OPEN_STATES_THEME 1
#define APP_BLUISH_THEME 2 
#define APP_APPEARANCE_THEME APP_OPEN_STATES_THEME

#define vendColor(r, g, b) static UIColor *ret; if (ret == nil) ret = [[UIColor colorWithRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:1.0] retain]; return ret

#define vendColorHex(v) vendColor(((v&0xFF0000)>>16),((v&0x00FF00)>>8),(v&0x0000FF))

@implementation SLFAppearance

#if ( APP_APPEARANCE_THEME == APP_OPEN_STATES_THEME ) || ( APP_APPEARANCE_THEME == APP_BLUISH_THEME )

    // http://chir.ag/projects/name-that-color 
    + (id)chambray          {vendColor(50,79,133);}       //  vendColorHex(0x324F85)
    + (id)monza             {vendColor(198,0,47);}        //  vendColorHex(0xC6002F)
    + (id)sycamore          {vendColor(126,145,67);}      //  vendColorHex(0x7E9143)
    + (id)burntOrange       {vendColor(201,72,2);}        //  vendColorHex(0xC94802)

    + (UIColor *)partyRed {return [[self class] monza];}
    + (UIColor *)partyBlue {return [[self class] chambray];}
    + (UIColor *)partyGreen {return [[self class] sycamore];}

    static NSString *SLFAppearanceFontName = @"HelveticaNeue-Bold";
    + (UIFont *)boldTen {return [UIFont fontWithName:SLFAppearanceFontName size:10.f];}
    + (UIFont *)boldTwelve {return [UIFont fontWithName:SLFAppearanceFontName size:12.f];}
    + (UIFont *)boldFourteen {return [UIFont fontWithName:SLFAppearanceFontName size:14.f];}
    + (UIFont *)boldFifteen {return [UIFont fontWithName:SLFAppearanceFontName size:15.f];}
    + (UIFont *)boldEighteen {return [UIFont fontWithName:SLFAppearanceFontName size:18.f];}

    static NSString *menuFontName = @"BlairMdITC TT";
    //+ (UIFont *)menuTextFont {return [UIFont fontWithName:menuFontName size:12.f];}
    + (UIFont *)menuTextFont {return [[self class] boldFifteen];}

    #endif

#if APP_APPEARANCE_THEME == APP_OPEN_STATES_THEME

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
            //[[UITableViewCell appearance] setFont:[[self class] boldFifteen]];
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
        [[UITableViewCell appearance] setFont:[[self class] boldFifteen]];
    }

#endif

@end
