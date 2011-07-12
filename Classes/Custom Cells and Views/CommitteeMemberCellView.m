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

#import "CommitteeMemberCellView.h"
#import "LegislatorObj+RestKit.h"
#import "TexLegeTheme.h"
#import "TexLegeCoreDataUtils.h"
#import "UtilityMethods.h"

const CGFloat kCommitteeMemberCellViewWidth = 531.0f;
const CGFloat kCommitteeMemberCellViewHeight = 73.0f;

@implementation CommitteeMemberCellView

@synthesize title;
@synthesize name;
@synthesize tenure;
@synthesize party;
@synthesize district;
@synthesize role;
@synthesize party_id, highlighted;
@synthesize useDarkBackground;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		title = [@"Rep." retain];
		name = [@"Genevieve McGillicuddy" retain];
		tenure = [@"(Freshman)" retain];
		party = [@"Republican" retain];
		district = [@"District 21" retain];
		role = [@"Vice-Chair" retain];
		party_id = 2;
		self.backgroundColor = [TexLegeTheme backgroundLight];
		[self setOpaque:YES];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		title = [@"Rep." retain];
		name = [@"Genevieve McGillicuddy" retain];
		tenure = [@"(Freshman)" retain];
		party = [@"Republican" retain];
		district = [@"District 21" retain];
		role = [@"Vice-Chair" retain];
		party_id = 2;
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
	if ([UtilityMethods isIPadDevice])
		return CGSizeMake(531.f, 73.f);
	else
		return CGSizeMake(234.f, 73.f);
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

- (void)setLegislator:(LegislatorObj *)value role:(NSString *)legRole {	
	if (value) {
		self.title = [value legTypeShortName];
		self.district = [NSString stringWithFormat:NSLocalizedStringFromTable(@"District %@", @"DataTableUI", @"District number"),
						 value.district];
		self.party = value.party_name;
		self.name = [value legProperName];
		self.tenure = [value tenureString];
		self.role = legRole;
		self.party_id = [[value party_id] integerValue];
	}
	[self setNeedsDisplay];	
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return [self cellSize];
}

- (void)drawRect:(CGRect)dirtyRect
{
	BOOL isIPad = [UtilityMethods isIPadDevice];
	
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, self.cellSize.width, self.cellSize.height);
	CGRect bounds = [self bounds];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect drawRect;
	CGFloat resolution;
	UIFont *font;
	resolution = 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	
	UIColor *nameColor = nil;
	UIColor *tenureColor = nil;
	UIColor *titleColor = nil;
	UIColor *partyColor = nil;
	UIColor *districtColor = nil;
	
	// Choose font color based on highlighted state.
	if (self.highlighted) {
		nameColor = tenureColor = titleColor = partyColor = districtColor = [TexLegeTheme backgroundLight];
	}
	else {
		nameColor = [TexLegeTheme textDark];
		tenureColor = districtColor = [TexLegeTheme textLight];
		titleColor = [TexLegeTheme accent];
		
		if (party_id == REPUBLICAN)
			partyColor = [TexLegeTheme texasRed];
		else if (party_id == DEMOCRAT)
			partyColor = [TexLegeTheme texasBlue];
		else // INDEPENDENT ?
			partyColor = [TexLegeTheme textLight];
	}

	CGFloat fontSize = ([UtilityMethods isIPadDevice]) ? 17.f : 11.f;
	font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize];
	UIFont *biggerFont = [font fontWithSize:fontSize+2.f];
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Tenure

	if (isIPad) 
		drawRect = CGRectMake(212.0f, 33.0f, 96.f, 30.f);
	else 
		drawRect = CGRectMake(11.f, 47.f, 67.f, 20.f);
	
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	[tenureColor set];
	[[self tenure] drawInRect:drawRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
	
	// District
	
	if (isIPad) 
		drawRect = CGRectMake(120.0f, 33.0f, 92.f, 30.f);
	else 
		drawRect = CGRectMake(90.f, 27.f, 67.f, 20.f);
	
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	[districtColor set];
	[[self district] drawInRect:drawRect withFont:font];
	
	// Party
	
	if (isIPad) 
		drawRect = CGRectMake(11.0f, 33.0f, 104.f, 30.f);
	else 
		drawRect = CGRectMake(11.f, 27.f, 77.f, 20.f);
		
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	[partyColor set];
	[[self party] drawInRect:drawRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
	
	// Role
	
	if (isIPad) 
		drawRect = CGRectMake(350.0f, 18.0f, 156.f, 30.f);
	else 
		drawRect = CGRectMake(140, 47.f, 95.f, 20.f);
	
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	[titleColor set];
	[[self role] drawInRect:drawRect withFont:biggerFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	
	// Name
	
	if (isIPad) 
		drawRect = CGRectMake(70.f, 3.f, 263.f, 30.f);
	else 
		drawRect = CGRectMake(45.f, 3.f, 164.f, 20.f);
		
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	[nameColor set];
	[[self name] drawInRect:drawRect withFont:biggerFont];
	
	// Title
	
	if (isIPad) 
		drawRect = CGRectMake(11.f, 3.f, 52.f, 30.f);
	else 
		drawRect = CGRectMake(11.f, 3.f, 35.f, 20.f);
	
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	[titleColor set];
	[[self title] drawInRect:drawRect withFont:biggerFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];

	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
}

@end
