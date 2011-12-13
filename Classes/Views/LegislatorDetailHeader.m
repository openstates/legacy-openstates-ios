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

@interface LegislatorDetailHeader()
@property (nonatomic,retain) UIBezierPath *borderOutlinePath;
@property (nonatomic,retain) IBOutlet UIImageView *imageView;
- (void)configure;
- (UIBezierPath *)createBorderPathWithFrame:(CGRect)frame;
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
    self.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:240/255.f green:240/255.f blue:226/255.f alpha:1];
    self.borderOutlinePath = [self createBorderPathWithFrame:frame];
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(28, 14, 52, 73)];
    [self addSubview:_imageView];
    [self setNeedsDisplay];
}

- (UIBezierPath *)createBorderPathWithFrame:(CGRect)frame {
    CGRect rect = frame;
    rect.size.height -= 20;
    rect.size.width -= 26;
    rect.origin.x += (CGRectGetMidX(frame) - CGRectGetMidX(rect));
    rect = CGRectIntegral(rect);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:rect.origin];
    [path addLineToPoint:CGPointMake(rect.origin.x+rect.size.width, rect.origin.y)];
    [path addLineToPoint:CGPointMake(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height)];
    [path addLineToPoint:CGPointMake(rect.origin.x+52, rect.origin.y+rect.size.height)];
    [path addLineToPoint:CGPointMake(rect.origin.x+38, rect.origin.y+rect.size.height + 15)];
    [path addLineToPoint:CGPointMake(rect.origin.x+24, rect.origin.y+rect.size.height)];
    [path addLineToPoint:CGPointMake(rect.origin.x, rect.origin.y+rect.size.height)];
    [path addLineToPoint:CGPointMake(rect.origin.x, rect.origin.y)];
    [path closePath];
    path.lineWidth = 1;
    path.lineJoinStyle = kCGLineJoinMiter;
    path.lineCapStyle = kCGLineCapButt;
    return path;
}

- (CGRect)rectOfString:(NSString *)string atOrigin:(CGPoint)origin withFont:(UIFont *)font {
    CGSize textSize = [string sizeWithFont:font];
    return CGRectMake(origin.x, origin.y, textSize.width, textSize.height);
}

- (void)drawRect:(CGRect)rect
{
    [[SLFAppearance cellBackgroundLightColor] setFill];
    [_borderOutlinePath fill];
    [[UIColor colorWithRed:189/255.f green:189/255.f blue:176/255.f alpha:1] setStroke];
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
    drawRect = [self rectOfString:_legislator.title atOrigin:CGPointMake(offsetX,13) withFont:titleFont];
    [_legislator.title drawInRect:drawRect withFont:titleFont];

        // Name
    [darkColor set];
    drawRect = [self rectOfString:_legislator.fullName atOrigin:CGPointMake(offsetX,30) withFont:nameFont];
    [_legislator.fullName drawInRect:drawRect withFont:nameFont];

        // Party
    [partyColor set];
    drawRect = [self rectOfString:_legislator.partyObj.name atOrigin:CGPointMake(offsetX,54) withFont:plainFont];
    [_legislator.partyObj.name drawInRect:drawRect withFont:plainFont];
    
        // District
    [lightColor set];
    drawRect = [self rectOfString:_legislator.districtShortName atOrigin:CGPointMake(drawRect.origin.x+drawRect.size.width+6, 54) withFont:plainFont];
    [_legislator.districtShortName drawInRect:drawRect withFont:plainFont];

        // Tenure
    [lightColor set];
    drawRect = [self rectOfString:_legislator.term atOrigin:CGPointMake(offsetX, 74) withFont:titleFont];
    [_legislator.term drawInRect:drawRect withFont:titleFont];
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
