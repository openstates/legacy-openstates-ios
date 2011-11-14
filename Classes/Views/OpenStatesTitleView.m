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

@implementation OpenStatesTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setOpaque:NO];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setOpaque:NO];
    }
    return self;
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
    
    UIFont *font = [UIFont fontWithName:@"BlairMdITC TT" size:39.0f];
    UIColor *fontColor = [UIColor colorWithRed:0.215f green:0.209f blue:0.205f alpha:1.0f];
    [fontColor set];
    CGFloat y = -4.0f;
	CGFloat height = 60.0f;
	
    // StatesText
    
    CGRect drawRect = [self scaleRect:CGRectMake(182.0f, y, 216.0f, height) withScale:scale];
    NSString *string = @"STATES";
    [string drawInRect:drawRect withFont:font];
    
    // OpenText
    
    drawRect = [self scaleRect:CGRectMake(1.0f, y, 166.0f, height) withScale:scale];
    string = @"OPEN";
    [string drawInRect:drawRect withFont:font];
    
    // Colon

    UIColor *colonColor = [UIColor colorWithRed:0.827f green:0.435f blue:0.161f alpha:1.0f];
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
