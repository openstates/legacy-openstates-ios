//  TitleBarView.m
//  Reconstituted by Greg Combs on 11/17/11.
//     Originates from digdog's DDActionHeaderView, MIT License, https://github.com/digdog/DDActionHeaderView
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "TitleBarView.h"
#import <QuartzCore/QuartzCore.h>

@interface TitleBarView()
- (void)drawLinearGradientInRect:(CGRect)rect colors:(NSArray *)colors;
- (void)drawLineInRect:(CGRect)rect color:(CGColorRef)strokeColor;
@property(nonatomic, retain) NSArray *gradientColors;
@property(nonatomic, retain) NSArray *borderShadowColors;
@end

UIColor *DDColorWithRGBA(int r, int g, int b, CGFloat a);

const CGFloat kTitleBarHeight = 70;
const CGFloat kDefaultGradientBorderHeight = 5;

@implementation TitleBarView
@synthesize useGradientBorder;
@synthesize titleLabel = _titleLabel;
@synthesize gradientColors = _gradientColors;
@synthesize borderShadowColors = _borderShadowColors;
@synthesize strokeTopColor = _strokeTopColor;
@synthesize strokeBottomColor = _strokeBottomColor;
@synthesize titleColor = _titleColor;
@synthesize titleFont = _titleFont;
@synthesize borderShadowHeight = _borderShadowHeight;
@dynamic gradientTopColor, gradientBottomColor;
@dynamic borderShadowTopColor, borderShadowBottomColor;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, kTitleBarHeight)];
	if (self) {
		[self setup];		
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title {
    self = [self initWithFrame:frame];
    if (self) {
        self.title = title;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
		[self setup];
    }
    return self;
} 

- (void)setup {
	self.opaque = NO;
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	useGradientBorder = YES;
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_titleLabel.numberOfLines = 2;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
	_titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_titleLabel];
    
    _borderShadowHeight = kDefaultGradientBorderHeight;
    static UIColor *gradientTop;
    if (!gradientTop)
        gradientTop = [DDColorWithRGBA(204, 206, 191, 1) retain];
    static UIColor *gradientBottom;
    if (!gradientBottom)
        gradientBottom = [DDColorWithRGBA(162, 165, 148, 1) retain];
    self.gradientColors = [NSArray arrayWithObjects:(id)gradientTop.CGColor, (id)gradientBottom.CGColor, nil];

    static UIColor *shadowTop;
    if (!shadowTop)
        shadowTop = [DDColorWithRGBA(79, 80, 72, 0.5f) retain];
    static UIColor *shadowBottom;
    if (!shadowBottom)
        shadowBottom = [[shadowTop colorWithAlphaComponent:0.1f] retain];
    _borderShadowColors = [[NSArray alloc] initWithObjects:(id)shadowTop.CGColor, (id)shadowBottom.CGColor, nil];
    
    if (!_strokeTopColor)
        _strokeTopColor = [DDColorWithRGBA(236, 239, 215, 1) retain];
    if (!_strokeBottomColor)
        _strokeBottomColor = [DDColorWithRGBA(100, 102, 92, 1) retain];

}

- (void)dealloc {
    self.titleColor = nil;
    self.titleFont = nil;
    self.titleLabel = nil;
    self.borderShadowColors = nil;
    self.gradientColors = nil;
    self.strokeTopColor = nil;
    self.strokeBottomColor = nil;
    [super dealloc];
}

- (CGFloat)opticalHeight {
    return kTitleBarHeight - 5;
}

#pragma mark Layout & Redraw

- (void)layoutSubviews {
    const CGFloat offsetX = 12;
    const CGFloat offsetY = 10;
    CGFloat labelWidth = CGRectGetWidth(self.frame) - 55;
    const CGFloat labelHeight = kTitleBarHeight - (2*offsetY) - 5;
    self.titleLabel.frame = CGRectMake(offsetX, offsetY, labelWidth, labelHeight);
}

- (void)drawRect:(CGRect)rect {	
	[self drawLinearGradientInRect:CGRectMake(0, 0, rect.size.width, self.opticalHeight - 1 ) colors:_gradientColors];
    if (useGradientBorder)
        [self drawLinearGradientInRect:CGRectMake(0, self.opticalHeight, rect.size.width, _borderShadowHeight) colors:_borderShadowColors];
    [self drawLineInRect:CGRectMake(0, 0, rect.size.width, 0) color:_strokeTopColor.CGColor];
    [self drawLineInRect:CGRectMake(0, self.opticalHeight - .5, rect.size.width, 0) color:_strokeBottomColor.CGColor];      
}

- (void)drawLinearGradientInRect:(CGRect)rect colors:(NSArray *)colors {
    BOOL isConvex = NO;
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(rgb, (CFArrayRef)colors, NULL);
	CGColorSpaceRelease(rgb);
    CGFloat yStart = 0;
    CGFloat yEnd = rect.size.height;
    if (isConvex) {
        yStart = rect.size.height * 0.25;
        yEnd = rect.size.height * 0.75;
    }
	CGPoint start = CGPointMake(rect.origin.x, rect.origin.y + yStart);
	CGPoint end = CGPointMake(rect.origin.x, rect.origin.y + yEnd);
	CGContextClipToRect(context, rect);
    CGGradientDrawingOptions options = 0;
    if (isConvex)
        options = kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation;
	CGContextDrawLinearGradient(context, gradient, start, end, options);
	CGGradientRelease(gradient);
	CGContextRestoreGState(context);
}

- (void)drawLineInRect:(CGRect)rect color:(CGColorRef)strokeColor {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, strokeColor);
	CGContextSetLineCap(context, kCGLineCapButt);
	CGContextSetLineWidth(context, 1.5);
	CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
	CGContextStrokePath(context);
	CGContextRestoreGState(context);
}

#pragma mark Accessors

- (void)setUseGradientBorder:(BOOL)visible{
    useGradientBorder = visible;
    [self setNeedsDisplay];
}

- (void)setTitle:(NSString *)newTitle {
    self.titleLabel.text = newTitle;
    [self.titleLabel setNeedsDisplay];
    [self setNeedsDisplay];
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)setTitleColor:(UIColor *)titleColor {
    self.titleLabel.textColor = titleColor;
    [self.titleLabel setNeedsDisplay];
    [self setNeedsDisplay];
}

- (UIColor *)titleColor {
    return self.titleLabel.textColor;
}

- (void)setTitleFont:(UIFont *)titleFont {
    self.titleLabel.font = titleFont;
    [self.titleLabel setNeedsDisplay];
    [self setNeedsDisplay];
}

- (UIFont *)titleFont {
    return self.titleLabel.font;
}

#pragma UIAppearance accessors

- (void)setColor:(UIColor *)color forCollectionKey:(NSString *)propertyKey index:(NSInteger)index {
    NSArray *collection = [self valueForKey:propertyKey];
    NSMutableArray *colors = [NSMutableArray arrayWithArray:collection];
    [colors replaceObjectAtIndex:index withObject:(id)color.CGColor];
    [self setValue:colors forKey:propertyKey];
}

- (UIColor *)colorForCollectionKey:(NSString *)propertyKey index:(NSInteger)index {
    NSArray *collection = [self valueForKey:propertyKey];
    return [UIColor colorWithCGColor:(CGColorRef)[collection objectAtIndex:index]];
}

- (UIColor *)gradientTopColor {
    return [self colorForCollectionKey:@"gradientColors" index:0];
}

- (void)setGradientTopColor:(UIColor *)gradientTopColor {
    [self setColor:gradientTopColor forCollectionKey:@"gradientColors" index:0];
}

- (UIColor *)gradientBottomColor {
    return [self colorForCollectionKey:@"gradientColors" index:1];
}

- (void)setGradientBottomColor:(UIColor *)gradientBottomColor {
    [self setColor:gradientBottomColor forCollectionKey:@"gradientColors" index:1];
}

- (UIColor *)borderShadowTopColor {
    return [self colorForCollectionKey:@"borderShadowColors" index:0];
}

- (void)setBorderShadowTopColor:(UIColor *)borderShadowTopColor {
    [self setColor:borderShadowTopColor forCollectionKey:@"borderShadowColors" index:0];
}

- (UIColor *)borderShadowBottomColor {
    return [self colorForCollectionKey:@"borderShadowColors" index:1];
}

- (void)setBorderShadowBottomColor:(UIColor *)borderShadowBottomColor {
    [self setColor:borderShadowBottomColor forCollectionKey:@"borderShadowColors" index:1];
}

- (void)setBorderShadowHeight:(CGFloat)borderShadowHeight {
    _borderShadowHeight = borderShadowHeight;
    [self setNeedsDisplay];
}

- (CGFloat)borderShadowHeight {
    return _borderShadowHeight;
}

- (void)setStrokeTopColor:(UIColor *)strokeTopColor {
    SLFRelease(_strokeTopColor);
    _strokeTopColor = [strokeTopColor retain];
    if (strokeTopColor) {
        [self setNeedsDisplay];
    }
}

- (void)setStrokeBottomColor:(UIColor *)strokeBottomColor {
    SLFRelease(_strokeBottomColor);
    _strokeBottomColor = [strokeBottomColor retain];
    if (strokeBottomColor) {
        [self setNeedsDisplay];
    }
}
@end

UIColor *DDColorWithRGBA(int r, int g, int b, CGFloat a) {
    return [UIColor colorWithRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:a];
}