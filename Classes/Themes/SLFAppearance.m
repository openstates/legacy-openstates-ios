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

+ (void)setupTheme {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    if (![UINavigationBar respondsToSelector:@selector(appearance)]) {
        RKLogError(@"Application themes use iOS 5 methods.  This device has iOS %@.", [[UIDevice currentDevice] systemVersion]);
        return;
    }
    [[UINavigationBar appearance] setTintColor:[[self class] riverBed]];
    [[UIToolbar appearance] setTintColor:[[self class] riverBed]];
    [[UISearchBar appearance] setTintColor:[[self class] christi]];
    [[UISegmentedControl appearance] setTintColor:[[self class] celery]];
    
        // These don't work that well...
    [[UITableView appearance] setBackgroundColor:[[self class] loblolly]];    
    [[UITableView appearance] setSeparatorColor:[[self class] loblollyLight]];
    [[UITableViewCell appearance] setBackgroundColor:[[self class] iron]];
    [[UITableViewCell appearance] setFont:[[self class] boldFifteen]];
    [[UITableViewCell appearance] setTextColor:[[self class] fiord]];
}
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
+ (UIColor *)chambray {return [UIColor colorWithRed:0.196f green:0.310f blue:0.522f alpha:1.0];}        // "Texas Blue"
+ (UIColor *)monza {return [UIColor colorWithRed:0.776f green:0.0f blue:0.184f alpha:1.0];}             // "Texas Red"
+ (UIColor *)sycamore {return [UIColor colorWithRed:0.494f green:0.569f blue:0.263f alpha:1.0];}        // "Texas Green"
+ (UIColor *)burntOrange {return [UIColor colorWithRed:0.8f green:0.333f blue:0.0f alpha:1.0];}         // "Texas Orange"
+ (UIColor *)partyRed {return [[self class] monza];}
+ (UIColor *)partyBlue {return [[self class] chambray];}
+ (UIColor *)partyGreen {return [[self class] sycamore];}

#define FONTNAME @"HelveticaNeue-Bold"
+ (UIFont *)boldTen {return [UIFont fontWithName:FONTNAME size:10.f];}
+ (UIFont *)boldTwelve {return [UIFont fontWithName:FONTNAME size:12.f];}
+ (UIFont *)boldFourteen {return [UIFont fontWithName:FONTNAME size:14.f];}
+ (UIFont *)boldFifteen {return [UIFont fontWithName:FONTNAME size:15.f];}
+ (UIFont *)boldEighteen {return [UIFont fontWithName:FONTNAME size:18.f];}

@end
