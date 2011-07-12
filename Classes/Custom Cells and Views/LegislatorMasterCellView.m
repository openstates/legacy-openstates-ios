//
//	LegislatorMasterCellView.m
//  Created by Gregory Combs on 8/29/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LegislatorMasterCellView.h"
#import "LegislatorObj+RestKit.h"
#import "TexLegeTheme.h"

const CGFloat kLegislatorMasterCellViewWidth = 234.0f;
const CGFloat kLegislatorMasterCellViewHeight = 73.0f;

@implementation LegislatorMasterCellView

@synthesize title;
@synthesize name;
@synthesize tenure;
@synthesize useDarkBackground;
@synthesize highlighted;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		title = [@"Representative - (D-23)" retain];
		name = [@"Rafael Anchía" retain];
		tenure = [@"4 Years" retain];
		
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

		[self setOpaque:YES];
	}
	return self;
}

- (void) awakeFromNib {
	[super awakeFromNib];
	
	title = [@"Representative - (D-23)" retain];
	name = [@"Rafael Anchía" retain];
	tenure = [@"4 Years" retain];

	[self setOpaque:YES];
	
}

- (void)dealloc
{
	nice_release(title);
	nice_release(name);
	nice_release(tenure);
	[super dealloc];
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
	
	[self setNeedsDisplay];
}

- (void)setLegislator:(LegislatorObj *)value {
	self.title = [value.legtype_name stringByAppendingFormat:@" - %@", [value districtPartyString]];
	self.name = [value legProperName];
	self.tenure = [value tenureString];
			
	[self setNeedsDisplay];	
}

- (void)drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, kLegislatorMasterCellViewWidth, kLegislatorMasterCellViewHeight);	
	CGRect bounds = [self bounds];

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat resolution;
	CGRect drawRect;
	UIFont *font;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	
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
	
	drawRect = CGRectMake(189.5f, 52.0f, 45.5, 13.0f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	font = [TexLegeTheme boldTen];
	[tenureColor set];
	[[self tenure] drawInRect:drawRect withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
	
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
	
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
}

@end
