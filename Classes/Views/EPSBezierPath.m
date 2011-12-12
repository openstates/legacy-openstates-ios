//
//  EPSBezierPath.m
//  Created by Greg Combs on 11/13/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "EPSBezierPath.h"

@interface EPSBezierPath()
@property (nonatomic,assign) CGPoint previousPoint;
@end

@implementation EPSBezierPath
@synthesize previousPoint = _previousPoint;
@synthesize fillColor = _fillColor;
@synthesize strokeColor = _strokeColor;

+ (EPSBezierPath *)pathWithFillColor:(UIColor *)fill strokeColor:(UIColor *)stroke {
    EPSBezierPath *path = [[[EPSBezierPath alloc] init] autorelease];
    path.fillColor = fill;
    path.strokeColor = stroke;
    return path;
}

- (void)dealloc {
    self.fillColor = nil;
    self.strokeColor = nil;
    [super dealloc];
}

    // EPS:"M"
- (void)moveToPoint:(CGPoint)point {
    [super moveToPoint:point];
    _previousPoint = point;
}

    // EPS:"L"
- (void)addLineToPoint:(CGPoint)point {
    [super addLineToPoint:point];
    _previousPoint = point;
}

    // EPS:"V"
- (void)startCurveWithControlPoint2:(CGPoint)point2 end:(CGPoint)end {
    [super addCurveToPoint:end controlPoint1:_previousPoint controlPoint2:point2];
    _previousPoint = end;
}

    // EPS:"C"
- (void)continueCurveWithControlPoint1:(CGPoint)point1 point2:(CGPoint)point2 end:(CGPoint)end {
    [super addCurveToPoint:end controlPoint1:point1 controlPoint2:point2];
    _previousPoint = end;
}

    // EPS:"Y"
- (void)endCurveWithControlPoint1:(CGPoint)point1 end:(CGPoint)end {
    [super addCurveToPoint:end controlPoint1:point1 controlPoint2:end];
    _previousPoint = end;
}

- (void)fillIfNeeded {
    if (!self.fillColor)
        return;
    [_fillColor setFill];
    [self fill];
}

- (void)strokeIfNeeded {
    if (!self.strokeColor)
        return;
    [_strokeColor setStroke];
    [self stroke];
}

- (void)fillAndStrokeIfNeeded {
    [self fillIfNeeded];
    [self strokeIfNeeded];
}
@end
