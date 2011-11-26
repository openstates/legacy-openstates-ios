//
//	DisclosureQuartzView.m
//  Created by Gregory Combs on 8/29/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "DisclosureQuartzView.h"
#import <QuartzCore/QuartzCore.h>
#import "SLFAppearance.h"

const CGFloat kDisclosureDiameter = 28.0f;
static CGFloat scaleMod = 0;

@implementation DisclosureQuartzView

- (id)initWithFrame:(CGRect)frame
{        
	self = [super initWithFrame:frame];
	if (self) {
		[self setOpaque:NO];
		
        if (scaleMod < 1) {    // so that we only do this once, it's expensive...
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
                scaleMod =  [[UIScreen mainScreen] scale];
            else
                scaleMod = 1;
        }
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
	return CGSizeMake(kDisclosureDiameter, kDisclosureDiameter);
}

- (void)drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, kDisclosureDiameter, kDisclosureDiameter);
	CGRect bounds = [self bounds];
	CGContextRef context = UIGraphicsGetCurrentContext();
	size_t bytesPerRow;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGFloat stroke;
	CGMutablePathRef path = nil;
	CGRect drawRect;
	UIColor *color;
        //	CGAffineTransform transform;
	NSString *string;
	UIFont *font;
	CGImageRef contextImage = nil;
	CGRect effectBounds;
	CGContextRef maskContext = nil;
	CGImageRef maskImage = nil;
	CGDataProviderRef provider = nil;
	NSData *data = nil;
	void *bitmapData = nil;
		
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	
	// DisclosureGroup
	
	// Setup for Inner Shadow Effect
	bytesPerRow = scaleMod * 4 * roundf(bounds.size.width);

	bitmapData = calloc(bytesPerRow * round(bounds.size.height), 8);
	context = CGBitmapContextCreate(bitmapData, scaleMod*round(bounds.size.width), scaleMod*round(bounds.size.height), 8, bytesPerRow, space, kCGImageAlphaPremultipliedLast);

	UIGraphicsPushContext(context);
	CGContextScaleCTM(context, scaleMod, scaleMod);
	
	// Disclosure
	
	stroke = 2.f;
	path = CGPathCreateMutable();
	
	drawRect = CGRectMake(1.0f, 1.0f, kDisclosureDiameter-2, kDisclosureDiameter-2);
	CGPathAddEllipseInRect(path, NULL, drawRect);
	[[UIColor whiteColor] setFill];
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	color = [UIColor colorWithRed:0.811f green:0.82f blue:0.845f alpha:1.0f];
	[color setStroke];
	CGContextSetLineWidth(context, stroke);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);
	
	drawRect = CGRectMake(8.0f, 0.0f, 20.0f, 30.0f);

	string = @">";
	font = [UIFont fontWithName:@"HiraKakuProN-W6" size:26.0f];
	color = [UIColor colorWithRed:116/255.0 green:174/255.0 blue:165/255.0 alpha:1.0];
	[color set];
	[string drawInRect:drawRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
	
	// Inner Shadow Effect
	bitmapData = (unsigned char *)CGBitmapContextGetData(context);

	contextImage = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	free(bitmapData);

	UIGraphicsPopContext();
	context = UIGraphicsGetCurrentContext();
	CGContextDrawImage(context, imageBounds, contextImage);
    
    CGContextSaveGState(context);
    effectBounds = bounds;
    CGFloat effectOffset = 3.f;
    CGFloat effectBlur = 4.f;
    CGFloat effectInsetX = -effectBlur;
    CGFloat effectInsetY = -(effectOffset + effectBlur);
    effectBounds = CGRectInset(effectBounds, effectInsetX, effectInsetY);
    effectBounds = CGRectIntegral(effectBounds);
    color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
    CGSize shadowOffset = CGSizeMake(0, -(effectBounds.size.height-effectOffset));
    CGContextSetShadowWithColor(context, shadowOffset, effectBlur, [color CGColor]);
    bytesPerRow = effectBounds.size.width;
    bitmapData = calloc(bytesPerRow * effectBounds.size.height, 8);
    maskContext = CGBitmapContextCreate(bitmapData, effectBounds.size.width, effectBounds.size.height, 8, bytesPerRow, NULL, kCGImageAlphaOnly);
    CGContextDrawImage(maskContext, CGRectMake(-effectBounds.origin.x, -effectBounds.origin.y, bounds.size.width, bounds.size.height), contextImage);
    maskImage = CGBitmapContextCreateImage(maskContext);
    data = [NSData dataWithBytes:bitmapData length:bytesPerRow * effectBounds.size.height];
    provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGImageRelease(contextImage);
    contextImage = CGImageMaskCreate(effectBounds.size.width, effectBounds.size.height, 8, 8, bytesPerRow, provider, NULL, 0);
    CGDataProviderRelease(provider);
    CGContextRelease(maskContext);
    CGContextClipToMask(context, effectBounds, maskImage);
    CGImageRelease(maskImage);
    effectBounds.origin.y += effectBounds.size.height;
    [[UIColor blackColor] setFill];
    CGContextDrawImage(context, effectBounds, contextImage);
    free(bitmapData);

    CGContextRestoreGState(context);

	CGImageRelease(contextImage);
	
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
}

@end
