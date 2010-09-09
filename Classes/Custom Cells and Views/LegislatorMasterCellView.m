//
//	LegislatorMasterCellView.m
//	LegislatorMasterCellView
//
//	Created by Gregory Combs on 8/30/10
//	Copyright Like Thought, LLC. All rights reserved.
//	THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import "LegislatorMasterCellView.h"
#import "LegislatorObj.h"
#import "TexLegeTheme.h"
#import "PartisanIndexStats.h"

const CGFloat kLegislatorMasterCellViewWidth = 234.0f;
const CGFloat kLegislatorMasterCellViewHeight = 73.0f;

@implementation LegislatorMasterCellView

@synthesize title;
@synthesize name;
@synthesize tenure;
@synthesize sliderValue, sliderMin, sliderMax;
@synthesize legislator;
@synthesize useDarkBackground;
@synthesize highlighted, questionImage;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		title = [@"Representative - (D-23)" retain];
		name = [@"Rafael Anchía" retain];
		tenure = [@"4 Years" retain];
		sliderValue = 0.0f;
		sliderMin = -1.5f;
		sliderMax = 1.5f;
		questionImage = nil;
		
		[self setOpaque:YES];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		title = [@"Representative - (D-23)" retain];
		name = [@"Rafael Anchía" retain];
		tenure = [@"4 Years" retain];
		sliderValue = 0.0f;
		sliderMin = -1.5f;
		sliderMax = 1.5f;
		questionImage = nil;

		[self setOpaque:YES];
	}
	return self;
}

- (void) awakeFromNib {
	[super awakeFromNib];
	
	title = [@"Representative - (D-23)" retain];
	name = [@"Rafael Anchía" retain];
	tenure = [@"4 Years" retain];
	sliderValue = 0.0f;
	sliderMin = -1.5f;
	sliderMax = 1.5f;
	questionImage = nil;
	
	[self setOpaque:YES];
	
}

- (void)dealloc
{
	[questionImage release];
	[title release];
	[name release];
	[tenure release];
	[super dealloc];
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
	}
	
	
	/*
	 StarAtDemoc = -5.0f;
	 StarAtRepub = 168.0f;
	 StarAtHalf = 86.5f;
	 173.0 total length of gradient bar
	 */
	
	//CGFloat 
	CGFloat magicNumber = (163.0f / (sliderMax - sliderMin));
	CGFloat offset = 81.5;								//(gradientWidth / 2) + lowStarX;
	sliderValue = sliderValue * magicNumber + offset;
	
	//[self setNeedsDisplay];
}


- (CGSize)sizeThatFits:(CGSize)size
{
	return CGSizeMake(kLegislatorMasterCellViewWidth, kLegislatorMasterCellViewHeight);
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
	/*
	if (flag)
		self.backgroundColor = [TexLegeTheme accent];
	else
		self.backgroundColor = (useDarkBackground) ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	*/
	[self setNeedsDisplay];
	
}


- (void)setLegislator:(LegislatorObj *)value {
	if ([legislator isEqual:value]) {
		return;
	}
	[legislator release];
	legislator = [value retain];
		
	self.title = [self.legislator.legtype_name stringByAppendingFormat:@" - %@", [self.legislator districtPartyString]];
	self.name = [self.legislator legProperName];
	self.tenure = [self.legislator tenureString];
		
	PartisanIndexStats *indexStats = [PartisanIndexStats sharedPartisanIndexStats];
	CGFloat minSlider = [[indexStats minPartisanIndexUsingLegislator:legislator] floatValue];
	CGFloat maxSlider = [[indexStats maxPartisanIndexUsingLegislator:legislator] floatValue];
	self.sliderMax = maxSlider;
	self.sliderMin = minSlider;	
	self.sliderValue = self.legislator.partisan_index.floatValue;

	[self setNeedsDisplay];	
}


- (void)drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, kLegislatorMasterCellViewWidth, kLegislatorMasterCellViewHeight);
	
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
	CGFloat locations[3];
	
	UIColor *nameColor = nil;
	UIColor *tenureColor = nil;
	UIColor *titleColor = nil;

	// Choose font color based on highlighted state.
	if (self.highlighted) {
		nameColor = tenureColor = titleColor = [TexLegeTheme backgroundLight];
	}
	else {
		nameColor = [TexLegeTheme textDark];
		tenureColor = [TexLegeTheme textLight];
		titleColor = [TexLegeTheme accent];
	}
	
	
	resolution = 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));

	// Tenure
	
	drawRect = CGRectMake(187.0f, 51.0f, 61.5f, 15.0f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	font = [TexLegeTheme boldTen];
	[tenureColor set];
	[[self tenure] drawInRect:drawRect withFont:font];
	
	// Title
	
	drawRect = CGRectMake(8.5f, 0.0f, 240.0f, 18.0f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	font = [TexLegeTheme boldTwelve];
	[titleColor set];
	[[self title] drawInRect:drawRect withFont:font];
	
	// Name
	
	drawRect = CGRectMake(8.5f, 17.0f, 240.0f, 21.0f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	font = [TexLegeTheme boldFifteen];
	[nameColor set];
	[[self name] drawInRect:drawRect withFont:font];
	
	// GradientBar
	
	alignStroke = 0.0f;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(8.5f, 53.0f, 173.0f, 13.0f);
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
	locations[2] = 0.499f;
	gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	point = CGPointMake(29.5f, 59.0f);
	point2 = CGPointMake(162.5f, 59.0f);
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
	
	
	if (self.legislator.partisan_index.floatValue == 0.0f) {
		if (!self.questionImage) {
			NSString *imageString = /*(self.usesSmallStar) ? @"Slider_Question.png" :*/ @"Slider_Question_big.png";
			self.questionImage = [UIImage imageNamed:imageString];
		}
		drawRect = CGRectMake(81.f, 41.f, 35.f, 32.f);
		[self.questionImage drawInRect:drawRect blendMode:kCGBlendModeNormal alpha:0.6];
	}
	else {
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
		point = CGPointMake(starCenter+5.157f, 68.5f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathMoveToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+13.5f, 62.126f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+21.843f, 68.5f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+18.657f, 58.187f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+27.0f, 51.813f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+16.687f, 51.813f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+13.5f, 41.5f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+10.313f, 51.813f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter, 51.813f);													/// top dead center
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+8.343f, 58.187f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+5.157f, 68.5f);
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
		point = CGPointMake(starCenter+14.0f, 52.0f);
		point2 = CGPointMake(starCenter+9.5f, 62.0f);
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
