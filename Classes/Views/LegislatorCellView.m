//
//    LegislatorCellView.m
//  Created by Gregory Combs on 7/12/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
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
@synthesize title = _title;
@synthesize name = _name;
@synthesize party = _party;
@synthesize district = _district;
@synthesize role = _role;
@synthesize highlighted = _highlighted;
@synthesize useDarkBackground = _useDarkBackground;
@synthesize genericName = _genericName;

- (void)configureDefaults {
    _title = [[NSString alloc] init];
    _name = [[NSString alloc] init];
    _party = [[Independent independent] retain];
    _district = [[NSString alloc] init];
    _role = nil;
    _genericName = @"";
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
    SLFRelease(_title);
    SLFRelease(_name);
    SLFRelease(_party);
    SLFRelease(_district);
    SLFRelease(_role);
    SLFRelease(_genericName);
    [super dealloc];
}

- (CGSize)cellSize {
    return CGSizeMake(234, 73);
}

- (void)setUseDarkBackground:(BOOL)flag
{
    if (self.highlighted)
        return;
    _useDarkBackground = flag;
    self.backgroundColor =  flag ? [SLFAppearance cellBackgroundDarkColor] : [SLFAppearance cellBackgroundLightColor];
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)flag
{
    if (_highlighted == flag)
        return;
    _highlighted = flag;
    [self setNeedsDisplay];
}

- (void)setLegislator:(SLFLegislator *)value {    
    if (value) {
        self.title = value.title;
        self.district = value.districtShortName;
        self.party = value.partyObj;
        self.name = value.fullName;
        self.role = nil;
        self.genericName = @"";
    }
    [self setNeedsDisplay];    
}

- (void)setGenericName:(NSString *)genericName {
    SLFRelease(_genericName);
    if (genericName) {
        _genericName = [genericName copy];
    }
    [self setNeedsDisplay];
}

- (void)setRole:(NSString *)value {
    SLFRelease(_role);
    if (value)
        _role = [value copy];
    [self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [self cellSize];
}

- (CGRect)rectOfString:(NSString *)string atOrigin:(CGPoint)origin withFont:(UIFont *)font {
    CGSize textSize = [string sizeWithFont:font];
    return CGRectMake(origin.x, origin.y, textSize.width, textSize.height);
}

- (void)drawRect:(CGRect)dirtyRect
{
    CGRect aBounds = [self bounds];

    NSString *partyString = _party.name;
    NSString *nameString = _name;
    if (IsEmpty(nameString)) {
        nameString = _genericName;
        partyString = NSLocalizedString(@"Unknown", @"");
    }

    static UIFont *font;
    if (!font)
        font = SLFPlainFont(13);
    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *darkColor = [SLFAppearance cellTextColor];
    UIColor *lightColor = [SLFAppearance cellSecondaryTextColor];
    UIColor *partyColor = _party.color;
    UIColor *accentColor = [SLFAppearance accentGreenColor];    
    if (self.highlighted)
        darkColor = lightColor = partyColor = accentColor = whiteColor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, aBounds.origin.x, aBounds.origin.y);
    
    CGRect drawRect;

    // Title
    [lightColor set];
    UIFont *titleFont = SLFItalicFont(13);
    drawRect = [self rectOfString:_title atOrigin:CGPointMake(9,9) withFont:titleFont];
    [_title drawInRect:drawRect withFont:SLFItalicFont(13)];
    
    // Name
    [darkColor set];
    UIFont *nameFont = SLFFont(18);
    drawRect = [self rectOfString:nameString atOrigin:CGPointMake(9,25) withFont:nameFont];
    [nameString drawInRect:drawRect withFont:SLFFont(18)];
    
    // Party
    [partyColor set];
    drawRect = [self rectOfString:partyString atOrigin:CGPointMake(9,48) withFont:font];
    [partyString drawInRect:drawRect withFont:font];
        
    // District
    [lightColor set];
    drawRect = [self rectOfString:_district atOrigin:CGPointMake(drawRect.origin.x+drawRect.size.width+6, 48.f) withFont:font];
    [_district drawInRect:drawRect withFont:font];
    
    // Role
    if (!IsEmpty(_role)) {
        [accentColor set];
        UIFont *roleFont = SLFFont(14);
        drawRect = [self rectOfString:_role atOrigin:CGPointMake(aBounds.size.width - 90.f, 9.f) withFont:roleFont];
        [_role drawInRect:drawRect withFont:roleFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
    }

    CGContextRestoreGState(context);
    CGColorSpaceRelease(space);    
}

@end
