//
//	DisclosureQuartzView.m
//	
//
//	Created by  on 8/30/10
//	Copyright Like Thought, LLC. All rights reserved.
//	THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import "DisclosureQuartzView.h"
#import <QuartzCore/QuartzCore.h>
#import "TexLegeTheme.h"

const CGFloat kDisclosureQuartzViewWidth = 32.0f;
const CGFloat kDisclosureQuartzViewHeight = 32.0f;

@implementation DisclosureQuartzView


- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self setOpaque:NO];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		[self setOpaque:NO];
	}
	return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return CGSizeMake(kDisclosureQuartzViewWidth, kDisclosureQuartzViewHeight);
}

- (UIImage *)imageFromUIView {
	
	UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return viewImage;
}


- (void)drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, kDisclosureQuartzViewWidth, kDisclosureQuartzViewHeight);
	CGRect bounds = [self bounds];
	CGContextRef context = UIGraphicsGetCurrentContext();
	size_t bytesPerRow;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGFloat alignStroke;
	CGFloat resolution;
	CGFloat stroke;
	CGMutablePathRef path = nil;
	CGRect drawRect;
	UIColor *color;
	CGAffineTransform transform;
	NSString *string;
	UIFont *font;
	CGImageRef contextImage = nil;
	CGRect effectBounds;
	unsigned char *pixels = nil;
	CGFloat minX, maxX, minY, maxY;
	NSUInteger width, height;
	CGContextRef maskContext = nil;
	CGImageRef maskImage = nil;
	CGDataProviderRef provider = nil;
	NSData *data = nil;
	void *bitmapData = nil;
	
	resolution = 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// DisclosureGroup
	
	// Setup for Inner Shadow Effect
	bytesPerRow = 4 * roundf(bounds.size.width);

	bitmapData = calloc(bytesPerRow * round(bounds.size.height), 8);
	context = CGBitmapContextCreate(bitmapData, round(bounds.size.width), round(bounds.size.height), 8, bytesPerRow, space, kCGImageAlphaPremultipliedLast);

	UIGraphicsPushContext(context);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Disclosure
	
	stroke = 1.5f;
	stroke *= resolution;
	if (stroke < 1.0f) {
		stroke = ceilf(stroke);
	} else {
		stroke = roundf(stroke);
	}
	stroke /= resolution;
	alignStroke = fmodf(0.5f * stroke * resolution, 1.0f);
	path = CGPathCreateMutable();
	
	drawRect = CGRectMake(1.0f, 1.0f, 30.0f, 30.0f);

	drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	CGPathAddEllipseInRect(path, NULL, drawRect);
	color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
	[color setFill];
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	color = [UIColor colorWithRed:0.814f green:0.821f blue:0.843f alpha:1.0f];
	[color setStroke];
	CGContextSetLineWidth(context, stroke);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);
	
	CGContextSaveGState(context);
	transform = CGAffineTransformMakeTranslation(CGRectGetMidX(drawRect), CGRectGetMidY(drawRect));

	transform = CGAffineTransformScale(transform, 0.882f, 0.882f);
	drawRect.size.width /= 0.882f;
	drawRect.size.height /= 0.882f;

	transform = CGAffineTransformTranslate(transform, -CGRectGetMidX(drawRect), -CGRectGetMidY(drawRect));
	CGContextConcatCTM(context, transform);

	drawRect = CGRectMake(5.0f, 3.0f, 30.0f, 30.0f);

	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	string = @">";
	font = [UIFont fontWithName:@"HiraKakuProN-W6" size:28.0f];
	color = [TexLegeTheme accent];
	[color set];
	[string drawInRect:drawRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	CGContextRestoreGState(context);
	
	// Inner Shadow Effect
	bitmapData = (unsigned char *)CGBitmapContextGetData(context);
	pixels = (unsigned char *)bitmapData;

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
	free(bitmapData);

	UIGraphicsPopContext();
	context = UIGraphicsGetCurrentContext();
	CGContextDrawImage(context, imageBounds, contextImage);
	if ((minX <= maxX) && (minY <= maxY)) {
		CGContextSaveGState(context);
		effectBounds = CGRectMake(minX, minY - 1.0f, maxX - minX + 1.0f, maxY - minY + 1.0f);
		effectBounds = CGRectInset(effectBounds, -(ABS(3.172f * cosf(1.571f) * resolution) + 4.291f), -(ABS(3.172f * sinf(1.571f) * resolution) + 4.291f));
		effectBounds = CGRectIntegral(effectBounds);
		color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
		CGContextSetShadowWithColor(context, CGSizeMake(3.172f * cosf(1.571f) * resolution, 3.172f * sinf(1.571f) * resolution - effectBounds.size.height), 4.291f, [color CGColor]);
		bytesPerRow = roundf(effectBounds.size.width);
		bitmapData = calloc(bytesPerRow * round(effectBounds.size.height), 8);
		maskContext = CGBitmapContextCreate(bitmapData, round(effectBounds.size.width), round(effectBounds.size.height), 8, bytesPerRow, NULL, kCGImageAlphaOnly);

		//[shadowBuffer setLength:(bytesPerRow * roundf(effectBounds.size.height) * roundf(effectBounds.size.width))];
		//maskContext = CGBitmapContextCreate([shadowBuffer mutableBytes], roundf(effectBounds.size.width), roundf(effectBounds.size.height), 8, bytesPerRow, NULL, kCGImageAlphaOnly);
		CGContextDrawImage(maskContext, CGRectMake(-effectBounds.origin.x, -effectBounds.origin.y, bounds.size.width, bounds.size.height), contextImage);
		maskImage = CGBitmapContextCreateImage(maskContext);
		data = [NSData dataWithBytes:bitmapData length:bytesPerRow * round(effectBounds.size.height)];
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
		free(bitmapData);

		CGContextRestoreGState(context);
	}
	CGImageRelease(contextImage);
	
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
	//[shadowBuffer release];
}

@end
