//
//	CommitteeMemberCellView.m
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
#import "TexLegeTheme.h"
#import "UtilityMethods.h"

@implementation LegislatorCellView

@synthesize title;
@synthesize name;
@synthesize tenure;
@synthesize party;
@synthesize district;
@synthesize role;
@synthesize highlighted;
@synthesize useDarkBackground;
@synthesize wideSize;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		title = [@"Representative" retain];
		name = [@"Genevieve McGillicuddy" retain];
		tenure = [@"(Freshman)" retain];
		party = [@"Republican" retain];
		district = [@"District 21" retain];
		role = nil;
		self.backgroundColor = [TexLegeTheme backgroundLight];
		[self setOpaque:YES];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		title = [@"Representative" retain];
		name = [@"Genevieve McGillicuddy" retain];
		tenure = [@"(Freshman)" retain];
		party = [@"Republican" retain];
		district = [@"District 21" retain];
		role = nil;
		self.backgroundColor = [TexLegeTheme backgroundLight];
		[self setOpaque:YES];
	}
	return self;
}

- (void)dealloc
{
	nice_release(title);
	nice_release(name);
	nice_release(tenure);
	nice_release(party);
	nice_release(district);
	nice_release(role);

	[super dealloc];
}

- (CGSize)cellSize {
	if (wideSize)
		return CGSizeMake(531.f, 73.f);
	else
		return CGSizeMake(234.f, 73.f);
}

- (void)setUseDarkBackground:(BOOL)flag
{
	if (self.highlighted)
		return;
	
	useDarkBackground = flag;
	self.backgroundColor =  flag ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	
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
                         NSLocalizedStringFromTable(@"District", @"DataTableUI", @""),
						 value.district];
		self.party = value.party;
		self.name = value.fullName;
		self.tenure = value.term;
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
	
	CGFloat fontSize = wideSize ? 16.f : 13.f;
	UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize];
		
	UIColor *nameColor = nil;
	UIColor *titleColor = nil;
	UIColor *partyColor = nil;
	UIColor *districtColor = nil;
	
	// Choose font color based on highlighted state.
	if (self.highlighted) {
		nameColor = titleColor = partyColor = districtColor = [TexLegeTheme backgroundLight];
	}
	else {
		nameColor = [TexLegeTheme textDark];
		districtColor = [TexLegeTheme textLight];
		titleColor = [TexLegeTheme accent];
		
		if ([party isEqualToString:stringForParty(REPUBLICAN, TLReturnFull)])
			partyColor = [TexLegeTheme texasRed];
		else if ([party isEqualToString:stringForParty(DEMOCRAT, TLReturnFull)])
			partyColor = [TexLegeTheme texasBlue];
		else // INDEPENDENT ?
			partyColor = [TexLegeTheme textLight];
	}
	
	CGFloat resolution = 0.5f * (aBounds.size.width / imageBounds.size.width + 
								 aBounds.size.height / imageBounds.size.height);

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, aBounds.origin.x, aBounds.origin.y);
	CGContextScaleCTM(context, (aBounds.size.width / imageBounds.size.width), 
					  (aBounds.size.height / imageBounds.size.height));
	
	CGFloat labHeight = wideSize ? 23.f : 20.f; // 18.f
	
	// Title	
	if (wideSize) 
		drawRect = [self scaleRect:CGRectMake(9.f, 0.f, 121.f, labHeight) resolution:resolution];
	else 
		drawRect = [self scaleRect:CGRectMake(9.f, 0.f, 94.f, labHeight) resolution:resolution];
	[titleColor set];
	[[self title] drawInRect:drawRect withFont:font];
	
	// Name
	if (wideSize) 
		drawRect = [self scaleRect:CGRectMake(9.f, 21.f, 266.f, 25.f) resolution:resolution];
	else 
		drawRect = [self scaleRect:CGRectMake(9.f, 21.f, 218.f, 25.f) resolution:resolution];
	[nameColor set];
	[[self name] drawInRect:drawRect withFont:[font fontWithSize:fontSize+4.f]];
	
	// Party	
	if (wideSize) 
		drawRect = [self scaleRect:CGRectMake(9.f, 46.f, 103.f, labHeight) resolution:resolution];
	else 
		drawRect = [self scaleRect:CGRectMake(9.f, 46.f, 73.f, labHeight) resolution:resolution];
	[partyColor set];
	[[self party] drawInRect:drawRect withFont:font];
		
	// District
	if (wideSize) 
		drawRect = [self scaleRect:CGRectMake(131.0f, 46.0f, 92.f, labHeight) resolution:resolution];
	else 
		drawRect = [self scaleRect:CGRectMake(86.f, 46.f, 92.f, labHeight) resolution:resolution];
	[districtColor set];
	[[self district] drawInRect:drawRect withFont:font];
	
	// Tenure	
	if (wideSize) 
		drawRect = [self scaleRect:CGRectMake(131.f, 0.f, 96.f, labHeight) resolution:resolution];
	else 
		drawRect = [self scaleRect:CGRectMake(109.f, 0.f, 75.f, labHeight) resolution:resolution];
	[districtColor set];
	[[self tenure] drawInRect:drawRect withFont:font];
	
	// Role
	if (!IsEmpty(role)) {
		if (wideSize) 
			drawRect = [self scaleRect:CGRectMake(361.0f, 45.0f, 156.f, labHeight) resolution:resolution];
		else 
			drawRect = [self scaleRect:CGRectMake(153, 45.f, 74.f, labHeight) resolution:resolution];
		[titleColor set];
		[[self role] drawInRect:drawRect 
					   withFont:[font fontWithSize:fontSize+1.f] 
				  lineBreakMode:UILineBreakModeWordWrap
					  alignment:UITextAlignmentRight];
	}
	
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
}

@end
