//
//  SLFBadgeCell.m
//  Created by Gregory Combs on 3/24/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <QuartzCore/QuartzCore.h>
#import "SLFBadgeCell.h"
#import "SLFDataModels.h"
#import "SLFTheme.h"

@interface MiniCellBadge : UIView
@property (nonatomic,copy) NSString *text;
@property (nonatomic,strong) UIBezierPath *ellipse;
@property (nonatomic,weak) SLFBadgeCell *cell;
@property (nonatomic,strong) UIColor *badgeColor;
@property (nonatomic,strong) UIColor *highlightColor;
@property (nonatomic,assign) BOOL highlighted;
@property (weak, nonatomic,readonly) UIFont *textFont;
@end

@implementation MiniCellBadge
@synthesize ellipse = _ellipse;
@synthesize text = _text;
@synthesize cell = _cell;
@synthesize badgeColor = _badgeColor;
@synthesize textFont = _textFont;
@synthesize highlightColor = _highlightColor;
@synthesize highlighted = _highlighted;

- (id)initWithText:(NSString *)text cell:(SLFBadgeCell *)cell
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        self.opaque = YES;
        self.text = text;
        self.cell = cell;
        self.badgeColor = [SLFAppearance accentBlueColor];
        _highlighted = NO;
        self.highlightColor = [UIColor whiteColor];
    }
    return self;
}

- (void)dealloc
{
    self.cell = nil;
}

- (UIFont *)textFont
{
    static UIFont *badgeFont = nil;
    if (!badgeFont)
        badgeFont = SLFFont(12);
    return badgeFont;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    NSString *text = self.text;
    if (!text || !text.length)
        return CGSizeZero;
    UIFont *font = self.textFont;
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGRect rect = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    rect = CGRectIntegral(rect);
    CGSize badgeTextSize = rect.size;
    badgeTextSize.width = roundf(badgeTextSize.width) + 16;
    badgeTextSize.height = roundf(badgeTextSize.height) + 8;
    return badgeTextSize;
}

- (void)setText:(NSString *)text
{
    SLFRelease(_text);
    _text = [text copy];
    [self sizeToFit];
    if (!text || !text.length)
    {
        self.ellipse = nil;
        return;
    }
    CGRect bounds = CGRectIntegral(self.bounds);
    self.ellipse = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:12];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    UIColor *color = _badgeColor;
    if (_highlighted)
        color = _highlightColor;

    CGContextRef context = UIGraphicsGetCurrentContext();
    [color set];
    [_ellipse fill];
    
    CGContextSaveGState(context);

    if (_highlighted)
        CGContextSetBlendMode(context, kCGBlendModeClear);
    else
        [self.backgroundColor set];

    CGContextRestoreGState(context);

    if (_text && _text.length)
    {
        static NSParagraphStyle *centeredStyle = nil;
        if (!centeredStyle)
        {
            NSMutableParagraphStyle *centered = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            centered.alignment = NSTextAlignmentCenter;
            centeredStyle = centered;
        }

        UIColor *background = self.badgeColor;
        if (!background)
            background = [UIColor clearColor];

        NSDictionary *attributes = @{NSFontAttributeName:self.textFont,
                                     NSForegroundColorAttributeName: (_highlighted ? [UIColor blackColor] : [UIColor whiteColor]),
                                     NSBackgroundColorAttributeName: color,
                                     NSParagraphStyleAttributeName: centeredStyle};
        [_text drawInRect:CGRectInset(rect, 8, 4) withAttributes:attributes];
    }
}

@end

@interface SLFBadgeCell()
@property (nonatomic,strong) MiniCellBadge *miniBadge;
@end

@implementation SLFBadgeCell
@synthesize isClickable = _isClickable;
@synthesize subjectEntry = _subjectEntry;
@synthesize miniBadge = _miniBadge;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _isClickable = YES;
        self.opaque = YES;

        static UIFont *labelFont = nil;
        if (!labelFont)
            labelFont = SLFFont(15);
        self.textLabel.font = labelFont;
        self.textLabel.textColor = [SLFAppearance cellTextColor];
        _miniBadge = [[MiniCellBadge alloc] initWithText:nil cell:self];
        self.accessoryView = _miniBadge;
        self.backgroundColor = [SLFAppearance cellBackgroundLightColor];
    }
    return self;
}

#pragma mark -
#pragma mark init & dealloc

- (void)dealloc
{
    self.subjectEntry = nil;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.subjectEntry = nil;
}

- (void)setSubjectEntry:(BillsSubjectsEntry *)subjectEntry
{
    SLFRelease(_subjectEntry);
    if (!subjectEntry)
    {
        self.textLabel.text = nil;
        self.miniBadge.text = nil;
        self.isClickable = NO;
        return;
    }
    _subjectEntry = subjectEntry;
    self.textLabel.text = subjectEntry.name;
    self.miniBadge.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Bills", @""), subjectEntry.billCount];
    self.isClickable = [subjectEntry.billCount integerValue] > 0;
}

- (void)updateBadgeState
{
    self.miniBadge.highlighted = (_isClickable && (self.isHighlighted || self.isSelected));
    [self.miniBadge setNeedsDisplay];
    [self.textLabel setNeedsDisplay];
    [self setNeedsDisplay];
}

- (void)setIsClickable:(BOOL)isClickable
{
    _isClickable = isClickable;
    if (isClickable)
    {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.textLabel.textColor = [SLFAppearance cellTextColor];
        self.miniBadge.alpha = 1;
        self.miniBadge.opaque = YES;
        self.miniBadge.badgeColor = [SLFAppearance  accentBlueColor];
    }
    else
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.textColor = SLFColorWithRGBShift(self.backgroundColor, -60); // doesn't use CG blending
        self.miniBadge.alpha = .3;
        self.miniBadge.opaque = NO;
        self.miniBadge.badgeColor = [SLFAppearance accentGreenColor];
    }
    [self updateBadgeState];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self updateBadgeState];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self updateBadgeState];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.miniBadge.backgroundColor = backgroundColor;
    self.textLabel.backgroundColor = backgroundColor;
    [self updateBadgeState];
}

@end
