//
//	CommitteeMemberCellView.m
//  Created by Gregory Combs on 8/29/10.
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

@synthesize title, name, tenure, party, party_id, district;
@synthesize highlighted;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		title = [@"Rep." retain];
		name = [@"Warren Chisum" retain];
		tenure = [@"4 Years" retain];
		party = [@"Republican" retain];
		district = [@"District 21" retain];
		party_id = 2;
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
		district = [@"District 21" retain];
		party_id = 2;
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
	district = [@"District 21" retain];
	party_id = 2;
	[self setOpaque:YES];
	self.backgroundColor = [TexLegeTheme backgroundLight];
}

- (void)dealloc
{
	nice_release(title);
	nice_release(name);
	nice_release(tenure);
	nice_release(party);
	nice_release(district);
	
	[super dealloc];
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

- (void)setLegislator:(LegislatorObj *)value {	
	if (value) {
		self.title = [value legTypeShortName];
		self.district = [NSString stringWithFormat:NSLocalizedStringFromTable(@"District %@", @"DataTableUI", @"District number"),
						 value.district];
		self.party = value.party_name;
		self.name = [value legProperName];
		self.tenure = [value tenureString];
		self.party_id = [[value party_id] integerValue];		
	}
	[self setNeedsDisplay];	
}

- (void)drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, kCommitteeMemberCellViewWidth, kCommitteeMemberCellViewHeight);
	CGRect bounds = [self bounds];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat resolution;
	CGRect drawRect;
	UIFont *font;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	resolution = 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
	
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
		partyColor = party_id == REPUBLICAN ? [TexLegeTheme texasRed] : [TexLegeTheme texasBlue];
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
	[[self tenure] drawInRect:drawRect withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
	
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
	
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
}

@end
