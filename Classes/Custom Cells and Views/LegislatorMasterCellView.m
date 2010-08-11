//
//	LegislatorMasterCellView.m
//	New Image
//
//	Created by Gregory Combs on 8/9/10
//	Copyright Like Thought, LLC. All rights reserved.
//	THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import "LegislatorMasterCellView.h"
#import "TexLegeTheme.h"
#import "LegislatorObj.h"

const CGFloat kLegislatorCellViewWidth = 320.0f;
const CGFloat kLegislatorCellViewHeight = 73.0f;

@implementation MyView

@synthesize legislator;
@synthesize photo;
@synthesize title;
@synthesize name;
@synthesize tenure;
@synthesize sliderValue;
@synthesize useDarkBackground;
@synthesize highlighted;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.title = @"Representative - (D-23)";
		self.name = @"Rafael Anchía";
		self.tenure = @"4 Years";
		self.sliderValue = -0.871f;
		[self setOpaque:YES];
		highlighted = NO;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		self.title = @"Representative - (D-23)";
		self.name = @"Rafael Anchía";
		self.tenure = @"4 Years";
		self.sliderValue = -0.871f;
		[self setOpaque:YES];
		highlighted = NO;
	}
	return self;
}

- (void)dealloc
{
	self.title = self.name = self.tenure = nil;
	self.legislator = nil;
	self.photo = nil;
	[super dealloc];
}

- (BOOL)useDarkBackground {
	return useDarkBackground;
}

- (void)setUseDarkBackground:(BOOL)flag
{
	if (self.highlighted)
		return;
	
	useDarkBackground = flag;
	
	UIColor *labelBGColor = (useDarkBackground) ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	self.backgroundColor = labelBGColor;
	[self setNeedsDisplay];
}

- (BOOL)highlighted{
	return highlighted;
}

- (void)setHighlighted:(BOOL)flag
{
	if (highlighted == flag)
		return;
	
	highlighted = flag;
	
	if (flag)
		self.backgroundColor = [TexLegeTheme accent];
	else
		self.backgroundColor = (useDarkBackground) ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	
	[self setNeedsDisplay];
	
}


- (void)setLegislator:(LegislatorObj *)value {
	if ([legislator isEqual:value]) {
		return;
	}
	[legislator release];
	legislator = [value retain];
	
	self.photo = [UIImage imageNamed:self.legislator.photo_name];	
	
	self.title = [self.legislator.legtype_name stringByAppendingFormat:@" - %@", [self.legislator districtPartyString]];
	self.name = [self.legislator legProperName];
	self.tenure = [self.legislator tenureString];
	
	self.sliderValue = self.legislator.partisan_index.floatValue;
	
	
	[self setNeedsDisplay];	
}


- (void)setName:(NSString *)value
{
	if ([name isEqualToString:value]) {
		return;
	}
	[name release];
	name = [value copy];
	[self setNeedsDisplay];
}


- (void)setSliderValue:(CGFloat)value
{
	sliderValue = value;
	[self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return CGSizeMake(kLegislatorCellViewWidth, kLegislatorCellViewHeight);
}

- (void)drawRect:(CGRect)dirtyRect
{
	
	// Color and font for the main text items (time zone name, time)
	UIColor *nameColor = nil;
	UIColor *tenureColor = nil;
	UIColor *titleColor = nil;
	UIColor *disclosureColor = nil;

	
	// Choose font color based on highlighted state.
	if (self.highlighted) {
		nameColor = tenureColor = titleColor = [TexLegeTheme backgroundLight];
		disclosureColor = [TexLegeTheme navbutton];
	}
	else {
		nameColor = [TexLegeTheme textDark];
		tenureColor = [TexLegeTheme textLight];
		titleColor = disclosureColor = [TexLegeTheme accent];
	}
	
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, kLegislatorCellViewWidth, kLegislatorCellViewHeight);
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
	resolution = 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Background
/*	
	alignStroke = 0.0f;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(0.0f, 0.0f, 320.0f, 73.0f);
	drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	CGPathAddRect(path, NULL, drawRect);
	[[self background] setFill];
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	CGPathRelease(path);
*/	
	// Photo
	
	CGContextSetShouldAntialias(context, NO);
	drawRect = CGRectMake(0.f, 0.f, 53.f, 74.f);
	//UIImage *photo = [UIImage imageNamed:@"anchia.png"];
	[self.photo drawInRect:drawRect];
	
	// Tenure
	
	CGContextSetShouldAntialias(context, YES);
	drawRect = CGRectMake(240.0f, 51.0f, 60.0f, 15.0f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	font = [TexLegeTheme boldTen];
	[tenureColor set];
	[self.tenure drawInRect:drawRect withFont:font];
	
	// Title
	
	drawRect = CGRectMake(60.0f, 0.0f, 240.0f, 18.0f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	font = [TexLegeTheme boldTwelve];
	[titleColor set];
	[self.title drawInRect:drawRect withFont:font];
	
	// Name
	
	drawRect = CGRectMake(60.0f, 17.0f, 240.0f, 21.0f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	font = [TexLegeTheme boldFifteen];
	[nameColor set];
	[self.name drawInRect:drawRect withFont:font];
	
	// GradientBar
	
	alignStroke = 0.0f;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(60.0f, 53.0f, 173.0f, 13.0f);
	drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	CGPathAddRect(path, NULL, drawRect);
	colors = [NSMutableArray arrayWithCapacity:3];
	[colors addObject:(id)[[TexLegeTheme texasBlue] CGColor]];
	locations[0] = 0.0f;
	[colors addObject:(id)[[TexLegeTheme texasRed] CGColor]];
	locations[1] = 1.0f;
	color = [UIColor whiteColor];
	[colors addObject:(id)[color CGColor]];
	locations[2] = 0.499f;
	gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	point = CGPointMake(81.0f, 59.0f);
	point2 = CGPointMake(214.0f, 59.0f);
	CGContextDrawLinearGradient(context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
	CGContextRestoreGState(context);
	CGGradientRelease(gradient);
	color = [UIColor blackColor];
	[color setStroke];
	stroke = 1.0f;
	stroke *= resolution;
	if (stroke < 1.0f) {
		stroke = ceilf(stroke);
	} else {
		stroke = roundf(stroke);
	}
	stroke /= resolution;
	stroke *= 2.0f;
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
	color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, CGSizeMake(0.724f * resolution, 2.703f * resolution), 1.679f * resolution, [color CGColor]);
	CGContextBeginTransparencyLayer(context, NULL);
	
	// Star
	
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
	point = CGPointMake(71.657f, 68.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(80.0f, 62.126f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(88.343f, 68.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(85.157f, 58.187f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(93.5f, 51.813f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(83.187f, 51.813f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(80.0f, 41.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(76.813f, 51.813f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(66.5f, 51.813f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(74.843f, 58.187f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(71.657f, 68.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	CGPathCloseSubpath(path);
	colors = [NSMutableArray arrayWithCapacity:2];
	color = [UIColor whiteColor];
	[colors addObject:(id)[color CGColor]];
	locations[0] = 0.0f;
	color = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f];
	[colors addObject:(id)[color CGColor]];
	locations[1] = 1.0f;
	gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	point = CGPointMake(80.5f, 52.0f);
	point2 = CGPointMake(76.0f, 62.0f);
	CGContextDrawLinearGradient(context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
	CGContextRestoreGState(context);
	CGGradientRelease(gradient);
	color = [UIColor blackColor];
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
	bytesPerRow = 4 * roundf(bounds.size.width);

	NSMutableData *disclosureBuffer = [NSMutableData dataWithCapacity:(bytesPerRow * roundf(bounds.size.height) * roundf(bounds.size.width))];

	context = CGBitmapContextCreate([disclosureBuffer mutableBytes], roundf(bounds.size.width), roundf(bounds.size.height), 8, bytesPerRow, space, kCGImageAlphaPremultipliedLast);
	UIGraphicsPushContext(context);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Disclosure
	
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
	drawRect = CGRectMake(259.5f, 18.0f, 30.0f, 30.0f);
	drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	CGPathAddEllipseInRect(path, NULL, drawRect);
	color = [UIColor whiteColor];
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
	
	drawRect = CGRectMake(261.0f, 18.0f, 30.0f, 30.0f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	string = [TexLegeTheme disclosureChar];
	font = [TexLegeTheme disclosureFont];
	color = disclosureColor;
	[color set];
	[string drawInRect:drawRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	
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
			if (pixels && pixels[4 * (width * row + column) + 3] > 0) {
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
		effectBounds = CGRectInset(effectBounds, -(ABS(3.172f * cosf(1.571f) * resolution) + 4.291f), -(ABS(3.172f * sinf(1.571f) * resolution) + 4.291f));
		effectBounds = CGRectIntegral(effectBounds);
		color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
		CGContextSetShadowWithColor(context, CGSizeMake(3.172f * cosf(1.571f) * resolution, 3.172f * sinf(1.571f) * resolution - effectBounds.size.height), 4.291f, [color CGColor]);
		bytesPerRow = roundf(effectBounds.size.width);
		
		//NSMutableData *maskBuffer = [NSMutableData dataWithCapacity:(bytesPerRow * roundf(effectBounds.size.height) * roundf(effectBounds.size.width))];
		[disclosureBuffer setLength:(bytesPerRow * roundf(effectBounds.size.height) * roundf(effectBounds.size.width))];
		maskContext = CGBitmapContextCreate([disclosureBuffer mutableBytes], roundf(effectBounds.size.width), roundf(effectBounds.size.height), 8, bytesPerRow, NULL, kCGImageAlphaOnly);
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
	
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
	
}

@end
