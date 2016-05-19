//
//  LegislatorDetailHeader.m
//  Created by Greg Combs on 12/12/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "LegislatorDetailHeader.h"
#import <QuartzCore/QuartzCore.h>
#import "SLFDataModels.h"
#import "UIImageView+SLFLegislator.h"
#import "SLFDrawingExtensions.h"

@interface LegislatorDetailHeader()
@property (nonatomic,strong) UIBezierPath *borderOutlinePath;
@property (nonatomic,strong) IBOutlet UIImageView *imageView;
- (void)configure;
@end

static UIFont *nameFont;
static UIFont *plainFont;
static UIFont *titleFont;

@implementation LegislatorDetailHeader
@synthesize borderOutlinePath = _borderOutlinePath;
@synthesize imageView = _imageView;
@synthesize legislator = _legislator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        CGFloat offsetX = 14;
        if (SLFIsIpad())
            offsetX = 28;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, 10, 52, 73)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];

        if (!nameFont)
            nameFont = SLFFontWithStyle(UIFontTextStyleSubheadline, UIFontDescriptorTraitBold, 0);
        if (!plainFont)
            plainFont = SLFFontWithStyle(UIFontTextStyleBody, 0, -2);
        if (!titleFont)
            titleFont = SLFFontWithStyle(UIFontTextStyleFootnote, UIFontDescriptorTraitItalic, 0);

        [self configure];
    }
    return self;
}

- (void)dealloc {
    self.legislator = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (CGSize)sizeThatFits:(CGSize)size {
    size.width = roundf(MAX(size.width, 320));
    size.height = roundf(MAX(size.height, 120));
    return size;
}

- (void)configure {
    [self sizeToFit];
    [self setNeedsDisplay];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateFontSize:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)didUpdateFontSize:(NSNotification *)notification
{
    SLFRelease(nameFont);
    nameFont = SLFFontWithStyle(UIFontTextStyleSubheadline, UIFontDescriptorTraitBold, 0);
    SLFRelease(plainFont);
    plainFont = SLFFontWithStyle(UIFontTextStyleBody, 0, -2);
    SLFRelease(titleFont);
    titleFont = SLFFontWithStyle(UIFontTextStyleFootnote, UIFontDescriptorTraitItalic, 0);

    [self setNeedsDisplay];
}

- (NSString *)validString:(NSString *)string {
    if (!SLFTypeNonEmptyStringOrNil(string))
        return @"";
    return string;
}

- (CGRect)rectOfString:(NSString *)string atOrigin:(CGPoint)origin withAttributes:(NSDictionary *)attributes options:(NSStringDrawingOptions)options context:(NSStringDrawingContext *)context maxWidth:(CGFloat)maxWidth
{
    if (!attributes || !string || !string.length)
        return CGRectZero;

    CGSize textSize = [string sizeWithAttributes:attributes];
    if (maxWidth <= 0.f) {
        return CGRectIntegral(CGRectMake(origin.x, origin.y, textSize.width, textSize.height));
    }

    textSize.width = MIN(textSize.width, maxWidth);

    CGRect rect = [string boundingRectWithSize:textSize options:options attributes:attributes context:context];
    rect.origin = origin;
    rect = CGRectIntegral(rect);
    return rect;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    self.borderOutlinePath = [SLFDrawing tableHeaderBorderPathWithFrame:rect];

    UIColor *backgroundColor = [SLFAppearance tableBackgroundDarkColor];
    [backgroundColor setFill];

    [_borderOutlinePath fill];
    [[SLFAppearance detailHeaderSeparatorColor] setStroke];
    [_borderOutlinePath stroke];
    if (!_legislator)
        return;

    UIColor *darkColor = [SLFAppearance cellTextColor];
    UIColor *lightColor = [SLFAppearance cellSecondaryTextColor];
    UIColor *partyColor = [_legislator partyObj].color;

    CGFloat offsetX = (_imageView.origin.x + _imageView.size.width) + 15.f;
    CGFloat offsetY = (_imageView.origin.y - 2.f);
    CGFloat maxWidth = CGRectGetWidth(self.borderOutlinePath.bounds) - offsetX;

    NSString *title = [self validString:_legislator.title];
    NSString *name = [self validString:_legislator.fullName];
    NSString *party = [self validString:_legislator.partyObj.name];
    NSString *district = [self validString:_legislator.districtShortName];
    NSString *term = [self validString:_legislator.term];

    static NSParagraphStyle *leftAlignedStyle = nil;
    if (!leftAlignedStyle)
    {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.alignment = NSTextAlignmentNatural;
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        leftAlignedStyle = style;
    }

    static NSParagraphStyle *rightAlignedStyle = nil;
    if (!rightAlignedStyle)
    {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.alignment = NSTextAlignmentRight;
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        rightAlignedStyle = style;
    }

    NSStringDrawingContext *context = context = [[NSStringDrawingContext alloc] init];
    NSStringDrawingOptions options = NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine;
    CGRect drawRect = CGRectZero;

    if (title.length)
    {
        NSDictionary *attributes = @{NSFontAttributeName: titleFont,
                                     NSParagraphStyleAttributeName: leftAlignedStyle,
                                     NSForegroundColorAttributeName: lightColor,
                                     NSBackgroundColorAttributeName: backgroundColor};

        drawRect = [self rectOfString:title atOrigin:CGPointMake(offsetX, offsetY) withAttributes:attributes options:options context:context maxWidth:maxWidth];
        [title drawWithRect:drawRect options:options attributes:attributes context:context];

        offsetY += roundf(2 + CGRectGetHeight(drawRect));
    }

    if (name.length)
    {
        NSDictionary *attributes = @{NSFontAttributeName: nameFont,
                                     NSParagraphStyleAttributeName: leftAlignedStyle,
                                     NSForegroundColorAttributeName: darkColor,
                                     NSBackgroundColorAttributeName: backgroundColor};

        drawRect = [self rectOfString:name atOrigin:CGPointMake(offsetX, offsetY) withAttributes:attributes options:options context:context maxWidth:maxWidth];
        [name drawWithRect:drawRect options:options attributes:attributes context:context];

        offsetY += roundf(2 + CGRectGetHeight(drawRect));
    }

    CGFloat shiftX = 0;

    if (party.length)
    {
        NSDictionary *attributes = @{NSFontAttributeName: plainFont,
                                     NSParagraphStyleAttributeName: leftAlignedStyle,
                                     NSForegroundColorAttributeName: partyColor,
                                     NSBackgroundColorAttributeName: backgroundColor};
        drawRect = [self rectOfString:party atOrigin:CGPointMake(offsetX, offsetY) withAttributes:attributes options:options context:context maxWidth:maxWidth];
        [party drawWithRect:drawRect options:options attributes:attributes context:context];

        shiftX += roundf(CGRectGetWidth(drawRect) + 6);
    }

    if (district.length)
    {
        NSDictionary *attributes = @{NSFontAttributeName: plainFont,
                                     NSParagraphStyleAttributeName: leftAlignedStyle,
                                     NSForegroundColorAttributeName: lightColor,
                                     NSBackgroundColorAttributeName: backgroundColor};

        drawRect = [self rectOfString:district atOrigin:CGPointMake((offsetX+shiftX), offsetY) withAttributes:attributes options:options context:context maxWidth:(maxWidth-shiftX)];
        [district drawWithRect:drawRect options:options attributes:attributes context:context];

        offsetY += roundf(2 + CGRectGetHeight(drawRect));
        shiftX = 0;
    }

    if (term.length)
    {
        NSDictionary *attributes = @{NSFontAttributeName: titleFont,
                                     NSParagraphStyleAttributeName: leftAlignedStyle,
                                     NSForegroundColorAttributeName: lightColor,
                                     NSBackgroundColorAttributeName: backgroundColor};

        drawRect = [self rectOfString:term atOrigin:CGPointMake(offsetX, offsetY) withAttributes:attributes options:options context:context maxWidth:maxWidth];
        [term drawWithRect:drawRect options:options attributes:attributes context:context];

        offsetY += roundf(2 + CGRectGetHeight(drawRect));
    }
}

- (void)setLegislator:(SLFLegislator *)legislator
{
    SLFRelease(_legislator);
    _legislator = legislator;
    [self.imageView setImageWithLegislator:legislator];
    if (!legislator)
        return;
    [self configure];
    [self setNeedsDisplay];
}


@end
