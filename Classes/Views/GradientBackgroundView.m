//
//  GradientBackgroundView.m
//  Created by Greg Combs on 9/29/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "GradientBackgroundView.h"
#import "SLFTheme.h"

@interface GradientBackgroundView()
@end

@implementation GradientBackgroundView

+ (Class) layerClass {
    return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)loadLayerAndGradientColors {
    UIColor *dark = [SLFAppearance tableBackgroundDarkColor];
    UIColor *light = [SLFAppearance tableBackgroundLightColor];
    NSArray *colors = [NSArray arrayWithObjects:(id)dark.CGColor, (id)light.CGColor, nil];
    [(CAGradientLayer *)self.layer setColors:colors];
}

- (void)loadLayerAndGradientWithColors:(NSArray *)colors {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (!SLFTypeNonEmptyArrayOrNil(colors))
        return;
    NSMutableArray *cgColors = [[NSMutableArray alloc] initWithCapacity:colors.count];
    [colors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIColor class]])
            [cgColors addObject:(id)[obj CGColor]];
    }];
    [(CAGradientLayer *)self.layer setColors:cgColors];
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
        _gradient.colors = @[(__bridge id)darkColor, (__bridge id)innerColor, (__bridge id)innerColor, (__bridge id)darkColor];
        _gradient.startPoint = CGPointMake(.5, -0.45);
        _gradient.endPoint = CGPointMake(.5, 1.45);
        [self.layer insertSublayer:_gradient atIndex:0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _gradient.frame = self.frame;
}

@end
