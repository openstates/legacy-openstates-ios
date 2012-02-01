//
//  GradientBackgroundView.m
//  Created by Greg Combs on 9/29/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "GradientBackgroundView.h"
#import "SLFTheme.h"
#import <QuartzCore/QuartzCore.h>

@interface GradientBackgroundView()
@end

@implementation GradientBackgroundView

+(Class) layerClass {
    return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
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

@implementation GradientInnerShadowView
@synthesize gradient = _gradient;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;;
        _gradient = [[CAGradientLayer alloc] initWithLayer:self.layer];
        CGColorRef innerColor = SLFColorWithRGBA(84,86,77,.69).CGColor;
        CGColorRef darkColor = [UIColor colorWithWhite:0.0f alpha:.75].CGColor;
        _gradient.frame = frame;
        _gradient.colors = [NSArray arrayWithObjects:(id)darkColor, (id)innerColor, (id)innerColor, (id)darkColor, nil];
        _gradient.startPoint = CGPointMake(.5, -0.45);
        _gradient.endPoint = CGPointMake(.5, 1.45);
        [self.layer insertSublayer:_gradient atIndex:0];
    }
    return self;
}

- (void)dealloc {
    self.gradient = nil;
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _gradient.frame = self.frame;
}

@end