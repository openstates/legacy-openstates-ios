//
//  OpenStatesTitleView.m
//  Created by Greg Combs on 11/13/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "OpenStatesTitleView.h"

const CGFloat kOpenStatesTitleViewWidth = 395.0f;
const CGFloat kOpenStatesTitleViewHeight = 42.0f;

@interface OpenStatesTitleView()
- (void)configure;
@end

@implementation OpenStatesTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)configure {
    self.contentMode = UIViewContentModeRedraw;
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    self.opaque = NO;
    self.layer.shouldRasterize = YES;
    /*
    self.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.375] CGColor];
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowOpacity = 1.f;
    self.layer.shadowRadius = 2.0f;
     */
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(kOpenStatesTitleViewWidth, kOpenStatesTitleViewHeight);
}

- (CGFloat)scaleDimension:(CGFloat)dimension withScale:(CGFloat)scale {
    if (scale <= 0)
        return 0;
    return roundf((scale * dimension) / scale);
}

- (CGRect)scaleRect:(CGRect)drawRect withScale:(CGFloat)scale {
    drawRect.origin.x = [self scaleDimension:CGRectGetMinX(drawRect) withScale:scale];
    drawRect.origin.y = [self scaleDimension:CGRectGetMinY(drawRect) withScale:scale];
    drawRect.size.width = [self scaleDimension:CGRectGetWidth(drawRect) withScale:scale];
    drawRect.size.height = [self scaleDimension:CGRectGetHeight(drawRect) withScale:scale];
    return drawRect;
}

- (void)drawRect:(CGRect)viewBounds
{
    viewBounds = CGRectIntegral(viewBounds);
    CGRect imageBounds = CGRectMake(0.0f, 0.0f, kOpenStatesTitleViewWidth, kOpenStatesTitleViewHeight);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path;
    CGFloat widthRatio = CGRectGetWidth(viewBounds) / CGRectGetWidth(imageBounds);
    CGFloat heightRatio = CGRectGetHeight(viewBounds) / CGRectGetHeight(imageBounds);
    CGFloat scale = 0.5f * (widthRatio + heightRatio);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, viewBounds.origin.x, viewBounds.origin.y);
    CGContextScaleCTM(context, widthRatio, heightRatio);
    
    // Text
    
    static UIFont *textFont;
    if (!textFont)
        textFont = [[UIFont fontWithName:@"BlairMdITC TT" size:39.0f] retain];
    static UIColor *textColor;
    if (!textColor)
        textColor = [[UIColor colorWithRed:0.215f green:0.209f blue:0.205f alpha:1.0f] retain];
    [textColor set];
    CGFloat y = -4.0f;
	CGFloat height = 60.0f;
	
    // StatesText
    
    CGRect drawRect = [self scaleRect:CGRectMake(182.0f, y, 216.0f, height) withScale:scale];
    NSString *string = @"STATES";
    [string drawInRect:drawRect withFont:textFont];
    
    // OpenText
    
    drawRect = [self scaleRect:CGRectMake(1.0f, y, 166.0f, height) withScale:scale];
    string = @"OPEN";
    [string drawInRect:drawRect withFont:textFont];
    
    // Colon

    static UIColor *colonColor;
    if (!colonColor)
        colonColor = [[UIColor colorWithRed:0.827f green:0.435f blue:0.161f alpha:1.0f] retain];
	height = 8.0f;
	CGFloat width = height;
	CGFloat x = 166.0f;
	
    // BottomColon
    
    path = CGPathCreateMutable();
    drawRect = [self scaleRect:CGRectMake(x, 27.0f, width, height) withScale:scale];
    CGPathAddEllipseInRect(path, NULL, drawRect);
    [colonColor setFill];
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGPathRelease(path);
    
    // TopColon
    
    path = CGPathCreateMutable();
    drawRect = [self scaleRect:CGRectMake(x, 6.0f, width, height) withScale:scale];
    CGPathAddEllipseInRect(path, NULL, drawRect);
    [colonColor setFill];
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGPathRelease(path);
    
    CGContextRestoreGState(context);
}

@end
