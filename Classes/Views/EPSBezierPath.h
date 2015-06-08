//
//  EPSBezierPath.h
//  Created by Greg Combs on 11/13/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <UIKit/UIKit.h>

/* This simplifies translation of an EPS document's shape paths into a UIBezierPath.
   If you save an EPS document in an older version format, you can easily grab
   the coordinates for shape paths when you open it in a text editor.  This was
   very welcome news to me. I read about it here:
   http://jeffmenter.wordpress.com/2011/04/17/method-for-interpreting-illustrator-art-assets-as-cocoa-cgpathref/
*/

@interface EPSBezierPath : UIBezierPath
+ (EPSBezierPath *)pathWithFillColor:(UIColor *)fill strokeColor:(UIColor *)stroke;
    // EPS:"M"
- (void)moveToPoint:(CGPoint)point;
    // EPS:"L"
- (void)addLineToPoint:(CGPoint)point;
    // EPS:"V"
- (void)startCurveWithControlPoint2:(CGPoint)point2 end:(CGPoint)end;
    // EPS:"C"
- (void)continueCurveWithControlPoint1:(CGPoint)point1 point2:(CGPoint)point2 end:(CGPoint)end;
    // EPS:"Y"
- (void)endCurveWithControlPoint1:(CGPoint)point1 end:(CGPoint)end;

- (void)fillIfNeeded;
- (void)strokeIfNeeded;
- (void)fillAndStrokeIfNeeded;
@property (nonatomic,retain) UIColor *fillColor;
@property (nonatomic,retain) UIColor *strokeColor;
@end
