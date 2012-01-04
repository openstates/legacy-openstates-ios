//
//  SLFAlertView.m (Excerpted from "iOS Recipes" by The Pragmatic Bookshelf)
//  Created by Gregory Combs on 3/14/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFAlertView.h"

@interface SLFAlertView ()

@property (nonatomic, copy) SLFAlertBlock cancelBlock;
@property (nonatomic, copy) SLFAlertBlock otherBlock;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, copy) NSString *otherButtonTitle;
@property (nonatomic, retain) UIColor *fillColor;
@property (nonatomic, retain) UIColor *shadowColor;
- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message 
        cancelTitle:(NSString *)cancelTitle 
        cancelBlock:(SLFAlertBlock)cancelBlock
         otherTitle:(NSString *)otherTitle
         otherBlock:(SLFAlertBlock)otherBlock;

@end

@implementation SLFAlertView

@synthesize cancelBlock;
@synthesize otherBlock;
@synthesize cancelButtonTitle;
@synthesize otherButtonTitle;
@synthesize fillColor = _fillColor;
@synthesize shadowColor = _shadowColor;

+ (void)showWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle {
    [self showWithTitle:title message:message cancelTitle:buttonTitle cancelBlock:nil otherTitle:nil otherBlock:nil];
}

+ (void)showWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle cancelBlock:(SLFAlertBlock)cancelBlk otherTitle:(NSString *)otherTitle otherBlock:(SLFAlertBlock)otherBlk {
    SLFAlertView *alert = [[SLFAlertView alloc] initWithTitle:title message:message cancelTitle:cancelTitle cancelBlock:cancelBlk otherTitle:otherTitle otherBlock:otherBlk];
    [alert show];
    [alert autorelease];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle cancelBlock:(SLFAlertBlock)cancelBlk otherTitle:(NSString *)otherTitle otherBlock:(SLFAlertBlock)otherBlk {
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:otherTitle, nil];
    if (self) {
        if (cancelBlk == nil && otherBlk == nil) {
            self.delegate = nil;
        }
        self.cancelButtonTitle = cancelTitle;
        self.otherButtonTitle = otherTitle;
        self.cancelBlock = cancelBlk;
        self.otherBlock = otherBlk;
        self.shadowColor = [UIColor blackColor];
        self.fillColor = SLFColorWithRGB(210, 210, 210);
    }
    return self;
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:self.cancelButtonTitle]) {
        if (self.cancelBlock) self.cancelBlock();
    } else if ([buttonTitle isEqualToString:self.otherButtonTitle]) {
        if (self.otherBlock) self.otherBlock();
    }
}

- (void)dealloc {
    self.fillColor = nil;
    self.shadowColor = nil;
    [cancelButtonTitle release], cancelButtonTitle = nil;
    [otherButtonTitle release], otherButtonTitle = nil;
    [cancelBlock release], cancelBlock = nil;
    [otherBlock release], otherBlock = nil;
    [super dealloc];
}

#pragma mark - Customized Graphics

/* Lifted straight from Aaron Crabtree's demo at http://mobile.tutsplus.com/tutorials/iphone/ios-sdk-uialertview-custom-graphics/ */

- (void)layoutSubviews
{
    for (UIView *subview in self.subviews){
        if ([subview isMemberOfClass:[UIImageView class]]) {
            subview.hidden = YES; //Hide UIImageView Containing Blue Background
        }
        if ([subview isMemberOfClass:[UILabel class]]) {
            UILabel *label = (UILabel*)subview;
            label.textColor = _fillColor;
            label.shadowColor = _shadowColor;
            label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        }
    }
}

- (CGPathRef)createShapeForContext:(CGContextRef)context {
    CGRect activeBounds = self.bounds;
    CGFloat cornerRadius = 10.0f;
    CGFloat inset = 6.5f;
    CGFloat originX = activeBounds.origin.x + inset;
    CGFloat originY = activeBounds.origin.y + inset;
    CGFloat width = activeBounds.size.width - (inset*2.0f);
    CGFloat height = activeBounds.size.height - (inset*2.0f);
    CGRect bPathFrame = CGRectMake(originX, originY, width, height);
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:bPathFrame cornerRadius:cornerRadius].CGPath;
    CGContextAddPath(context, path);
    return path;
}

- (void)createFillAndShadowForContext:(CGContextRef)context {
    CGContextSetFillColorWithColor(context, _fillColor.CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 6.0f, _shadowColor.CGColor);
    CGContextDrawPath(context, kCGPathFill);
}

- (void)clipPath:(CGPathRef)path forContext:(CGContextRef)context {
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
}

- (void)drawGradientForContext:(CGContextRef)context {
    CGRect activeBounds = self.bounds;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t count = 3;
    CGFloat locations[3] = {0.0f, 0.57f, 1.0f};
    CGFloat components[12] =
    {
        99.0f/255.0f, 100.0f/255.0f, 89.0f/255.0f, 1.0f,
        79.0f/255.0f, 80.0f/255.0f, 72.0f/255.0f, 1.0f,
        69.0f/255.0f, 70.0f/255.0f, 62.0f/255.0f, 1.0f, 
    };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, count);
    CGPoint startPoint = CGPointMake(activeBounds.size.width * 0.5f, 0.0f);
    CGPoint endPoint = CGPointMake(activeBounds.size.width * 0.5f, activeBounds.size.height);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

static CGFloat const kButtonOffset = 92.5f; //Offset buttonOffset by half point for crisp lines

- (void)drawBackgroundPatternForContext:(CGContextRef)context {
    CGRect activeBounds = self.bounds;
    CGContextSaveGState(context);
    CGRect hatchFrame = CGRectMake(0.0f, kButtonOffset, activeBounds.size.width, (activeBounds.size.height - kButtonOffset+1.0f));
    CGContextClipToRect(context, hatchFrame);
    CGFloat spacer = 4.0f;
    int rows = (activeBounds.size.width + activeBounds.size.height/spacer);
    CGFloat padding = 0.0f;
    CGMutablePathRef hatchPath = CGPathCreateMutable();
    for(int i=1; i<=rows; i++) {
        CGPathMoveToPoint(hatchPath, NULL, spacer * i, padding);
        CGPathAddLineToPoint(hatchPath, NULL, padding, spacer * i);
    }
    CGContextAddPath(context, hatchPath);
    CGPathRelease(hatchPath);
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0 alpha:.15f].CGColor);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
}

- (void)drawSeparatorForContext:(CGContextRef)context {
    CGRect activeBounds = self.bounds;
    CGMutablePathRef linePath = CGPathCreateMutable();
    CGFloat linePathY = (kButtonOffset - 1.0f);
    CGPathMoveToPoint(linePath, NULL, 0.0f, linePathY);
    CGPathAddLineToPoint(linePath, NULL, activeBounds.size.width, linePathY);
    CGContextAddPath(context, linePath);
    CGPathRelease(linePath);
    CGContextSetLineWidth(context, 1.0f);
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0 alpha:.6f].CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 0.0f, [UIColor colorWithWhite:1 alpha:.2f].CGColor);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
}

- (void)drawInnerShadowWithPath:(CGPathRef)path forContext:(CGContextRef)context {
    CGContextAddPath(context, path);
    CGContextSetLineWidth(context, 3.0f);
    CGContextSetStrokeColorWithColor(context, _fillColor.CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 6.0f, _shadowColor.CGColor);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)redrawPath:(CGPathRef)path forContext:(CGContextRef)context {
    CGContextRestoreGState(context);
    CGContextAddPath(context, path);
    CGContextSetLineWidth(context, 3.0f);
    CGContextSetStrokeColorWithColor(context, _fillColor.CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 0.0f, [UIColor colorWithWhite:0 alpha:.1f].CGColor);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPathRef path = [self createShapeForContext:context];
    [self createFillAndShadowForContext:context];
    [self clipPath:path forContext:context];
    [self drawGradientForContext:context];
    [self drawBackgroundPatternForContext:context];
    [self drawInnerShadowWithPath:path forContext:context];
    [self redrawPath:path forContext:context];
}


@end