//
//  GradientBackgroundView.m
//  Created by Greg Combs on 9/29/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "GradientBackgroundView.h"
#import "SLFTheme.h"
#import <QuartzCore/QuartzCore.h>

@implementation GradientBackgroundView

+(Class) layerClass {
    return [CAGradientLayer class];
}

- (void)loadLayerAndGradientColors {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [(CAGradientLayer *)[self layer] setColors:[NSArray arrayWithObjects:(id)[SLFAppearance tableBackgroundDarkColor].CGColor,(id)[SLFAppearance tableBackgroundLightColor].CGColor, nil]];
}
@end
