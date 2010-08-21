//
//	ColoredBarButtonView.m
//	Green Button
//
//	Created by Gregory Combs on 8/14/10
//

#import "ColoredBarButtonView.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat kMyViewWidth = 120.0f;
const CGFloat kMyViewHeight = 30.0f;

@implementation ColoredBarButtonView
@synthesize green, selected;//, title;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self setOpaque:NO];
		self.green = YES;
		self.selected = NO;
		//self.title = @"";
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		[self setOpaque:NO];
		self.green = NO;
		self.selected = NO;
		//self.title = @"Legislators";

	}
	return self;
}


- (UIImage *)imageFromUIView {
	
	UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return viewImage;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return CGSizeMake(kMyViewWidth, kMyViewHeight);
}

- (void)drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, kMyViewWidth, kMyViewHeight);
	CGRect bounds = [self bounds];
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIColor *color;
	CGFloat resolution;
	CGFloat alignStroke;
	CGFloat stroke;
	CGMutablePathRef path;
	CGPoint point;
	CGPoint controlPoint1;
	CGPoint controlPoint2;
	//CGRect drawRect;
	//NSString *string;
	//UIFont *font;
	CGGradientRef gradient;
	NSMutableArray *colors;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGPoint point2;
	CGFloat locations[4];
	resolution = 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Setup for Shadow Effect
	color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f];
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f * resolution, 1.0f * resolution), 0.0f * resolution, [color CGColor]);
	CGContextBeginTransparencyLayer(context, NULL);
	
	// Button Color
	
	stroke = 1.0f;
	stroke *= resolution;
	if (stroke < 1.0f) {
		stroke = ceilf(stroke);
	} else {
		stroke = roundf(stroke);
	}
	stroke /= resolution;
	alignStroke = fmodf(0.5f * stroke * resolution, 1.0f);
	path = CGPathCreateMutable();
	point = CGPointMake(115.5f, 28.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(kMyViewWidth-0.5f, 24.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(117.694f, 28.5f);
	controlPoint2 = CGPointMake(kMyViewWidth-0.5f, 26.694f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(kMyViewWidth-0.5f, 4.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(115.5f, 0.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(kMyViewWidth-0.5f, 2.306f);
	controlPoint2 = CGPointMake(117.694f, 0.5f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(4.5f, 0.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(0.5f, 4.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(2.306f, 0.5f);
	controlPoint2 = CGPointMake(0.5f, 2.306f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(0.5f, 24.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(4.5f, 28.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(0.5f, 26.694f);
	controlPoint2 = CGPointMake(2.306f, 28.5f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(115.5f, 28.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	CGPathCloseSubpath(path);
	
	if (self.green && !self.selected)
		color = [UIColor colorWithRed:0.465f green:0.593f blue:0.23f alpha:1.0f];
	else if (self.green && self.selected)
		color = [UIColor colorWithRed:0.3f green:0.38f blue:0.147f alpha:1.0f];
	else if (!self.green && !self.selected)
		color = [UIColor colorWithRed:0.145f green:0.164f blue:0.179f alpha:1.0f];
	else if (!self.green && self.selected)
		color = [UIColor colorWithRed:0.092f green:0.104f blue:0.114f alpha:1.0f];

	[color setFill];
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	color = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.0f];
	[color setStroke];
	CGContextSetLineWidth(context, stroke);
	CGContextSetLineCap(context, kCGLineCapSquare);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);
	
		// Text Layer
/*	
	//drawRect = CGRectMake(10.0f, 4.688f, 100.5f, 20.313f);
	drawRect = CGRectMake(0.0f, 4.688f, kMyViewWidth, 20.313f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	string = self.title;
	font = [UIFont boldSystemFontOfSize:14];
	color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
	[color set];
	[string drawInRect:drawRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
*/	


 // Button Shine
	CGContextSetAlpha(context, 0.72f);
	CGContextBeginTransparencyLayer(context, NULL);
	
	stroke = 1.0f;
	stroke *= resolution;
	if (stroke < 1.0f) {
		stroke = ceilf(stroke);
	} else {
		stroke = roundf(stroke);
	}
	stroke /= resolution;
	alignStroke = fmodf(0.5f * stroke * resolution, 1.0f);
	path = CGPathCreateMutable();
	point = CGPointMake(115.5f, 28.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(kMyViewWidth-0.5f, 24.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(117.694f, 28.5f);
	controlPoint2 = CGPointMake(kMyViewWidth-0.5f, 26.694f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(119.5f, 4.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(115.5f, 0.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(kMyViewWidth-0.5f, 2.306f);
	controlPoint2 = CGPointMake(117.694f, 0.5f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(4.5f, 0.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(0.5f, 4.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(2.306f, 0.5f);
	controlPoint2 = CGPointMake(0.5f, 2.306f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(0.5f, 24.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(4.5f, 28.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(0.5f, 26.694f);
	controlPoint2 = CGPointMake(2.306f, 28.5f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(115.5f, 28.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	CGPathCloseSubpath(path);
	colors = [NSMutableArray arrayWithCapacity:4];
	color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.2f];
	[colors addObject:(id)[color CGColor]];
	locations[0] = 1.0f;
	color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
	[colors addObject:(id)[color CGColor]];
	locations[1] = 0.75f;
	color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
	[colors addObject:(id)[color CGColor]];
	locations[2] = 0.5f;
	color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f];
	[colors addObject:(id)[color CGColor]];
	locations[3] = 0.02f;
	gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	point = CGPointMake(60.0f, 0.833f);
	point2 = CGPointMake(60.0f, 28.167f);
	CGContextDrawLinearGradient(context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
	CGContextRestoreGState(context);
	CGGradientRelease(gradient);
	color = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.6f];
	[color setStroke];
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);
	
	CGContextEndTransparencyLayer(context);
	
	// Shadow Effect
	CGContextEndTransparencyLayer(context);
	CGContextRestoreGState(context);
	
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
}

@end
