//
//	PartisanScaleView.m
//	
//  TexLege
//
//  Created by Gregory Combs on 8/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "PartisanScaleView.h"
#import "TexLegeTheme.h"

const CGFloat kPartisanScaleViewWidth = 172.0f;
const CGFloat kPartisanScaleViewHeight = 32.0f;

@implementation PartisanScaleView
@synthesize  questionImage;
@synthesize sliderValue, sliderMin, sliderMax;
@synthesize highlighted, showUnknown;


- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		sliderValue = 0.0f;
		sliderMin = -1.5f;
		sliderMax = 1.5f;
		questionImage = nil;
		showUnknown = NO;
		
		[self setOpaque:NO];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		sliderValue = 0.0f;
		sliderMin = -1.5f;
		sliderMax = 1.5f;
		questionImage = nil;
		showUnknown = NO;
		
		[self setOpaque:NO];
	}
	return self;
}

- (void) awakeFromNib {
	[super awakeFromNib];

	sliderValue = 0.0f;
	sliderMin = -1.5f;
	sliderMax = 1.5f;
	questionImage = nil;
	showUnknown = NO;
	
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return CGSizeMake(kPartisanScaleViewWidth, kPartisanScaleViewHeight);
}

- (void)setSliderValue:(CGFloat)value
{
	sliderValue = value;
	
	if (sliderValue < sliderMin) // lets say -1.5
		sliderValue = sliderMin;
	if (sliderValue > sliderMax) // let's say +1.5
		sliderValue = sliderMax;
	
	if (sliderValue == 0.0f) {	// this gives us the center, in cases of no roll call scores
		sliderValue = (sliderMin + sliderMin)/2;
		self.showUnknown = YES;
	}
	else
		self.showUnknown = NO;
	
#define	kStarAtDemoc 0.5f
#define kStarAtRepub 144.5f
#define	kStarAtHalf 72.5f
#define kStarMagnifierBase (kStarAtRepub - kStarAtDemoc)
	
	CGFloat magicNumber = (kStarMagnifierBase / (sliderMax - sliderMin));
	CGFloat offset = kStarAtHalf;
	sliderValue = sliderValue * magicNumber + offset;

	[self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)flag
{
	if (highlighted == flag)
		return;
	highlighted = flag;
	[self setNeedsDisplay];
	
}

- (void)drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, kPartisanScaleViewWidth, kPartisanScaleViewHeight);
	CGRect bounds = [self bounds];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat alignStroke;
	CGFloat resolution;
	CGMutablePathRef path;
	CGRect drawRect;
	CGGradientRef gradient;
	NSMutableArray *colors;
	UIColor *color;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGPoint point;
	CGPoint point2;
	CGFloat stroke;
	CGFloat locations[3];
	resolution = 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// GradientBar
	
	alignStroke = 0.0f;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(11.0f, 11.0f, 150.0f, 13.0f);
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
	color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
	[colors addObject:(id)[color CGColor]];
	locations[2] = 0.501f;
	gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	point = CGPointMake(29.208f, 17.0f);
	point2 = CGPointMake(144.526f, 17.0f);
	CGContextDrawLinearGradient(context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
	CGContextRestoreGState(context);
	CGGradientRelease(gradient);
	if (self.highlighted)
		color = [UIColor whiteColor];
	else 
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
	
	if (self.showUnknown) {
		if (!self.questionImage) {
			NSString *imageString = /*(self.usesSmallStar) ? @"Slider_Question.png" :*/ @"Slider_Question_big.png";
			self.questionImage = [UIImage imageNamed:imageString];
		}
		drawRect = CGRectMake(68.f, 0.f, 35.f, 32.f);
		[self.questionImage drawInRect:drawRect blendMode:kCGBlendModeNormal alpha:0.6];
	}
	else 
	{
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
		CGFloat starCenter = self.sliderValue;  // lets start at 86.5
		
		stroke /= resolution;
		alignStroke = fmodf(0.5f * stroke * resolution, 1.0f);
		path = CGPathCreateMutable();
		point = CGPointMake(starCenter+5.157f, 28.0f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathMoveToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+13.5f, 21.71f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+21.843f, 28.0f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+18.732f, 17.713f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+27.0f, 11.313f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+16.734f, 11.245f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+13.5f, 1.0f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+10.266f, 11.245f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+0.0f, 11.313f);				// top dead center
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+8.268f, 17.713f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+5.157f, 28.0f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		CGPathCloseSubpath(path);
		colors = [NSMutableArray arrayWithCapacity:2];
		color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
		[colors addObject:(id)[color CGColor]];
		locations[0] = 0.0f;
		color = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f];
		[colors addObject:(id)[color CGColor]];
		locations[1] = 1.0f;
		gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, locations);
		CGContextAddPath(context, path);
		CGContextSaveGState(context);
		CGContextEOClip(context);
		point = CGPointMake(starCenter+14.0f, 11.5f);
		point2 = CGPointMake(starCenter+9.5f, 21.5f);
		CGContextDrawLinearGradient(context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
		CGContextRestoreGState(context);
		CGGradientRelease(gradient);
		if (self.highlighted)
			color = [UIColor whiteColor];
		else 
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
	}
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
}

@end
