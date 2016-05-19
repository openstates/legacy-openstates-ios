//
//  GenericDetailHeader.m
//  Created by Greg Combs on 12/12/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "GenericDetailHeader.h"
#import <QuartzCore/QuartzCore.h>
#import "SLFDrawingExtensions.h"

@interface GenericDetailHeader()
@property (nonatomic,strong) UIBezierPath *borderOutlinePath;
@end

static UIFont *titleFont;
static UIFont *subtitleFont;
static UIFont *detailFont;

@implementation GenericDetailHeader
@synthesize borderOutlinePath = _borderOutlinePath;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize detail = _detail;
@synthesize defaultSize = _defaultSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        if (!titleFont)
            titleFont = SLFFont(18);
        if (!subtitleFont)
            subtitleFont = SLFPlainFont(13);
        if (!detailFont)
            detailFont = SLFItalicFont(11);
        self.defaultSize = CGSizeMake(320, 100);
        [self configure];
    }
    return self;
}

- (void)dealloc {
    self.subtitle = nil;
    self.detail = nil;
}

- (CGSize)preferredSizeOfOneLineString:(NSString *)string withFont:(UIFont *)font {
    if (!SLFTypeNonEmptyStringOrNil(string))
        return CGSizeZero;
    return [string sizeWithFont:font];
}

- (CGSize)preferredSizeOfDetail {
    if (!SLFTypeNonEmptyStringOrNil(_detail))
        return CGSizeZero;
    return [_detail sizeWithFont:detailFont constrainedToSize:CGSizeMake(_defaultSize.width-40, _defaultSize.height-60)];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat preferredWidth = 0;
    if (SLFIsIpad())
        preferredWidth = 26;  // inset for header border box
    CGFloat preferredHeight = 26; // ...
    preferredWidth += 30; // text inset from inside the box
    preferredHeight += 15;
    
    CGSize titleSize = [self preferredSizeOfOneLineString:_title withFont:titleFont];
    CGSize subtitleSize = [self preferredSizeOfOneLineString:_subtitle withFont:subtitleFont];
    CGSize detailSize = [self preferredSizeOfDetail];
    CGFloat maxStringWidth = MAX(titleSize.width, subtitleSize.width);
    maxStringWidth = MAX(maxStringWidth, detailSize.width);
    preferredWidth += maxStringWidth;
    preferredHeight += (titleSize.height+5 + subtitleSize.height+5 + detailSize.height+5);
    size.width = roundf(MAX(size.width,preferredWidth));
    size.height = roundf(preferredHeight);
    return size;
}

- (void)configure {
    [self sizeToFit];
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    self.borderOutlinePath = [SLFDrawing tableHeaderBorderPathWithFrame:rect];
    [[SLFAppearance tableBackgroundDarkColor] setFill];
    [_borderOutlinePath fill];
    [[SLFAppearance detailHeaderSeparatorColor] setStroke];
    [_borderOutlinePath stroke];
    UIColor *darkColor = [SLFAppearance cellTextColor];
    UIColor *lightColor = [SLFAppearance cellSecondaryTextColor];
    CGFloat offsetX = rect.origin.x + 14;
    if (SLFIsIpad())
        offsetX += 14;
    CGFloat offsetY = 10 + rect.origin.y;
    CGFloat maxWidth = _borderOutlinePath.bounds.size.width - offsetX;

    [darkColor set];
    if (SLFTypeNonEmptyStringOrNil(_title)) {
        CGFloat actualFontSize;
        CGSize renderedSize = [_title drawAtPoint:CGPointMake(offsetX, offsetY) forWidth:maxWidth withFont:titleFont minFontSize:14 actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
        offsetY += roundf(5+renderedSize.height);
    }

    [lightColor set];
    if (SLFTypeNonEmptyStringOrNil(_subtitle)) {
        CGFloat actualFontSize;
        CGSize renderedSize = [_subtitle drawAtPoint:CGPointMake(offsetX, offsetY) forWidth:maxWidth withFont:subtitleFont minFontSize:10 actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
        offsetY += roundf(5+renderedSize.height);
    }

    if (SLFTypeNonEmptyStringOrNil(_detail)) {
        CGFloat maxHeight = _borderOutlinePath.bounds.size.height - offsetY - 15;
        CGSize constrainedSize = [_detail sizeWithFont:detailFont constrainedToSize:CGSizeMake(maxWidth, maxHeight)];
        CGRect detailRect = CGRectMake(offsetX, offsetY, constrainedSize.width, constrainedSize.height);
        [_detail drawInRect:detailRect withFont:detailFont];
    }
}

- (void)setTitle:(NSString *)title {
    SLFRelease(_title);
    _title = [title copy];
    if (!title)
        return;
    [self configure];
}

- (void)setSubtitle:(NSString *)subtitle {
    SLFRelease(_subtitle);
    _subtitle = [subtitle copy];
    if (!subtitle)
        return;
    [self configure];
}

- (void)setDetail:(NSString *)detail {
    SLFRelease(_detail);
    _detail = [detail copy];
    if (!detail)
        return;
    [self configure];
}

@end
