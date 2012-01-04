//
//  SLFBadgeCell.m
//  Created by Gregory Combs on 3/24/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <QuartzCore/QuartzCore.h>
#import "SLFBadgeCell.h"
#import "SLFDataModels.h"
#import "SLFTheme.h"

@interface MiniCellBadge : UIView
@property (nonatomic,copy) NSString *text;
@property (nonatomic,retain) UIBezierPath *ellipse;
@property (nonatomic,assign) SLFBadgeCell *cell;
@property (nonatomic,retain) UIColor *badgeColor;
@property (nonatomic,retain) UIColor *highlightColor;
@property (nonatomic,assign) BOOL highlighted;
@property (nonatomic,retain) UIFont *textFont;
@end

@implementation MiniCellBadge
@synthesize ellipse = _ellipse;
@synthesize text = _text;
@synthesize cell = _cell;
@synthesize badgeColor = _badgeColor;
@synthesize textFont = _textFont;
@synthesize highlightColor = _highlightColor;
@synthesize highlighted = _highlighted;

- (id)initWithText:(NSString *)text cell:(SLFBadgeCell *)cell {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.opaque = YES;
        self.text = text;
        self.cell = cell;
        self.textFont = SLFFont(12);
        self.badgeColor = [SLFAppearance accentBlueColor];
        _highlighted = NO;
        self.highlightColor = [UIColor whiteColor];
    }
    return self;
}

- (void)dealloc {
    self.textFont = nil;
    self.text = nil;
    self.ellipse = nil;
    self.cell = nil;
    self.badgeColor = nil;
    self.highlightColor = nil;
    [super dealloc];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize badgeTextSize = [self.text sizeWithFont:SLFFont(12)];
    badgeTextSize.width += 16;
    badgeTextSize.height += 8;
    return badgeTextSize;
}

- (void)setText:(NSString *)text {
    SLFRelease(_text);
    _text = [text copy];
    [self sizeToFit];
    if (text) {
        self.ellipse = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:12];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *color = _badgeColor;
    if (_highlighted)
        color = _highlightColor;
    [color set];
    [_ellipse fill];
    
    CGContextSaveGState(context);
    if (_highlighted)
        CGContextSetBlendMode(context, kCGBlendModeClear);
    else
        [self.backgroundColor set];
    [_text drawInRect:CGRectInset(rect, 8, 4) withFont:_textFont];
    CGContextRestoreGState(context);
}

@end

@interface SLFBadgeCell()
@property (nonatomic,retain) MiniCellBadge *miniBadge;
@end

@implementation SLFBadgeCell
@synthesize isClickable = _isClickable;
@synthesize subjectEntry = _subjectEntry;
@synthesize miniBadge = _miniBadge;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.backgroundColor = [SLFAppearance cellBackgroundLightColor];
        _isClickable = YES;
        self.opaque = YES;
        self.textLabel.font = SLFFont(15);
        self.textLabel.textColor = [SLFAppearance cellTextColor];
        _miniBadge = [[MiniCellBadge alloc] initWithText:nil cell:self];
        self.accessoryView = _miniBadge;
    }
    return self;
}

#pragma mark -
#pragma mark init & dealloc

- (void)dealloc {
    self.subjectEntry = nil;
    self.miniBadge = nil;
    [super dealloc];
}

- (void)setSubjectEntry:(BillsSubjectsEntry *)subjectEntry {
    SLFRelease(_subjectEntry);
    if (!subjectEntry)
        return;
    _subjectEntry = [subjectEntry retain];
    self.textLabel.text = subjectEntry.name;
    self.miniBadge.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Bills", @""), subjectEntry.billCount];
    self.isClickable = [subjectEntry.billCount integerValue] > 0;
}

- (void)updateBadgeState {
    _miniBadge.highlighted = (_isClickable && (self.isHighlighted || self.isSelected));
    [_miniBadge setNeedsDisplay];
}

- (void)setIsClickable:(BOOL)isClickable {
    _isClickable = isClickable;
    if (isClickable) {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.textLabel.textColor = [SLFAppearance cellTextColor];
        self.miniBadge.alpha = 1;
        _miniBadge.opaque = YES;
        _miniBadge.badgeColor = [SLFAppearance  accentBlueColor];
    }
    else {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.textColor = SLFColorWithRGBShift(self.backgroundColor, -60); // doesn't use CG blending
        self.miniBadge.alpha = .3;
        _miniBadge.opaque = NO;
        _miniBadge.badgeColor = [SLFAppearance accentGreenColor];
    }
    [self updateBadgeState];
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self updateBadgeState];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self updateBadgeState];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    _miniBadge.backgroundColor = backgroundColor;
}
@end
