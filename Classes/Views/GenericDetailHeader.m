//
//  GenericDetailHeader.m
//  Created by Greg Combs on 12/12/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "GenericDetailHeader.h"
#import <QuartzCore/QuartzCore.h>
#import "SLFDrawingExtensions.h"

@interface GenericDetailHeader()
@property (nonatomic,retain) UIBezierPath *borderOutlinePath;
- (void)configure;
@end

@implementation GenericDetailHeader
@synthesize borderOutlinePath = _borderOutlinePath;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize detail = _detail;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)dealloc {
    self.borderOutlinePath = nil;
    self.title = nil;
    self.subtitle = nil;
    self.detail = nil;
    [super dealloc];
}

- (CGSize)sizeThatFits:(CGSize)size {
    size.width = MAX(size.width, 320);
    size.height = MAX(size.height, 100);
    return size;
}

- (void)configure {
    [self sizeToFit];
    /*CGRect frame = self.frame;
    frame.size = [self sizeThatFits:frame.size];
    self.frame = frame;*/
    self.backgroundColor = [UIColor clearColor];
    self.borderOutlinePath = [SLFDrawing tableHeaderBorderPathWithFrame:self.frame];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [[SLFAppearance cellBackgroundLightColor] setFill];
    [_borderOutlinePath fill];
    static UIColor *strokeColor;
    if (!strokeColor)
        strokeColor = [SLFColorWithRGB(189, 189, 176) retain];
    [strokeColor setStroke];
    [_borderOutlinePath stroke];
    UIColor *darkColor = [SLFAppearance cellTextColor];
    UIColor *lightColor = [SLFAppearance cellSecondaryTextColor];
    static UIFont *plainFont;
    if (!plainFont)
        plainFont = [[UIFont fontWithName:@"HelveticaNeue" size:13] retain];
    static UIFont *nameFont;
    if (!nameFont)
        nameFont = [SLFFont(18) retain];

    CGFloat offsetX = 30;
    CGFloat offsetY = 10;

        // Title
    [darkColor set];
    if (!IsEmpty(_title)) {
        [_title drawWithFont:nameFont origin:CGPointMake(offsetX,offsetY)];
        offsetY += 25;
    }

        // Subtitle
    [lightColor set];
    if (!IsEmpty(_subtitle)) {
        [_subtitle drawWithFont:plainFont origin:CGPointMake(offsetX, offsetY)];
        offsetY += 20;
    }

        // Detail
    if (!IsEmpty(_subtitle)) {
        static UIFont *italic;
        if (!italic)
            italic = [SLFItalicFont(13) retain];
        [_detail drawWithFont:italic origin:CGPointMake(offsetX, offsetY)];
    }
}

- (void)setTitle:(NSString *)title {
    SLFRelease(_title);
    _title = [title copy];
    if (!title)
        return;
    [self setNeedsDisplay];
}

- (void)setSubtitle:(NSString *)subtitle {
    SLFRelease(_subtitle);
    _subtitle = [subtitle copy];
    if (!subtitle)
        return;
    [self setNeedsDisplay];
}

- (void)setDetail:(NSString *)detail {
    SLFRelease(_detail);
    _detail = [detail copy];
    if (!detail)
        return;
    [self setNeedsDisplay];
}

@end
