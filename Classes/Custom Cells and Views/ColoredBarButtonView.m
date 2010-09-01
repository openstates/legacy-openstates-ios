//
//	ColoredBarButtonView.m
//	Green Button
//
//	Created by Gregory Combs on 8/14/10
//

#import "ColoredBarButtonView.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat kMyViewWidth = 50.0f;
const CGFloat kMyViewHeight = 30.0f;

@implementation ColoredBarButtonView
@synthesize green, colorGrad1, colorGrad2, colorGrad3, colorGrad4, colorGrad5;
@synthesize selected;//, title;

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
/*
if (self.green && !self.selected)
	color = [UIColor colorWithRed:0.465f green:0.593f blue:0.23f alpha:1.0f];
else if (self.green && self.selected)
	color = [UIColor colorWithRed:0.3f green:0.38f blue:0.147f alpha:1.0f];
else if (!self.green && !self.selected)
	color = [UIColor colorWithRed:0.145f green:0.164f blue:0.179f alpha:1.0f];
else if (!self.green && self.selected)
	color = [UIColor colorWithRed:0.092f green:0.104f blue:0.114f alpha:1.0f];
*/
- (void)setGreen:(BOOL)isGreen {
	green = isGreen;
	
	if (green) {
		self.colorGrad1 = [UIColor colorWithRed:0.435f green:0.538f blue:0.256f alpha:1.0f];
		self.colorGrad2 = [UIColor colorWithRed:0.558f green:0.69f blue:0.329f alpha:1.0f];
		self.colorGrad3 = [UIColor colorWithRed:0.594f green:0.734f blue:0.349f alpha:1.0f];
		self.colorGrad4 = [UIColor colorWithRed:0.726f green:0.897f blue:0.427f alpha:1.0f];
		self.colorGrad5 = [UIColor colorWithRed:0.646f green:0.799f blue:0.38f alpha:1.0f];
	} else {
		self.colorGrad1 = [UIColor colorWithRed:0.158f green:0.184f blue:0.201f alpha:1.0f];
		self.colorGrad2 = [UIColor colorWithRed:0.243f green:0.283f blue:0.31f alpha:1.0f];
		self.colorGrad3 = [UIColor colorWithRed:0.273f green:0.318f blue:0.348f alpha:1.0f];
		self.colorGrad4 = [UIColor colorWithRed:0.426f green:0.497f blue:0.543f alpha:1.0f];
		self.colorGrad5 = [UIColor colorWithRed:0.302f green:0.353f blue:0.384f alpha:1.0f];
	}
	[self setNeedsDisplay];
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

- (void)setColorGrad:(UIColor *)value atIndex:(NSInteger)index
{
	switch (index) {
		case 1:
			self.colorGrad1 = value;
			break;
		case 2:
			self.colorGrad2 = value;
			break;
		case 3:
			self.colorGrad3 = value;
			break;
		case 4:
			self.colorGrad4 = value;
			break;
		case 5:
			self.colorGrad5 = value;
			break;
	}
	[self setNeedsDisplay];
}


- (void)drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, kMyViewWidth, kMyViewHeight);
	CGRect bounds = [self bounds];
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIColor *color;
	CGFloat resolution;
	size_t bytesPerRow;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGFloat alignStroke;
	CGMutablePathRef path;
	CGPoint point;
	CGPoint controlPoint1;
	CGPoint controlPoint2;
	CGImageRef contextImage;
	CGRect effectBounds;
	unsigned char *pixels;
	CGFloat minX, maxX, minY, maxY;
	NSUInteger width, height;
	CGContextRef maskContext;
	CGImageRef maskImage;
	CGDataProviderRef provider;
	NSData *data;
	CGGradientRef gradient;
	NSMutableArray *colors;
	CGPoint point2;
	CGFloat locations[5];
	resolution = 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Stroke Folder
	
	// Setup for Shadow Effect
	color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f * resolution, 1.0f * resolution), 0.0f * resolution, [color CGColor]);
	CGContextBeginTransparencyLayer(context, NULL);
	
	// Setup for Inner Shadow Effect
	bytesPerRow = 4 * roundf(bounds.size.width);
	
	NSMutableData *shadowBuffer = [NSMutableData dataWithCapacity:(bytesPerRow * roundf(bounds.size.height) * roundf(bounds.size.width))];

	context = CGBitmapContextCreate([shadowBuffer mutableBytes], roundf(bounds.size.width), roundf(bounds.size.height), 8, bytesPerRow, space, kCGImageAlphaPremultipliedLast);
	UIGraphicsPushContext(context);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Outer
	
	alignStroke = 0.0f;
	path = CGPathCreateMutable();
	point = CGPointMake(46.0f, 30.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(50.0f, 26.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(48.194f, 30.0f);
	controlPoint2 = CGPointMake(50.0f, 28.194f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(50.0f, 4.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(46.0f, 0.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(50.0f, 1.806f);
	controlPoint2 = CGPointMake(48.194f, 0.0f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(4.0f, 0.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(0.0f, 4.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(1.806f, 0.0f);
	controlPoint2 = CGPointMake(0.0f, 1.806f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(0.0f, 26.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(4.0f, 30.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(0.0f, 28.194f);
	controlPoint2 = CGPointMake(1.806f, 30.0f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(46.0f, 30.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	CGPathCloseSubpath(path);
	color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
	[color setFill];
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	CGPathRelease(path);
	
	// Inner Shadow Effect
	pixels = (unsigned char *)CGBitmapContextGetData(context);
	width = roundf(bounds.size.width);
	height = roundf(bounds.size.height);
	minX = width;
	maxX = -1.0f;
	minY = height;
	maxY = -1.0f;
	for (NSInteger row = 0; row < height; row++) {
		for (NSInteger column = 0; column < width; column++) {
			if (pixels[4 * (width * row + column) + 3] > 0) {
				minX = MIN(minX, (CGFloat)column);
				maxX = MAX(maxX, (CGFloat)column);
				minY = MIN(minY, (CGFloat)(height - row));
				maxY = MAX(maxY, (CGFloat)(height - row));
			}
		}
	}
	contextImage = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	UIGraphicsPopContext();
	context = UIGraphicsGetCurrentContext();
	CGContextDrawImage(context, imageBounds, contextImage);
	if ((minX <= maxX) && (minY <= maxY)) {
		CGContextSaveGState(context);
		effectBounds = CGRectMake(minX, minY - 1.0f, maxX - minX + 1.0f, maxY - minY + 1.0f);
		effectBounds = CGRectInset(effectBounds, -(ABS(1.0f * cosf(1.571f) * resolution) + 0.0f), -(ABS(1.0f * sinf(1.571f) * resolution) + 0.0f));
		effectBounds = CGRectIntegral(effectBounds);
		color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
		CGContextSetShadowWithColor(context, CGSizeMake(1.0f * cosf(1.571f) * resolution, 1.0f * sinf(1.571f) * resolution - effectBounds.size.height), 0.0f, [color CGColor]);
		bytesPerRow = roundf(effectBounds.size.width);
		[shadowBuffer setLength:(bytesPerRow * roundf(effectBounds.size.height) * roundf(effectBounds.size.width))];

		maskContext = CGBitmapContextCreate([shadowBuffer mutableBytes], roundf(effectBounds.size.width), roundf(effectBounds.size.height), 8, bytesPerRow, NULL, kCGImageAlphaOnly);
		CGContextDrawImage(maskContext, CGRectMake(-effectBounds.origin.x, -effectBounds.origin.y, bounds.size.width, bounds.size.height), contextImage);
		maskImage = CGBitmapContextCreateImage(maskContext);
		data = [NSData dataWithBytes:CGBitmapContextGetData(maskContext) length:bytesPerRow * roundf(effectBounds.size.height)];
		provider = CGDataProviderCreateWithCFData((CFDataRef)data);
		CGImageRelease(contextImage);
		contextImage = CGImageMaskCreate(roundf(effectBounds.size.width), roundf(effectBounds.size.height), 8, 8, bytesPerRow, provider, NULL, 0);
		CGDataProviderRelease(provider);
		CGContextRelease(maskContext);
		CGContextScaleCTM(context, (imageBounds.size.width / bounds.size.width), (imageBounds.size.height / bounds.size.height));
		CGContextClipToMask(context, effectBounds, maskImage);
		CGImageRelease(maskImage);
		effectBounds.origin.y += effectBounds.size.height;
		[[UIColor blackColor] setFill];
		CGContextDrawImage(context, effectBounds, contextImage);
		CGContextRestoreGState(context);
	}
	CGImageRelease(contextImage);
	
	// Shadow Effect
	CGContextEndTransparencyLayer(context);
	CGContextRestoreGState(context);
	
	// Green Folder
	
	// Setup for Shadow Effect
	color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f];
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f * resolution, 1.0f * resolution), 0.0f * resolution, [color CGColor]);
	CGContextBeginTransparencyLayer(context, NULL);
	
	// Green Inner
	
	alignStroke = 0.0f;
	path = CGPathCreateMutable();
	point = CGPointMake(45.0f, 29.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(49.0f, 25.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(47.194f, 29.0f);
	controlPoint2 = CGPointMake(49.0f, 27.194f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(49.0f, 5.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(45.0f, 1.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(49.0f, 2.806f);
	controlPoint2 = CGPointMake(47.194f, 1.0f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(5.0f, 1.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(1.0f, 5.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(2.806f, 1.0f);
	controlPoint2 = CGPointMake(1.0f, 2.806f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(1.0f, 25.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(5.0f, 29.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(1.0f, 27.194f);
	controlPoint2 = CGPointMake(2.806f, 29.0f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(45.0f, 29.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	CGPathCloseSubpath(path);
	colors = [NSMutableArray arrayWithCapacity:5];
	[colors addObject:(id)[[self colorGrad1] CGColor]];
	locations[0] = 0.0f;
	[colors addObject:(id)[[self colorGrad5] CGColor]];
	locations[1] = 1.0f;
	[colors addObject:(id)[[self colorGrad4] CGColor]];
	locations[2] = 0.972f;
	[colors addObject:(id)[[self colorGrad2] CGColor]];
	locations[3] = self.green ? 0.472f : 0.459f;
	[colors addObject:(id)[[self colorGrad3] CGColor]];
	locations[3] = self.green ? 0.49f : 0.483f;
	gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	point = CGPointMake(25.0f, 29.0f);
	point2 = CGPointMake(25.0f, 1.0f);
	CGContextDrawLinearGradient(context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
	CGContextRestoreGState(context);
	CGGradientRelease(gradient);
	CGPathRelease(path);
	
	// Shadow Effect
	CGContextEndTransparencyLayer(context);
	CGContextRestoreGState(context);
	
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
}

@end
