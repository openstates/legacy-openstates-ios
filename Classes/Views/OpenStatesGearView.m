//
//  OpenStatesGearView.m
//  Created by Greg Combs on 12/12/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "OpenStatesGearView.h"
#import "EPSBezierPath.h"
#import "SLFAppearance.h"
#import "SLFDrawingExtensions.h"

const CGFloat kOpenStatesGearViewWidth = 56.f;
const CGFloat kOpenStatesGearViewHeight = 56.f;
#define EPSPointShift(x,y) CGPointMake(x,y+kOpenStatesGearViewWidth)


@interface OpenStatesGearView() {
    CGGradientRef _gradient;
}
@property (nonatomic,retain) EPSBezierPath *penumbraPath;
@property (nonatomic,retain) EPSBezierPath *shinePath;
@property (nonatomic,retain) EPSBezierPath *surfacePath;
- (void)configure;
- (EPSBezierPath *)penumbraFactory;
- (EPSBezierPath *)shineFactory;
- (EPSBezierPath *)surfaceFactory;
- (void)createGradient;
- (void)destroyGradient;
@end

@implementation OpenStatesGearView
@synthesize penumbraPath=_penumbraPath;
@synthesize shinePath=_shinePath;
@synthesize surfacePath=_surfacePath;
@synthesize useGradientOverlay;
@synthesize useDropShadow = _useDropShadow;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)dealloc {
    self.penumbraPath = nil;
    self.shinePath = nil;
    self.surfacePath = nil;
    [self destroyGradient];
    [super dealloc];
}

- (void)configure {
    self.contentMode = UIViewContentModeRedraw;
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    self.opaque = NO;
    self.layer.shouldRasterize = YES;
    self.layer.shadowColor = [[UIColor colorWithRed:0.278 green:0.275 blue:0.267 alpha:.6] CGColor];
    self.layer.shadowOffset = CGSizeMake(0, -1);
    self.layer.shadowRadius = 3.0f;
    self.useDropShadow = YES;
    self.penumbraPath = [self penumbraFactory];    
    self.shinePath = [self shineFactory];
    self.surfacePath = [self surfaceFactory];
    [self createGradient];
    self.useGradientOverlay = NO;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(kOpenStatesGearViewWidth, kOpenStatesGearViewHeight);
}

- (void)drawRect:(CGRect)viewBounds
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, kOpenStatesGearViewWidth, kOpenStatesGearViewHeight);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat widthRatio = CGRectGetWidth(viewBounds) / CGRectGetWidth(imageBounds);
    CGFloat heightRatio = CGRectGetHeight(viewBounds) / CGRectGetHeight(imageBounds);
//  CGFloat scale = 0.5f * ( widthRatio + heightRatio );
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(viewBounds),CGRectGetMinY(viewBounds));
    CGContextScaleCTM(context, widthRatio, heightRatio);
    
#if 0
    [[UIColor colorWithWhite:0 alpha:.2] setFill];
    [_penumbraPath fillWithBlendMode:kCGBlendModeExclusion alpha:1];
    [_shinePath fillWithBlendMode:kCGBlendModeMultiply alpha:1];
    [_surfacePath fillWithBlendMode:kCGBlendModeDifference alpha:1];
#else
    CGContextSetBlendMode(context, kCGBlendModeDarken);
    [_penumbraPath fillAndStrokeIfNeeded];
    [_shinePath fillAndStrokeIfNeeded];
    [_surfacePath fillAndStrokeIfNeeded];
#endif
    
    if (useGradientOverlay) {
        CGPoint startPoint;
        CGPoint endPoint;
#if 0 
            // use this if you ever need to calculate the points again, otherwise it's expensive cpu time
        [SLFDrawing getStartPoint:&startPoint endPoint:&endPoint withAngle:105.f inRect:_penumbraPath.bounds];
#else
        startPoint = CGPointMake(-5, 37);
        endPoint = CGPointMake(19, 60);
#endif
            //CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextAddPath(context, _penumbraPath.CGPath);
        CGContextClip(context);
        CGContextSetBlendMode(context, kCGBlendModeDifference);
        CGContextDrawLinearGradient(context, _gradient, startPoint, endPoint, 0);
        CGContextRestoreGState(context);
    }

    CGContextRestoreGState(context);
}

- (EPSBezierPath *)penumbraFactory {
    EPSBezierPath *path = [EPSBezierPath pathWithFillColor:[SLFAppearance tableBackgroundLightColor] strokeColor:nil];
    [path moveToPoint:EPSPointShift(27.9658, -1.37744)];
    [path startCurveWithControlPoint2:EPSPointShift(32.709, -5.03369) end:EPSPointShift(36.0703, -5.82471)];
    [path continueCurveWithControlPoint1:EPSPointShift(39.4316, -6.61572) point2:EPSPointShift(44.1748, -5.72607) end:EPSPointShift(44.7676, -6.02197)];
    [path continueCurveWithControlPoint1:EPSPointShift(45.3613, -6.31885) point2:EPSPointShift(45.0645, -12.644) end:EPSPointShift(47.041, -15.0171)];
    [path continueCurveWithControlPoint1:EPSPointShift(49.0176, -17.3882) point2:EPSPointShift(55.4004, -20.2778) end:EPSPointShift(55.5703, -21.1069)];
    [path continueCurveWithControlPoint1:EPSPointShift(55.7393, -21.9351) point2:EPSPointShift(49.6113, -24.7026) end:EPSPointShift(50.2041, -28.6558)];
    [path continueCurveWithControlPoint1:EPSPointShift(50.7969, -32.6099) point2:EPSPointShift(54.8496, -36.4644) end:EPSPointShift(54.4541, -37.354)];
    [path continueCurveWithControlPoint1:EPSPointShift(54.0586, -38.2437) point2:EPSPointShift(47.9316, -37.6499) end:EPSPointShift(45.6582, -41.2085)];
    [path continueCurveWithControlPoint1:EPSPointShift(43.3848, -44.7671) point2:EPSPointShift(44.8301, -49.0894) end:EPSPointShift(43.8789, -49.7085)];
    [path continueCurveWithControlPoint1:EPSPointShift(42.9277, -50.3276) point2:EPSPointShift(38.5059, -48.4956) end:EPSPointShift(33.4023, -49.4116)];
    [path continueCurveWithControlPoint1:EPSPointShift(28.2969, -50.3276) point2:EPSPointShift(22.8262, -55.4409) end:EPSPointShift(21.7393, -55.2437)];
    [path continueCurveWithControlPoint1:EPSPointShift(20.6523, -55.0464) point2:EPSPointShift(19.5645, -48.2261) end:EPSPointShift(16.3027, -46.1499)];
    [path continueCurveWithControlPoint1:EPSPointShift(13.041, -44.0747) point2:EPSPointShift(4.24414, -43.3833) end:EPSPointShift(3.94824, -42.7905)];
    [path continueCurveWithControlPoint1:EPSPointShift(3.65234, -42.1968) point2:EPSPointShift(7.90625, -37.0503) end:EPSPointShift(6.57031, -32.6069)];
    [path continueCurveWithControlPoint1:EPSPointShift(5.23242, -28.1616) point2:EPSPointShift(0.447266, -25.6851) end:EPSPointShift(0.320313, -24.1069)];
    [path continueCurveWithControlPoint1:EPSPointShift(0.192383, -22.5288) point2:EPSPointShift(6.32031, -22.6274) end:EPSPointShift(8.29688, -17.0923)];
    [path continueCurveWithControlPoint1:EPSPointShift(10.2734, -11.5571) point2:EPSPointShift(9.7793, -5.25439) end:EPSPointShift(10.5703, -4.10596)];
    [path continueCurveWithControlPoint1:EPSPointShift(11.3613, -2.9585) point2:EPSPointShift(15.4141, -6.61572) end:EPSPointShift(19.4658, -5.52783)];
    [path endCurveWithControlPoint1:EPSPointShift(23.5176, -4.44092) end:EPSPointShift(26.2852, -1.77197)];
    [path startCurveWithControlPoint2:EPSPointShift(23.3203, -6.02197) end:EPSPointShift(18.9717, -6.81299)];
    [path endCurveWithControlPoint1:EPSPointShift(15.2441, -7.49072) end:EPSPointShift(11.5586, -5.33057)];
    [path startCurveWithControlPoint2:EPSPointShift(11.46, -13.0396) end:EPSPointShift(9.58203, -17.8823)];
    [path endCurveWithControlPoint1:EPSPointShift(7.7041, -22.7261) end:EPSPointShift(1.87305, -24.2085)];
    [path startCurveWithControlPoint2:EPSPointShift(8.00098, -28.4585) end:EPSPointShift(8.09961, -33.2026)];
    [path endCurveWithControlPoint1:EPSPointShift(8.19824, -37.9468) end:EPSPointShift(6.32031, -41.7026)];
    [path startCurveWithControlPoint2:EPSPointShift(13.1406, -41.8999) end:EPSPointShift(16.8965, -44.6675)];
    [path endCurveWithControlPoint1:EPSPointShift(20.6523, -47.4351) end:EPSPointShift(22.332, -52.3774)];
    [path startCurveWithControlPoint2:EPSPointShift(25.5938, -49.1157) end:EPSPointShift(32.1172, -47.8306)];
    [path endCurveWithControlPoint1:EPSPointShift(38.5137, -46.5698) end:EPSPointShift(41.9023, -47.4351)];
    [path startCurveWithControlPoint2:EPSPointShift(40.7158, -42.394) end:EPSPointShift(43.7793, -38.8364)];
    [path endCurveWithControlPoint1:EPSPointShift(46.8438, -35.2788) end:EPSPointShift(50.7969, -35.4761)];
    [path startCurveWithControlPoint2:EPSPointShift(46.7441, -31.2261) end:EPSPointShift(48.3262, -26.6792)];
    [path endCurveWithControlPoint1:EPSPointShift(49.9082, -22.1323) end:EPSPointShift(52.2793, -21.144)];
    [path startCurveWithControlPoint2:EPSPointShift(47.4365, -18.9702) end:EPSPointShift(45.46, -14.9175)];
    [path endCurveWithControlPoint1:EPSPointShift(43.4834, -10.8647) end:EPSPointShift(43.7793, -7.40674)];
    [path startCurveWithControlPoint2:EPSPointShift(39.4307, -8.09814) end:EPSPointShift(35.7734, -6.81299)];
    [path endCurveWithControlPoint1:EPSPointShift(32.1172, -5.52783) end:EPSPointShift(27.9658, -1.37744)];
    [path closePath];
    return path;
}

- (EPSBezierPath *)shineFactory {
    EPSBezierPath *path = [EPSBezierPath pathWithFillColor:[SLFAppearance tableBackgroundLightColor] strokeColor:nil];
    [path moveToPoint:EPSPointShift(45.541, -24.1284)];
    [path startCurveWithControlPoint2:EPSPointShift(45.918, -19.2749) end:EPSPointShift(42.1855, -14.7964)];
    [path continueCurveWithControlPoint1:EPSPointShift(39.1846, -11.1978) point2:EPSPointShift(32.9336, -7.65283) end:EPSPointShift(26.2217, -8.49268)];
    [path continueCurveWithControlPoint1:EPSPointShift(8.15332, -10.7515) point2:EPSPointShift(6.15234, -30.6499) end:EPSPointShift(12.7969, -38.4546)];
    [path continueCurveWithControlPoint1:EPSPointShift(17.9531, -44.5122) point2:EPSPointShift(25.7725, -47.8843) end:EPSPointShift(36.0332, -43.6753)];
    [path endCurveWithControlPoint1:EPSPointShift(46.0742, -39.5562) end:EPSPointShift(45.541, -26.6655)];
    [path startCurveWithControlPoint2:EPSPointShift(44.8027, -37.8882) end:EPSPointShift(36.4551, -42.0562)];
    [path continueCurveWithControlPoint1:EPSPointShift(28.4395, -46.0591) point2:EPSPointShift(14.0234, -44.8394) end:EPSPointShift(10.832, -30.4312)];
    [path continueCurveWithControlPoint1:EPSPointShift(9.87402, -26.1108) point2:EPSPointShift(11.5928, -19.4253) end:EPSPointShift(15.0879, -15.8608)];
    [path continueCurveWithControlPoint1:EPSPointShift(20.0322, -10.8179) point2:EPSPointShift(26.7949, -8.08252) end:EPSPointShift(33.6709, -10.3755)];
    [path endCurveWithControlPoint1:EPSPointShift(44.7246, -14.0601) end:EPSPointShift(45.541, -24.1284)];
    [path closePath];
    return path;
}

- (EPSBezierPath *)surfaceFactory {
    EPSBezierPath *path = [EPSBezierPath pathWithFillColor:[SLFAppearance tableBackgroundLightColor] strokeColor:nil];
    [path moveToPoint:EPSPointShift(45.2578, -28.2935)];
    [path continueCurveWithControlPoint1:EPSPointShift(45.2578, -37.4253) point2:EPSPointShift(38.1719, -44.8276) end:EPSPointShift(29.4336, -44.8276)];
    [path continueCurveWithControlPoint1:EPSPointShift(20.6943, -44.8276) point2:EPSPointShift(13.6094, -37.4253) end:EPSPointShift(13.6094, -28.2935)];
    [path continueCurveWithControlPoint1:EPSPointShift(13.6094, -19.1616) point2:EPSPointShift(20.6943, -11.7593) end:EPSPointShift(29.4336, -11.7593)];
    [path continueCurveWithControlPoint1:EPSPointShift(38.1719, -11.7593) point2:EPSPointShift(45.2578, -19.1616) end:EPSPointShift(45.2578, -28.2935)];
    [path closePath];
    return path;
}

- (void)createGradient {    
    CGFloat colors [] = { 
        0.0, 0.0, 0.0, 0.0, 
        0.278, 0.275, 0.267, 1.0
    };
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    _gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, 2);
    CGColorSpaceRelease(rgb);
}

- (void)destroyGradient {
    if (_gradient == NULL)
        return;
    CGGradientRelease(_gradient);
    _gradient = NULL;
}

- (void)setUseGradientOverlay:(BOOL)newValue {
    useGradientOverlay = newValue;
    [self setNeedsDisplay];
}

- (void)setUseDropShadow:(BOOL)useDropShadow {
    _useDropShadow = useDropShadow;
    if (_useDropShadow)
        self.layer.shadowOpacity = .2;
    else
        self.layer.shadowOpacity = 0;
    [self.layer setNeedsDisplay];
}

@end
