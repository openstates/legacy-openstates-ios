//
//  OpenStatesIconView.m
//  Created by Greg Combs on 11/13/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "OpenStatesIconView.h"
#import "EPSBezierPath.h"
#import "SLFAppearance.h"

const CGFloat kOpenStatesIconViewWidth = 512.f;
const CGFloat kOpenStatesIconViewHeight = 512.f;


@interface OpenStatesIconView() {
    CGGradientRef _gradient;
}
@property (nonatomic,retain) EPSBezierPath *outerPath;
@property (nonatomic,retain) EPSBezierPath *lowerPath;
@property (nonatomic,retain) EPSBezierPath *lowerShinePath;
@property (nonatomic,retain) EPSBezierPath *upperShinePath;
@property (nonatomic,retain) EPSBezierPath *upperPath;
@property (nonatomic,retain) EPSBezierPath *chartPath;
- (void)configure;
- (EPSBezierPath *)outerFactory;
- (EPSBezierPath *)lowerFactory;
- (EPSBezierPath *)lowerShineFactory;
- (EPSBezierPath *)upperShineFactory;
- (EPSBezierPath *)upperFactory;
- (EPSBezierPath *)chartFactory;
- (void)createGradient;
- (void)destroyGradient;
- (void)drawGradient:(CGGradientRef)aGradient inBezierPath:(UIBezierPath *)path angle:(CGFloat)angle;
@end

@implementation OpenStatesIconView
@synthesize outerPath=_outerPath;
@synthesize lowerPath=_lowerPath;
@synthesize lowerShinePath=_lowerShinePath;
@synthesize upperShinePath=_upperShinePath;
@synthesize upperPath=_upperPath;
@synthesize chartPath=_chartPath;
@synthesize useGradientOverlay;

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
    self.outerPath = nil;
    self.lowerPath = nil;
    self.lowerShinePath = nil;
    self.upperShinePath = nil;
    self.upperPath = nil;
    self.chartPath = nil;
    [self destroyGradient];
    [super dealloc];
}

- (void)configure {
    self.contentMode = UIViewContentModeRedraw;
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    self.opaque = NO;
    self.layer.shouldRasterize = YES;
    self.layer.shadowColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.375f] CGColor];
    self.layer.shadowOffset = CGSizeMake(0, 5);
    self.layer.shadowOpacity = 1.f;
    self.layer.shadowRadius = 5.0f;
    [self createGradient];
    self.useGradientOverlay = YES;
    self.outerPath = [self outerFactory];    
    self.lowerPath = [self lowerFactory];
    self.lowerShinePath = [self lowerShineFactory];
    self.upperShinePath = [self upperShineFactory];
    self.upperPath = [self upperFactory];
    self.chartPath = [self chartFactory];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(kOpenStatesIconViewWidth, kOpenStatesIconViewHeight);
}

- (void)drawRect:(CGRect)viewBounds
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, kOpenStatesIconViewWidth, kOpenStatesIconViewHeight);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat widthRatio = CGRectGetWidth(viewBounds) / CGRectGetWidth(imageBounds);
    CGFloat heightRatio = CGRectGetHeight(viewBounds) / CGRectGetHeight(imageBounds);
//  CGFloat scale = 0.5f * ( widthRatio + heightRatio );
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(viewBounds),CGRectGetMinY(viewBounds));
    CGContextScaleCTM(context, widthRatio, heightRatio);
    
    [_outerPath fillIfNeeded];
    [_lowerPath fillIfNeeded];
    [_lowerShinePath fillIfNeeded];
    [_upperPath fillIfNeeded];    
    [_upperShinePath fillIfNeeded];
    [_chartPath fillIfNeeded];
    
    if (useGradientOverlay)
        [self drawGradient:_gradient inBezierPath:_outerPath angle:105.f];

    CGContextRestoreGState(context);
}

- (EPSBezierPath *)outerFactory {
    EPSBezierPath *path = [EPSBezierPath pathWithFillColor:SLFColorWithRGB(236,236,225) strokeColor:nil];
	[path moveToPoint:CGPointMake(425,17)];
	[path startCurveWithControlPoint2:CGPointMake(345,44) end:CGPointMake(257,17)];
	[path addLineToPoint:CGPointMake(257, 17)];
	[path continueCurveWithControlPoint1:CGPointMake(257,17) point2:CGPointMake(256,17) end:CGPointMake(256,17)];
	[path continueCurveWithControlPoint1:CGPointMake(256,17) point2:CGPointMake(255,17) end:CGPointMake(255,17)];
	[path addLineToPoint:CGPointMake(255,17)];
	[path endCurveWithControlPoint1:CGPointMake(167,44) end:CGPointMake(87,17)];
	[path startCurveWithControlPoint2:CGPointMake(-142,330) end:CGPointMake(255,494)];
	[path addLineToPoint:CGPointMake(255,495)];
	[path continueCurveWithControlPoint1:CGPointMake(255,495) point2:CGPointMake(256,495) end:CGPointMake(256,495)];
	[path continueCurveWithControlPoint1:CGPointMake(256,495) point2:CGPointMake(257,495) end:CGPointMake(257,495)];
	[path addLineToPoint:CGPointMake(257,494)];
	[path endCurveWithControlPoint1:CGPointMake(655,330) end:CGPointMake(425,17)];
    [path closePath];
    return path;
}

- (EPSBezierPath *)lowerFactory {
    EPSBezierPath *path = [EPSBezierPath pathWithFillColor:SLFColorWithRGB(111, 106, 102) strokeColor:nil];
	[path moveToPoint:CGPointMake(48,161)];
	[path continueCurveWithControlPoint1:CGPointMake(27,257) point2:CGPointMake(48,387) end:CGPointMake(255,473)];
	[path addLineToPoint:CGPointMake(255,473)];
	[path continueCurveWithControlPoint1:CGPointMake(255,473) point2:CGPointMake(256,473) end:CGPointMake(256,473)];
	[path continueCurveWithControlPoint1:CGPointMake(256,473) point2:CGPointMake(257,473) end:CGPointMake(257,473)];
	[path addLineToPoint:CGPointMake(257,473)];
	[path continueCurveWithControlPoint1:CGPointMake(465,387) point2:CGPointMake(483,257) end:CGPointMake(462,161)];
	[path addLineToPoint:CGPointMake(48,161)];
    [path closePath];
    return path;
}

- (EPSBezierPath *)lowerShineFactory {
    EPSBezierPath *path = [EPSBezierPath pathWithFillColor:SLFColorWithRGB(70, 69, 68) strokeColor:nil];
    [path moveToPoint:CGPointMake(48,161)];
    [path continueCurveWithControlPoint1:CGPointMake(27,257) point2:CGPointMake(48,387) end:CGPointMake(255,473)];
    [path addLineToPoint:CGPointMake(255,473)];
    [path continueCurveWithControlPoint1:CGPointMake(255,473) point2:CGPointMake(256,473) end:CGPointMake(256,473)];
    [path continueCurveWithControlPoint1:CGPointMake(256,473) point2:CGPointMake(257,473) end:CGPointMake(257,473)];
    [path addLineToPoint:CGPointMake(257,473)];
    [path endCurveWithControlPoint1:CGPointMake(90,313) end:CGPointMake(123,161)];
    [path addLineToPoint:CGPointMake(48,161)];
    [path closePath];
    return path;
}

- (EPSBezierPath *)upperShineFactory {
    EPSBezierPath *path = [EPSBezierPath pathWithFillColor:SLFColorWithRGB(191, 82, 41) strokeColor:nil];
    [path moveToPoint:CGPointMake(161,49)];
    [path endCurveWithControlPoint1:CGPointMake(125,47)  end:CGPointMake(102,39)];
    [path startCurveWithControlPoint2:CGPointMake(71,81) end:CGPointMake(53,142)];
    [path addLineToPoint:CGPointMake(128,142)];
    [path startCurveWithControlPoint2:CGPointMake(141,90) end:CGPointMake(161,49)];
    [path closePath];
    return path;
}

- (EPSBezierPath *)upperFactory {
    EPSBezierPath *path = [EPSBezierPath pathWithFillColor:SLFColorWithRGB(211, 111, 40) strokeColor:nil];
    [path moveToPoint:CGPointMake(457,142)];
    [path endCurveWithControlPoint1:CGPointMake(440,81)  end:CGPointMake(409,39)];
    [path startCurveWithControlPoint2:CGPointMake(337,63) end:CGPointMake(257,39)];
    [path addLineToPoint:CGPointMake(257,39)];
    [path continueCurveWithControlPoint1:CGPointMake(257,39) point2:CGPointMake(256,39) end:CGPointMake(256,39)];
    [path continueCurveWithControlPoint1:CGPointMake(256,39) point2:CGPointMake(255,39) end:CGPointMake(255,39)];
    [path addLineToPoint:CGPointMake(255,39)];
    [path endCurveWithControlPoint1:CGPointMake(175,63) end:CGPointMake(102,39)];
    [path startCurveWithControlPoint2:CGPointMake(71,81) end:CGPointMake(53,142)];
    [path addLineToPoint:CGPointMake(457,142)];
    [path closePath];
    return path;
}

- (EPSBezierPath *)chartFactory {
    EPSBezierPath *path = [EPSBezierPath pathWithFillColor:[UIColor whiteColor] strokeColor:nil];
    [path moveToPoint:CGPointMake(195,292)];
    [path addLineToPoint:CGPointMake(124,292)];
    [path addLineToPoint:CGPointMake(124,351)];
    [path addLineToPoint:CGPointMake(195,351)];
    [path addLineToPoint:CGPointMake(195,292)];
    [path closePath];
    [path moveToPoint:CGPointMake(292,351)];
    [path addLineToPoint:CGPointMake(221,351)];
    [path addLineToPoint:CGPointMake(221,247)];
    [path addLineToPoint:CGPointMake(292,247)];
    [path addLineToPoint:CGPointMake(292,351)];
    [path closePath];
    [path moveToPoint:CGPointMake(388,351)];
    [path addLineToPoint:CGPointMake(318,351)];
    [path addLineToPoint:CGPointMake(318,203)];
    [path addLineToPoint:CGPointMake(388,203)];
    [path addLineToPoint:CGPointMake(388,351)];
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

#if !defined(DegreesToRadians)
#define DegreesToRadians(x) (x * (CGFloat)M_PI / 180.0f)
#endif

#if !defined(RadiansToDegrees)
#define RadiansToDegrees(x) (x * 180.0f / (CGFloat)M_PI)
#endif

- (void)drawGradient:(CGGradientRef)aGradient inBezierPath:(UIBezierPath *)path angle:(CGFloat)angle
{
	CGRect rect = path.bounds;
	CGPoint startPoint = rect.origin;
    CGPoint endPoint = CGPointMake(0.0f, CGRectGetHeight(rect));
	if(angle == 0)
  	{
		startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
		endPoint   = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
  	} else if(angle == 90) {
		startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
		endPoint   = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
  	} else {
		double_t x, y;
		double_t sina, cosa, tana;
		double_t length;
		double_t deltax, deltay;
        
		double_t radians = DegreesToRadians(angle);
        
		if(fabs(tan(radians)) <= 1.0f)
		{
			x = CGRectGetWidth(rect);
			y = CGRectGetHeight(rect);
            
			sina = sin(radians);
			cosa = cos(radians);
			tana = tan(radians);
            
			length = x/fabs(cosa) + (y - x * fabs(tana)) * fabs(sina);
            
			deltax = length * cosa/2;
			deltay = length * sina/2;
		} else	{
			x = CGRectGetHeight(rect);
			y = CGRectGetWidth(rect);
            
			sina = sin(radians - DegreesToRadians(90));
			cosa = cos(radians - DegreesToRadians(90));
			tana = tan(radians - DegreesToRadians(90));
            
			length = x/fabs(cosa) + (y - x * fabs(tana)) * fabs(sina);
            
			deltax = -length * sina/2;
			deltay = length * cosa/2;
		}
        
		startPoint = CGPointMake(CGRectGetMidX(rect) - (CGFloat)deltax, CGRectGetMidY(rect) - (CGFloat)deltay);
		endPoint   = CGPointMake(CGRectGetMidX(rect) + (CGFloat)deltax, CGRectGetMidY(rect) + (CGFloat)deltay);
	}
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextAddPath(context, path.CGPath);
	CGContextClip(context);
    CGContextSetBlendMode(context, kCGBlendModeDifference);
	CGContextDrawLinearGradient(context, aGradient, startPoint, endPoint, 0);
	CGContextRestoreGState(context);
}

@end
