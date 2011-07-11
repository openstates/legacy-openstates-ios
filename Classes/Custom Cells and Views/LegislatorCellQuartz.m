//
//	LegislatorMasterTableViewCell.m
//  Created by Gregory Combs on 8/29/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LegislatorCellQuartz.h"

const CGFloat kLegislatorTableViewCellWidth = 320.0;
const CGFloat kLegislatorTableViewCellHeight = 73.0;

@implementation LegislatorCellQuartz

@synthesize title;
@synthesize name;
@synthesize background;
@synthesize textDark;
@synthesize textLight;
@synthesize accent;
@synthesize tenure;
@synthesize texasRed;
@synthesize texasBlue;
@synthesize sliderValue;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		title = [@"Representative - (D-23)" retain];
		name = [@"Rafael Anchía" retain];
		background = [[UIColor colorWithRed:0.855 green:0.875 blue:0.867 alpha:1.0] retain];
		textDark = [[UIColor colorWithRed:0.263 green:0.337 blue:0.384 alpha:1.0] retain];
		textLight = [[UIColor colorWithRed:0.592 green:0.631 blue:0.651 alpha:1.0] retain];
		accent = [[UIColor colorWithRed:0.6 green:0.745 blue:0.353 alpha:1.0] retain];
		tenure = [@"4 Years" retain];
		texasRed = [[UIColor colorWithRed:0.626 green:0.125 blue:0.153 alpha:1.0] retain];
		texasBlue = [[UIColor colorWithRed:0.196 green:0.31 blue:0.522 alpha:1.0] retain];
		sliderValue = 6.871;
		[self setOpaque:NO];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		title = [@"Representative - (D-23)" retain];
		name = [@"Rafael Anchía" retain];
		background = [[UIColor colorWithRed:0.855 green:0.875 blue:0.867 alpha:1.0] retain];
		textDark = [[UIColor colorWithRed:0.263 green:0.337 blue:0.384 alpha:1.0] retain];
		textLight = [[UIColor colorWithRed:0.592 green:0.631 blue:0.651 alpha:1.0] retain];
		accent = [[UIColor colorWithRed:0.6 green:0.745 blue:0.353 alpha:1.0] retain];
		tenure = [@"4 Years" retain];
		texasRed = [[UIColor colorWithRed:0.626 green:0.125 blue:0.153 alpha:1.0] retain];
		texasBlue = [[UIColor colorWithRed:0.196 green:0.31 blue:0.522 alpha:1.0] retain];
		sliderValue = 6.871;
		[self setOpaque:NO];
	}
	return self;
}

- (void)dealloc
{
	[title release];
	[name release];
	[background release];
	[textDark release];
	[textLight release];
	[accent release];
	[tenure release];
	[texasRed release];
	[texasBlue release];
	[super dealloc];
}

- (void)setTitle:(NSString *)value
{
	if ([title isEqualToString:value])
		return;
	[title release];
	title = [value copy];
	[self setNeedsDisplay];
}

- (void)setName:(NSString *)value
{
	if ([name isEqualToString:value])
		return;
	[name release];
	name = [value copy];
	[self setNeedsDisplay];
}

- (void)setBackground:(UIColor *)value
{
	if ([background isEqual:value])
		return;
	[background release];
	background = [value retain];
	[self setNeedsDisplay];
}

- (void)setTextDark:(UIColor *)value
{
	if ([textDark isEqual:value])
		return;
	[textDark release];
	textDark = [value retain];
	[self setNeedsDisplay];
}

- (void)setTextLight:(UIColor *)value
{
	if ([textLight isEqual:value])
		return;
	[textLight release];
	textLight = [value retain];
	[self setNeedsDisplay];
}

- (void)setAccent:(UIColor *)value
{
	if ([accent isEqual:value])
		return;
	[accent release];
	accent = [value retain];
	[self setNeedsDisplay];
}

- (void)setTenure:(NSString *)value
{
	if ([tenure isEqualToString:value])
		return;
	[tenure release];
	tenure = [value copy];
	[self setNeedsDisplay];
}

- (void)setTexasRed:(UIColor *)value
{
	if ([texasRed isEqual:value])
		return;
	[texasRed release];
	texasRed = [value retain];
	[self setNeedsDisplay];
}

- (void)setTexasBlue:(UIColor *)value
{
	if ([texasBlue isEqual:value])
		return;
	[texasBlue release];
	texasBlue = [value retain];
	[self setNeedsDisplay];
}

- (void)setSliderValue:(CGFloat)value
{
	sliderValue = value;
	[self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return CGSizeMake(kLegislatorTableViewCellWidth, kLegislatorTableViewCellHeight);
}

- (void)drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0, 0.0, kLegislatorTableViewCellWidth, kLegislatorTableViewCellHeight);
	CGRect bounds = [self bounds];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat alignStroke;
	CGFloat resolution;
	CGMutablePathRef path;
	CGRect drawRect;
	UIFont *font;
	CGGradientRef gradient;
	NSMutableArray *colors;
	UIColor *color;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGPoint point;
	CGPoint point2;
	CGFloat stroke;
	size_t bytesPerRow;
	void *bitmapData;
	NSString *string;
	CGImageRef contextImage;
	CGRect effectBounds;
	unsigned char *pixels;
	CGFloat minX, maxX, minY, maxY;
	NSUInteger width, height;
	CGContextRef maskContext;
	CGImageRef maskImage;
	CGDataProviderRef provider;
	NSData *data;
	CGFloat locations[3];
	resolution = 0.5 * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Background
	
	alignStroke = 0.0;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(0.0, 0.0, 320.0, 73.0);
	drawRect.origin.x = (round(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (round(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	CGPathAddRect(path, NULL, drawRect);
	[[self background] setFill];
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	CGPathRelease(path);
	
	// Photo
	
	CGContextSetShouldAntialias(context, NO);
	
	// Tenure
	
	CGContextSetShouldAntialias(context, YES);
	drawRect = CGRectMake(240.0, 51.0, 60.0, 15.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0];
	[[self textLight] set];
	[[self tenure] drawInRect:drawRect withFont:font];
	
	// Title
	
	drawRect = CGRectMake(60.0, 0.0, 240.0, 18.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
	[[self accent] set];
	[[self title] drawInRect:drawRect withFont:font];
	
	// Name
	
	drawRect = CGRectMake(60.0, 19.0, 240.0, 21.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
	[[self textDark] set];
	[[self name] drawInRect:drawRect withFont:font];
	
	// GradientBar
	
	alignStroke = 0.0;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(60.0, 53.0, 173.0, 13.0);
	drawRect.origin.x = (round(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (round(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	CGPathAddRect(path, NULL, drawRect);
	colors = [NSMutableArray arrayWithCapacity:3];
	[colors addObject:(id)[[self texasBlue] CGColor]];
	locations[0] = 0.0;
	[colors addObject:(id)[[self texasRed] CGColor]];
	locations[1] = 1.0;
	color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[2] = 0.499;
	gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	point = CGPointMake(81.0, 59.0);
	point2 = CGPointMake(214.0, 59.0);
	CGContextDrawLinearGradient(context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
	CGContextRestoreGState(context);
	CGGradientRelease(gradient);
	color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	[color setStroke];
	stroke = 1.0;
	stroke *= resolution;
	if (stroke < 1.0)
		stroke = ceil(stroke);
	else
		stroke = round(stroke);
	stroke /= resolution;
	stroke *= 2.0;
	CGContextSetLineWidth(context, stroke);
	CGContextSaveGState(context);
	CGContextAddPath(context, path);
	CGContextEOClip(context);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGContextRestoreGState(context);
	CGPathRelease(path);
	
	// StarGroup
	
	// Setup for Shadow Effect
	color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, CGSizeMake(3.697 * cos(-1.309) * resolution, 3.697 * sin(-1.309) * resolution), 1.232 * resolution, [color CGColor]);
	CGContextBeginTransparencyLayer(context, NULL);
	
	// Star
	
	stroke = 1.0;
	stroke *= resolution;
	if (stroke < 1.0)
		stroke = ceil(stroke);
	else
		stroke = round(stroke);
	stroke /= resolution;
	alignStroke = fmod(0.5 * stroke * resolution, 1.0);
	path = CGPathCreateMutable();
	point = CGPointMake(71.657, 68.5);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(80.0, 62.126);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(88.343, 68.5);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(85.157, 58.187);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(93.5, 51.813);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(83.187, 51.813);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(80.0, 41.5);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(76.813, 51.813);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(66.5, 51.813);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(74.843, 58.187);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(71.657, 68.5);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	CGPathCloseSubpath(path);
	colors = [NSMutableArray arrayWithCapacity:2];
	color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[0] = 0.0;
	color = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[1] = 1.0;
	gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	point = CGPointMake(80.5, 52.0);
	point2 = CGPointMake(76.0, 62.0);
	CGContextDrawLinearGradient(context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
	CGContextRestoreGState(context);
	CGGradientRelease(gradient);
	color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	[color setStroke];
	CGContextSetLineWidth(context, stroke);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);
	
	// Shadow Effect
	CGContextEndTransparencyLayer(context);
	CGContextRestoreGState(context);
	
	// DisclosureGroup
	
	// Setup for Inner Shadow Effect
	bytesPerRow = 4 * round(bounds.size.width);
	bitmapData = calloc(bytesPerRow * round(bounds.size.height), 8);
	context = CGBitmapContextCreate(bitmapData, round(bounds.size.width), round(bounds.size.height), 8, bytesPerRow, space, kCGImageAlphaPremultipliedLast);
	UIGraphicsPushContext(context);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Disclosure
	
	stroke = 1.0;
	stroke *= resolution;
	if (stroke < 1.0)
		stroke = ceil(stroke);
	else
		stroke = round(stroke);
	stroke /= resolution;
	alignStroke = fmod(0.5 * stroke * resolution, 1.0);
	path = CGPathCreateMutable();
	drawRect = CGRectMake(269.5, 22.5, 30.0, 30.0);
	drawRect.origin.x = (round(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (round(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	CGPathAddEllipseInRect(path, NULL, drawRect);
	color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	[color setFill];
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	color = [UIColor colorWithRed:0.814 green:0.821 blue:0.843 alpha:1.0];
	[color setStroke];
	CGContextSetLineWidth(context, stroke);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);
	
	drawRect = CGRectMake(271.0, 18.0, 30.0, 30.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	string = @">";
	font = [UIFont fontWithName:@"HiraKakuProN-W6" size:28.0];
	color = [UIColor colorWithRed:0.6 green:0.745 blue:0.353 alpha:1.0];
	[color set];
	[string drawInRect:drawRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	
	// Inner Shadow Effect
	bitmapData = CGBitmapContextGetData(context);
	pixels = (unsigned char *)bitmapData;
	width = round(bounds.size.width);
	height = round(bounds.size.height);
	minX = width;
	maxX = -1.0;
	minY = height;
	maxY = -1.0;
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
		effectBounds = CGRectMake(minX, minY - 1.0, maxX - minX + 1.0, maxY - minY + 1.0);
		effectBounds = CGRectInset(effectBounds, -(ABS(3.0 * cos(-1.571)) + 3.0), -(ABS(3.0 * sin(-1.571)) + 3.0));
		effectBounds = CGRectIntegral(effectBounds);
		color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
		CGContextSetShadowWithColor(context, CGSizeMake(3.0 * cos(-1.571) * resolution, 3.0 * sin(-1.571) * resolution + effectBounds.size.height), 3.0, [color CGColor]);
		bytesPerRow = round(effectBounds.size.width);
		bitmapData = calloc(bytesPerRow * round(effectBounds.size.height), 8);
		maskContext = CGBitmapContextCreate(bitmapData, round(effectBounds.size.width), round(effectBounds.size.height), 8, bytesPerRow, NULL, kCGImageAlphaOnly);
		CGContextDrawImage(maskContext, CGRectMake(-effectBounds.origin.x, -effectBounds.origin.y, bounds.size.width, bounds.size.height), contextImage);
		maskImage = CGBitmapContextCreateImage(maskContext);
		data = [NSData dataWithBytes:bitmapData length:bytesPerRow * round(effectBounds.size.height)];
		provider = CGDataProviderCreateWithCFData((CFDataRef)data);
		CGImageRelease(contextImage);
		contextImage = CGImageMaskCreate(round(effectBounds.size.width), round(effectBounds.size.height), 8, 8, bytesPerRow, provider, NULL, 0);
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
}

@end
