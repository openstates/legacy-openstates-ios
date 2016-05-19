//
//    LegislatorCellView.m
//  Created by Gregory Combs on 7/12/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFDataModels.h"
#import "LegislatorCellView.h"
#import "SLFTheme.h"
#import <UIKit/UIKit.h>

static UIFont *plainFont;
static UIFont *nameFont;
static UIFont *titleFont;
static UIFont *roleFont;

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
    _party = [Independent independent];
    _district = @"";
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
        [self setNeedsDisplay];
    }
    else {
        self.title = nil;
        self.district = nil;
        self.party = nil;
        self.name = nil;
        self.role = nil;
        self.genericName = @"";
    }
}

- (void)setGenericName:(NSString *)genericName {
    SLFRelease(_genericName);
    if (genericName) {
        _genericName = [genericName copy];
        [self setNeedsDisplay];
    }
}

- (void)setRole:(NSString *)value {
    SLFRelease(_role);
    if (value) {
        _role = [value copy];
        [self setNeedsDisplay];
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [self cellSize];
}

- (CGRect)rectOfString:(NSString *)string atOrigin:(CGPoint)origin withAttributes:(NSDictionary *)attributes {
    if (!attributes || !string || !string.length)
        return CGRectZero;
    CGSize textSize = [string sizeWithAttributes:attributes];
    return CGRectMake(origin.x, origin.y, textSize.width, textSize.height);
}

- (void)drawRect:(CGRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    CGRect aBounds = [self bounds];

    NSString *partyString = _party.name;
    NSString *nameString = _name;
    if (!SLFTypeNonEmptyStringOrNil(nameString)) {
        nameString = _genericName;
        partyString = @"";
    }

    static UIFont *font = nil;
    if (!font)
        font = SLFPlainFont(13);
    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *darkColor = [SLFAppearance cellTextColor];
    UIColor *lightColor = [SLFAppearance cellSecondaryTextColor];
    UIColor *partyColor = _party.color;
    UIColor *accentColor = [SLFAppearance accentGreenColor];
    UIColor *backgroundColor = self.backgroundColor;

    if (!plainFont)
        plainFont = SLFFontWithStyle(UIFontTextStyleBody, 0, -2);
    if (!nameFont)
        nameFont = SLFFontWithStyle(UIFontTextStyleHeadline, UIFontDescriptorTraitBold, 0);
    if (!titleFont)
                    titleFont = SLFFontWithStyle(UIFontTextStyleFootnote, UIFontDescriptorTraitItalic, 0);
    if (!roleFont)
        roleFont = SLFFontWithStyle(UIFontTextStyleSubheadline, UIFontDescriptorTraitBold, 0);

    if (self.highlighted)
        darkColor = lightColor = partyColor = accentColor = whiteColor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, aBounds.origin.x, aBounds.origin.y);
    
    CGRect drawRect = CGRectZero;

    // Title
    if (SLFTypeNonEmptyStringOrNil(_title)) {
        NSDictionary *attributes = @{NSFontAttributeName: titleFont,
                                     NSForegroundColorAttributeName: lightColor,
                                     NSBackgroundColorAttributeName: backgroundColor};
        drawRect = [self rectOfString:_title atOrigin:CGPointMake(9,9) withAttributes:attributes];
        [_title drawInRect:drawRect withAttributes:attributes];
    }

    // Name
    if (SLFTypeNonEmptyStringOrNil(nameString)) {
        NSDictionary *attributes = @{NSFontAttributeName: nameFont,
                                     NSForegroundColorAttributeName: darkColor,
                                     NSBackgroundColorAttributeName: backgroundColor};
        drawRect = [self rectOfString:nameString atOrigin:CGPointMake(9,25) withAttributes:attributes];
        [nameString drawInRect:drawRect withAttributes:attributes];
    }
    
    // Party
    if (SLFTypeNonEmptyStringOrNil(partyString)) {
        NSDictionary *attributes = @{NSFontAttributeName: plainFont,
                                     NSForegroundColorAttributeName: partyColor,
                                     NSBackgroundColorAttributeName: backgroundColor};
        drawRect = [self rectOfString:partyString atOrigin:CGPointMake(9,48) withAttributes:attributes];
        [partyString drawInRect:drawRect withAttributes:attributes];
    }

    // District
    if (SLFTypeNonEmptyStringOrNil(_district)) {
        CGFloat xoffset = drawRect.origin.x+drawRect.size.width;
        if (SLFTypeNonEmptyStringOrNil(partyString))
            xoffset += 6;
        NSDictionary *attributes = @{NSFontAttributeName: plainFont,
                                     NSForegroundColorAttributeName: lightColor,
                                     NSBackgroundColorAttributeName: backgroundColor};
        drawRect = [self rectOfString:_district atOrigin:CGPointMake(xoffset,48) withAttributes:attributes];
        [_district drawInRect:drawRect withAttributes:attributes];
    }
    
    // Role
    if (SLFTypeNonEmptyStringOrNil(_role)) {
        static NSParagraphStyle *rightAlignedStyle = nil;
        if (!rightAlignedStyle)
        {
            NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            style.alignment = NSTextAlignmentRight;
            style.lineBreakMode = NSLineBreakByTruncatingTail;
            rightAlignedStyle = style;
        }
        NSDictionary *attributes = @{NSFontAttributeName: roleFont,
                                     NSParagraphStyleAttributeName: rightAlignedStyle,
                                     NSForegroundColorAttributeName: accentColor,
                                     NSBackgroundColorAttributeName: backgroundColor};

        drawRect = [self rectOfString:_role atOrigin:CGPointMake(aBounds.size.width - 90.f, 9.f) withAttributes:attributes];
        [_role drawInRect:drawRect withAttributes:attributes];
    }

    CGContextRestoreGState(context);
    CGColorSpaceRelease(space);    
}

- (void)didUpdateFontSize:(NSNotification *)notification
{
    plainFont = SLFFontWithStyle(UIFontTextStyleBody, 0, -2);
    nameFont = SLFFontWithStyle(UIFontTextStyleHeadline, UIFontDescriptorTraitBold, 0);
    titleFont = SLFFontWithStyle(UIFontTextStyleFootnote, UIFontDescriptorTraitItalic, 0);
    roleFont = SLFFontWithStyle(UIFontTextStyleSubheadline, UIFontDescriptorTraitBold, 0);

    [self setNeedsDisplay];
}


@end
