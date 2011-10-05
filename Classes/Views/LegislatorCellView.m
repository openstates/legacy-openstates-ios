//
//	LegislatorCellView.m
//  Created by Gregory Combs on 7/12/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFDataModels.h"
#import "LegislatorCellView.h"
#import "SLFTheme.h"

@implementation LegislatorCellView

@synthesize title;
@synthesize name;
@synthesize party;
@synthesize district;
@synthesize role;
@synthesize highlighted;
@synthesize useDarkBackground;

- (void)configureDefaults {
    title = [[NSString alloc] init];
    name = [[NSString alloc] init];
    party = [[NSString alloc] init];
    district = [[NSString alloc] init];
    role = nil;
    self.backgroundColor = [SLFAppearance cellBackgroundLightColor];
    [self setOpaque:YES];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
        [self configureDefaults];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
        [self configureDefaults];
	}
	return self;
}

- (void)dealloc
{
	nice_release(title);
	nice_release(name);
	nice_release(party);
	nice_release(district);
	nice_release(role);

	[super dealloc];
}

- (CGSize)cellSize {
    return CGSizeMake(234, 73);
}

- (void)setUseDarkBackground:(BOOL)flag
{
	if (self.highlighted)
		return;
	useDarkBackground = flag;
	self.backgroundColor =  flag ? [SLFAppearance cellBackgroundDarkColor] : [SLFAppearance cellBackgroundLightColor];
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

- (void)setLegislator:(SLFLegislator *)value {	
	if (value) {
		self.title = value.title;
		self.district = [NSString stringWithFormat:@"%@ %@ %@",
                         [value.stateID uppercaseString],
                         NSLocalizedString(@"District", @""),
						 value.district];
		self.party = value.party;
		self.name = value.fullName;
		self.role = nil;
	}
	[self setNeedsDisplay];	
}

- (void)setRole:(NSString *)value {
	nice_release(role);
	if (value)
		role = [value copy];
	[self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return [self cellSize];
}

- (CGRect)scaleRect:(CGRect)inRect resolution:(CGFloat)resolution {
	CGRect outRect;
	outRect.origin.x = roundf(resolution * inRect.origin.x) / resolution;
	outRect.origin.y = roundf(resolution * inRect.origin.y) / resolution;
	outRect.size.width = roundf(resolution * inRect.size.width) / resolution;
	outRect.size.height = roundf(resolution * inRect.size.height) / resolution;
	return outRect;
}

- (void)drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, self.cellSize.width, self.cellSize.height);
	CGRect aBounds = [self bounds];
	CGRect drawRect;
	
	CGFloat fontSize = 13.f;
    UIFont *font = [[SLFAppearance boldFifteen] fontWithSize:fontSize];
		
	UIColor *darkColor = nil;
	UIColor *lightColor = nil;
	UIColor *partyColor = nil;
	UIColor *accentColor = nil;
	
	// Choose font color based on highlighted state.
	if (self.highlighted) {
		darkColor = lightColor = partyColor = accentColor = [UIColor whiteColor];
	}
	else {
		darkColor = [SLFAppearance cellTextColor];
		lightColor = [SLFAppearance cellSecondaryTextColor];
        accentColor = [SLFAppearance tableSectionColor];

		if ([party isEqualToString:@"Republican"])
			partyColor = [SLFAppearance partyRed];
		else if ([party isEqualToString:@"Democrat"])
			partyColor = [SLFAppearance partyBlue];
		else
			partyColor = [SLFAppearance partyGreen];
	}
	
	CGFloat resolution = 0.5f * (aBounds.size.width / imageBounds.size.width + 
								 aBounds.size.height / imageBounds.size.height);

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, aBounds.origin.x, aBounds.origin.y);
	CGContextScaleCTM(context, (aBounds.size.width / imageBounds.size.width), 
					  (aBounds.size.height / imageBounds.size.height));
		
	// Title	
    drawRect = [self scaleRect:CGRectMake(9.f, 1.f, 94.f, 20.f) resolution:resolution];
	[lightColor set];
	[[self title] drawInRect:drawRect withFont:font];
	
	// Name
    drawRect = [self scaleRect:CGRectMake(9.f, 21.f, 218.f, 25.f) resolution:resolution];
	[darkColor set];
	[[self name] drawInRect:drawRect withFont:[font fontWithSize:fontSize+4.f]];
	
	// Party	
    drawRect = [self scaleRect:CGRectMake(9.f, 46.f, 73.f, 20.f) resolution:resolution];
	[partyColor set];
	[[self party] drawInRect:drawRect withFont:font];
		
	// District
    drawRect = [self scaleRect:CGRectMake(86.f, 46.f, 92.f, 20.f) resolution:resolution];
	[lightColor set];
	[[self district] drawInRect:drawRect withFont:font];
	
	// Role
	if (!IsEmpty(role)) {
        drawRect = [self scaleRect:CGRectMake(153, 45.f, 74.f, 20.f) resolution:resolution];
		[accentColor set];
		[[self role] drawInRect:drawRect withFont:[font fontWithSize:fontSize+1.f] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];
	}
	
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
}

@end
