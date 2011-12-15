//
//  LegislatorDetailHeader.m
//  Created by Greg Combs on 12/12/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LegislatorDetailHeader.h"
#import <QuartzCore/QuartzCore.h>
#import "SLFDataModels.h"
#import "UIImageView+AFNetworking.h"
#import "SLFDrawingExtensions.h"

@interface LegislatorDetailHeader()
@property (nonatomic,retain) UIBezierPath *borderOutlinePath;
@property (nonatomic,retain) IBOutlet UIImageView *imageView;
- (void)configure;
@end

@implementation LegislatorDetailHeader
@synthesize borderOutlinePath = _borderOutlinePath;
@synthesize imageView = _imageView;
@synthesize legislator = _legislator;

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
    self.imageView = nil;
    self.legislator = nil;
    [super dealloc];
}

- (CGSize)sizeThatFits:(CGSize)size {
    size.width = MAX(size.width, 320);
    size.height = MAX(size.height, 120);
    return size;
}

- (void)configure {
    CGRect frame = self.frame;
    frame.size = [self sizeThatFits:frame.size];
    self.frame = frame;
    self.backgroundColor = [UIColor clearColor];
    self.borderOutlinePath = [SLFDrawing tableHeaderBorderPathWithFrame:frame];
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(28, 14, 52, 73)];
    [self addSubview:_imageView];
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
    if (!_legislator)
        return;
    CGRect drawRect = CGRectZero;
    UIColor *darkColor = [SLFAppearance cellTextColor];
    UIColor *lightColor = [SLFAppearance cellSecondaryTextColor];
    UIColor *partyColor = [_legislator partyObj].color;
    CGFloat offsetX = _imageView.origin.x + _imageView.size.width + 15;
    static UIFont *plainFont;
    if (!plainFont)
        plainFont = [[UIFont fontWithName:@"HelveticaNeue" size:13] retain];
    static UIFont *nameFont;
    if (!nameFont)
        nameFont = [SLFFont(18) retain];
    static UIFont *titleFont;
    if (!titleFont)
        titleFont = [SLFItalicFont(13) retain];

        // Title
    [lightColor set];
    [_legislator.title drawWithFont:titleFont origin:CGPointMake(offsetX,13)];

        // Name
    [darkColor set];
    [_legislator.fullName drawWithFont:nameFont origin:CGPointMake(offsetX,30)];

        // Party
    [partyColor set];
    drawRect = [_legislator.partyObj.name rectWithFont:plainFont origin:CGPointMake(offsetX,54)];
    [_legislator.partyObj.name drawInRect:drawRect withFont:plainFont];
    
        // District
    [lightColor set];
    [_legislator.districtShortName drawWithFont:plainFont origin:CGPointMake(drawRect.origin.x+drawRect.size.width+6, 54)];

        // Tenure
    [lightColor set];
    [_legislator.term drawWithFont:titleFont origin:CGPointMake(offsetX, 74)];
}

- (void)setLegislator:(SLFLegislator *)legislator {
    SLFRelease(_legislator);
    _legislator = [legislator retain];
    if (!legislator)
        return;
    if (legislator.photoURL)
        [_imageView setImageWithURL:[NSURL URLWithString:legislator.photoURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    else
        [self.imageView setImage:[UIImage imageNamed:@"placeholder"]];
    [self setNeedsDisplay];
}


@end
