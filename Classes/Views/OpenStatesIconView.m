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

@interface OpenStatesIconView()
@property (nonatomic,retain) EPSBezierPath *outerPath;
@property (nonatomic,retain) EPSBezierPath *lowerPath;
@property (nonatomic,retain) EPSBezierPath *lowerShinePath;
@property (nonatomic,retain) EPSBezierPath *upperShinePath;
@property (nonatomic,retain) EPSBezierPath *upperPath;
@property (nonatomic,retain) EPSBezierPath *chartPath;
- (void)configurePaths;
- (EPSBezierPath *)outerFactory;
- (EPSBezierPath *)lowerFactory;
- (EPSBezierPath *)lowerShineFactory;
- (EPSBezierPath *)upperShineFactory;
- (EPSBezierPath *)upperFactory;
- (EPSBezierPath *)chartFactory;
@end

@implementation OpenStatesIconView
@synthesize outerPath=_outerPath;
@synthesize lowerPath=_lowerPath;
@synthesize lowerShinePath=_lowerShinePath;
@synthesize upperShinePath=_upperShinePath;
@synthesize upperPath=_upperPath;
@synthesize chartPath=_chartPath;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configurePaths];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configurePaths];
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
    [super dealloc];
}

- (void)configurePaths {
    self.contentMode = UIViewContentModeRedraw;
    self.autoresizingMask = UIViewAutoresizingNone;
    self.opaque = NO;
    self.outerPath = [self outerFactory];    
    self.lowerPath = [self lowerFactory];
    self.lowerShinePath = [self lowerShineFactory];
    self.upperShinePath = [self upperShineFactory];
    self.upperPath = [self upperFactory];
    self.chartPath = [self chartFactory];
    [self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(512.f, 512.f);
}

- (void)drawRect:(CGRect)viewBounds
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, 512.f, 512.f);
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
    CGContextRestoreGState(context);
}

- (EPSBezierPath *)outerFactory {
    EPSBezierPath *path = [EPSBezierPath pathWithFillColor:[UIColor colorWithWhite:.9 alpha:1] strokeColor:nil];
	[path moveToPoint:CGPointMake(425.2344, 17)];
	[path startCurveWithControlPoint2:CGPointMake(345, 44.0176) end:CGPointMake(257, 17.4648)];
	[path addLineToPoint:CGPointMake(257, 17)];
	[path continueCurveWithControlPoint1:CGPointMake(257, 17.0742) point2:CGPointMake(256.2598, 17.1484) end:CGPointMake(256, 17.2227)];
	[path continueCurveWithControlPoint1:CGPointMake(255.7305, 17.1484) point2:CGPointMake(255, 17.0742) end:CGPointMake(255, 17)];
	[path addLineToPoint:CGPointMake(255, 17.4648)];
	[path endCurveWithControlPoint1:CGPointMake(167, 44.0176) end:CGPointMake(86.7651, 17)];
	[path startCurveWithControlPoint2:CGPointMake(-142, 330.0605) end:CGPointMake(255, 494.3496)];
	[path addLineToPoint:CGPointMake(255, 495)];
	[path continueCurveWithControlPoint1:CGPointMake(255, 494.9082) point2:CGPointMake(255.7305, 494.7773) end:CGPointMake(256, 494.667)];
	[path continueCurveWithControlPoint1:CGPointMake(256.2598, 494.7773) point2:CGPointMake(257, 494.9082) end:CGPointMake(257, 495)];
	[path addLineToPoint:CGPointMake(257, 494.3496)];
	[path endCurveWithControlPoint1:CGPointMake(655, 330.0605) end:CGPointMake(425.2344, 17)];
    [path closePath];
    return path;
}

- (EPSBezierPath *)lowerFactory {
    EPSBezierPath *path = [EPSBezierPath pathWithFillColor:[UIColor grayColor] strokeColor:nil];
	[path moveToPoint:CGPointMake(48.2549, 161)];
	[path continueCurveWithControlPoint1:CGPointMake(27.2949, 257) point2:CGPointMake(48, 386.9336) end:CGPointMake(255, 472.6992)];
	[path addLineToPoint:CGPointMake(255, 473.2754)];
	[path continueCurveWithControlPoint1:CGPointMake(255, 473.1641) point2:CGPointMake(255.75, 473.0713) end:CGPointMake(256, 472.9785)];
	[path continueCurveWithControlPoint1:CGPointMake(256.2402, 473.0713) point2:CGPointMake(257, 473.1641) end:CGPointMake(257, 473.2754)];
	[path addLineToPoint:CGPointMake(257, 472.6992)];
	[path continueCurveWithControlPoint1:CGPointMake(465, 386.9336) point2:CGPointMake(483.3262, 257) end:CGPointMake(462.3672, 161)];
	[path addLineToPoint:CGPointMake(48.2549, 161)];
    [path closePath];
    return path;
}

- (EPSBezierPath *)lowerShineFactory {
    EPSBezierPath *path = [EPSBezierPath pathWithFillColor:[UIColor darkGrayColor] strokeColor:nil];
    [path moveToPoint:CGPointMake(48.2549,161)];
    [path continueCurveWithControlPoint1:CGPointMake(27.2949, 257) point2:CGPointMake(48,386.9336) end:CGPointMake(255,472.6992)];
    [path addLineToPoint:CGPointMake(255,473.2754)];
    [path continueCurveWithControlPoint1:CGPointMake(255,473.1641) point2:CGPointMake(255.75,473.0713) end:CGPointMake(256,472.9785)];
    [path continueCurveWithControlPoint1:CGPointMake(256.2402,473.0713) point2:CGPointMake(257,473.1641) end:CGPointMake(257,473.2754)];
    [path addLineToPoint:CGPointMake(257,472.6992)];
    [path endCurveWithControlPoint1:CGPointMake(90,312.8096) end:CGPointMake(123.4873,161)];
    [path addLineToPoint:CGPointMake(48.2549,161)];
    [path closePath];
    return path;
}

- (EPSBezierPath *)upperShineFactory {
    EPSBezierPath *path = [EPSBezierPath pathWithFillColor:[UIColor brownColor] strokeColor:nil];
    [path moveToPoint:CGPointMake(160.8618, 49.3271)];
    [path endCurveWithControlPoint1:CGPointMake(125.4351, 46.9873)  end:CGPointMake(101.6548, 39.0117)];
    [path startCurveWithControlPoint2:CGPointMake(70.6323, 81) end:CGPointMake(53.2168, 142)];
    [path addLineToPoint:CGPointMake(128.272, 142)];
    [path startCurveWithControlPoint2:CGPointMake(141.0342, 89.8984) end:CGPointMake(160.8618, 49.3271)];
    [path closePath];
    return path;
}

- (EPSBezierPath *)upperFactory {
    EPSBezierPath *path = [EPSBezierPath pathWithFillColor:[UIColor orangeColor] strokeColor:nil];
    [path moveToPoint:CGPointMake(457.4053,142)];
    [path endCurveWithControlPoint1:CGPointMake(439.9971,81)  end:CGPointMake(409.4492,38.9102)];
    [path startCurveWithControlPoint2:CGPointMake(337,63.291) end:CGPointMake(257,39.1328)];
    [path addLineToPoint:CGPointMake(257,38.7061)];
    [path continueCurveWithControlPoint1:CGPointMake(257,38.7988) point2:CGPointMake(256.2402,38.873) end:CGPointMake(256,38.9287)];
    [path continueCurveWithControlPoint1:CGPointMake(255.75,38.873) point2:CGPointMake(255,38.7988) end:CGPointMake(255,38.7061)];
    [path addLineToPoint:CGPointMake(255,39.1328)];
    [path endCurveWithControlPoint1:CGPointMake(175,63.291) end:CGPointMake(101.8511,38.9102)];
    [path startCurveWithControlPoint2:CGPointMake(70.6323,81) end:CGPointMake(53.2168,142)];
    [path addLineToPoint:CGPointMake(457.4053,142)];
    [path closePath];
    return path;
}

- (EPSBezierPath *)chartFactory {
    EPSBezierPath *path = [EPSBezierPath pathWithFillColor:[UIColor whiteColor] strokeColor:nil];
    [path moveToPoint:CGPointMake(195, 292)];
    [path addLineToPoint:CGPointMake(124, 292)];
    [path addLineToPoint:CGPointMake(124, 351)];
    [path addLineToPoint:CGPointMake(195, 351)];
    [path addLineToPoint:CGPointMake(195, 292)];
    [path closePath];
    [path moveToPoint:CGPointMake(292, 351)];
    [path addLineToPoint:CGPointMake(221, 351)];
    [path addLineToPoint:CGPointMake(221, 247)];
    [path addLineToPoint:CGPointMake(292, 247)];
    [path addLineToPoint:CGPointMake(292, 351)];
    [path closePath];
    [path moveToPoint:CGPointMake(388, 351)];
    [path addLineToPoint:CGPointMake(318, 351)];
    [path addLineToPoint:CGPointMake(318, 203)];
    [path addLineToPoint:CGPointMake(388, 203)];
    [path addLineToPoint:CGPointMake(388, 351)];
    [path closePath];
    return path;
}
@end
