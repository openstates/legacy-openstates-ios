//
//	CommitteeMemberCellView.m
//
//	Created by Gregory Combs on 9/10/10
//	Copyright Like Thought, LLC. All rights reserved.
//	THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import "CommitteeMemberCellView.h"
#import "LegislatorObj.h"
#import "TexLegeTheme.h"
#import "PartisanIndexStats.h"
#import "TexLegeCoreDataUtils.h"
#import "UtilityMethods.h"

const CGFloat kCommitteeMemberCellViewWidth = 531.0f;
const CGFloat kCommitteeMemberCellViewHeight = 73.0f;

@implementation CommitteeMemberCellView

@synthesize legislator;
@synthesize title, name, tenure, party, rank, district;
@synthesize highlighted, questionImage;
@synthesize sliderValue, sliderMin, sliderMax;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		title = [@"Rep." retain];
		name = [@"Warren Chisum" retain];
		tenure = [@"4 Years" retain];
		party = [@"Republican" retain];
		rank = [@"3rd most partisan (out of 76 Repubs)" retain];
		district = [@"District 21" retain];
		sliderValue = 0.0f;
		sliderMin = -1.5f;
		sliderMax = 1.5f;
		questionImage = nil;
//		[self setOpaque:NO];
		[self setOpaque:YES];
		self.backgroundColor = [TexLegeTheme backgroundLight];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		title = [@"Rep." retain];
		name = [@"Warren Chisum" retain];
		tenure = [@"4 Years" retain];
		party = [@"Republican" retain];
		rank = [@"3rd most partisan (out of 76 Repubs)" retain];
		district = [@"District 21" retain];
		sliderValue = 0.0f;
		sliderMin = -1.5f;
		sliderMax = 1.5f;
		questionImage = nil;
//		[self setOpaque:NO];
		[self setOpaque:YES];
		self.backgroundColor = [TexLegeTheme backgroundLight];
	}
	return self;
}

- (void) awakeFromNib {
	[super awakeFromNib];
	title = [@"Rep." retain];
	name = [@"Warren Chisum" retain];
	tenure = [@"4 Years" retain];
	party = [@"Republican" retain];
	rank = [@"3rd most partisan (out of 76 Repubs)" retain];
	district = [@"District 21" retain];
	sliderValue = 0.0f;
	sliderMin = -1.5f;
	sliderMax = 1.5f;
	questionImage = nil;
//	[self setOpaque:NO];
	[self setOpaque:YES];
	self.backgroundColor = [TexLegeTheme backgroundLight];
}

- (void)dealloc
{
	[title release];
	[name release];
	[tenure release];
	[party release];
	[rank release];
	[district release];
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
	
	
#define	kStarAtDemoc 270.5f
#define kStarAtRepub 478.5f
#define	kStarAtHalf 374.5f
#define kStarMagnifierBase (kStarAtRepub - kStarAtDemoc)
	
#ifdef JUSTTESTINGHERE
	sliderValue = [legislator.party_id integerValue] == DEMOCRAT ? 0 : +1.5;
	sliderMin = -1.5;
	sliderMax = +1.5;
#endif
	
	//the magnifier ... multiplies our -1.05 type score into the number of pixels to shift
	CGFloat magicNumber = (kStarMagnifierBase / (sliderMax - sliderMin));	
	
	// the static offset ... where the "center" of our gradient in the view,
	//		it's not the REAL center of the gradient, because we're going off the left boundary of the star.
	CGFloat offset = kStarAtHalf;										
	
	sliderValue = sliderValue * magicNumber + offset;
	
	//[self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return CGSizeMake(kCommitteeMemberCellViewWidth, kCommitteeMemberCellViewHeight);
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

- (NSString *) partisanRankStringForLegislator {
	
	//self.rank = @"3rd most partisan (out of 76 Repubs)";

	NSArray *legislators = [TexLegeCoreDataUtils allLegislatorsSortedByPartisanshipFromChamber:[legislator.legtype integerValue] 
																		   andPartyID:[legislator.party_id integerValue] 
																			  context:self.legislator.managedObjectContext];
	if (legislators) {
		NSInteger rankIndex = [legislators indexOfObject:self.legislator] + 1;
		NSInteger count = [legislators count];
		NSString *partyShortName = [self.legislator.party_id integerValue] == DEMOCRAT ? @"Dems" : @"Repubs";
		
		NSString *ordinalRank = [UtilityMethods ordinalNumberFormat:rankIndex];
		return [NSString stringWithFormat:@"%@ most partisan (out of %d %@)", ordinalRank, count, partyShortName];	
	}
	else {
		return nil;
	}
}

- (void)setLegislator:(LegislatorObj *)value {
	if ([legislator isEqual:value]) {
		return;
	}
	if (legislator)
		[legislator release], legislator=nil;
	
	if (value) {
		legislator = [value retain];

		self.title = [self.legislator legTypeShortName];
		self.district = [NSString stringWithFormat:@"District %@", legislator.district];
		self.party = self.legislator.party_name;
		self.name = [self.legislator legProperName];
		self.tenure = [self.legislator tenureString];
		
		PartisanIndexStats *indexStats = [PartisanIndexStats sharedPartisanIndexStats];
		CGFloat minSlider = [[indexStats minPartisanIndexUsingLegislator:legislator] floatValue];
		CGFloat maxSlider = [[indexStats maxPartisanIndexUsingLegislator:legislator] floatValue];
		
		self.sliderMax = maxSlider;
		self.sliderMin = minSlider;	
		self.sliderValue = self.legislator.partisan_index.floatValue;
		
		self.rank = [self partisanRankStringForLegislator];
	}
	[self setNeedsDisplay];	
}

- (void)drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, kCommitteeMemberCellViewWidth, kCommitteeMemberCellViewHeight);
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
	resolution = 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
	
	UIColor *nameColor = nil;
	UIColor *tenureColor = nil;
	UIColor *titleColor = nil;
	UIColor *partyColor = nil;
	UIColor *rankColor = nil;
	UIColor *districtColor = nil;
	
	// Choose font color based on highlighted state.
	if (self.highlighted) {
		nameColor = tenureColor = titleColor = partyColor = rankColor = districtColor = [TexLegeTheme backgroundLight];
	}
	else {
		nameColor = [TexLegeTheme textDark];
		tenureColor = rankColor = districtColor = [TexLegeTheme textLight];
		titleColor = [TexLegeTheme accent];
		partyColor = [legislator.party_id integerValue] == REPUBLICAN ? [TexLegeTheme texasRed] : [TexLegeTheme texasBlue];
	}
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Tenure
	
	drawRect = CGRectMake(418.0f, 3.0f, 85.0f, 15.0f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0f];
	[tenureColor set];
	[[self tenure] drawInRect:drawRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];
	
	// District
	
	drawRect = CGRectMake(96.5f, 33.0f, 100.0f, 30.0f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	font = [TexLegeTheme boldFifteen];
	[districtColor set];
	[[self district] drawInRect:drawRect withFont:font];
	
	// Party
	
	drawRect = CGRectMake(8.5f, 33.0f, 88.0f, 30.0f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	font = [TexLegeTheme boldFifteen];
	[partyColor set];
	[[self party] drawInRect:drawRect withFont:font];
	
	// Rank
	
	drawRect = CGRectMake(283.0f, 56.5f, 220.0f, 15.0f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	font = [TexLegeTheme boldTen];
	[rankColor set];
	[[self rank] drawInRect:drawRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];
	
	// Title
	
	drawRect = CGRectMake(8.5f, 3.0f, 40.0f, 30.0f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
	[titleColor set];
	[[self title] drawInRect:drawRect withFont:font];
	
	// Name
	
	drawRect = CGRectMake(48.5f, 3.0f, 240.0f, 30.0f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
	[nameColor set];
	[[self name] drawInRect:drawRect withFont:font];
	
	// GradientBar
	
	alignStroke = 0.0f;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(283.0f, 31.0f, 220.0f, 17.0f);
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
	point = CGPointMake(309.705f, 38.846f);
	point2 = CGPointMake(478.838f, 38.846f);
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
		drawRect = CGRectMake(374.f, 19.5f, 36.f, 36.f);
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
		CGFloat starCenter = self.sliderValue;		//	middle is 374.5f
		
		stroke /= resolution;
		alignStroke = fmodf(0.5f * stroke * resolution, 1.0f);
		path = CGPathCreateMutable();
		point = CGPointMake(starCenter+7.066f, 55.0f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathMoveToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+18.5f, 46.38f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+29.934f, 55.0f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+25.67f, 40.903f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+37.f, 32.133f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+22.931f, 32.04f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+18.5f, 18.0f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+14.069f, 32.04f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+0.f, 32.133f);		// top dead center
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+11.33f, 40.903f);
		point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
		point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
		point = CGPointMake(starCenter+7.066f, 55.0f);
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
		point = CGPointMake(starCenter+28.007f, 35.13f);
		point2 = CGPointMake(starCenter+13.019f, 46.093f);
		CGContextDrawLinearGradient(context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
		CGContextRestoreGState(context);
		CGGradientRelease(gradient);
		color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
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
