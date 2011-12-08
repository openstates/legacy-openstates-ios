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
    UIColor *dark = [SLFAppearance tableBackgroundDarkColor];
    UIColor *light = [SLFAppearance tableBackgroundLightColor];
    NSArray *colors = [NSArray arrayWithObjects:(id)dark.CGColor, (id)light.CGColor, nil];
    [(CAGradientLayer *)self.layer setColors:colors];
}

- (void)loadLayerAndGradientWithColors:(NSArray *)colors {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (IsEmpty(colors))
        return;
    NSMutableArray *cgColors = [[NSMutableArray alloc] initWithCapacity:colors.count];
    [colors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIColor class]])
            [cgColors addObject:(id)[obj CGColor]];
    }];
    [(CAGradientLayer *)self.layer setColors:cgColors];
    [cgColors release];
}
@end
