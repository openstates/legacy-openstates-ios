//
//  UIColor+SLUtils
//  SLToastKit
//
//  Created by Greg Combs
//

#import "UIColor+SLUtils.h"
#import "SLTypeCheck.h"

const static CGFloat SLColorUndefinedHue = -1.0f;

const SLColorHSBComponents SLInvalidHSB = {
    .hue = -1,
    .saturation = -1,
    .brightness = -1,
    .alpha = 0
};

const SLColorRGBComponents SLColorInvalidRGB = {
    .red = -1,
    .green = -1,
    .blue = -1,
    .alpha = 0
};

BOOL SLColorIsValidRGB(SLColorRGBComponents rgb) {
    SLColorRGBComponents invalidRGB = SLColorInvalidRGB;
    return (rgb.red != invalidRGB.red
            && rgb.green != invalidRGB.green
            && rgb.blue != invalidRGB.blue
            && rgb.alpha >= 0.0);
}

BOOL SLColorIsValidHSB(SLColorHSBComponents hsb) {
    SLColorHSBComponents invalidHSB = SLInvalidHSB;
    return (hsb.hue != invalidHSB.hue
            && hsb.saturation != invalidHSB.saturation
            && hsb.brightness != invalidHSB.brightness
            && hsb.alpha >= 0.0);
}

@interface NSString (SLUtils)

- (unsigned int)slColorHexValue;

@end

@implementation NSString (SLUtils)

- (unsigned int)slColorHexValue
{
	unsigned int result = 0;
	sscanf([self UTF8String], "%x", &result);
	return result;
}

@end


@implementation UIColor (SLUtils)

#pragma mark -

- (NSString *)debugDescription
{
    SLColorRGBComponents rgb = [self rgbComponents];
    NSString *r = [NSString stringWithFormat:@"R: %.0f #%0X - %.2f", rgb.red*255, (int)(rgb.red*255), rgb.red];
    NSString *g = [NSString stringWithFormat:@"G: %.0f #%0X - %.2f", rgb.green*255, (int)(rgb.green*255), rgb.green];
    NSString *b = [NSString stringWithFormat:@"B: %.0f #%0X - %.2f", rgb.blue*255, (int)(rgb.blue*255), rgb.blue];
    NSString *a = [NSString stringWithFormat:@"A: %.2f", rgb.alpha];
    NSString *rgbHex = [NSString stringWithFormat:@"#%X%X%X", (int)(rgb.red*255),(int)(rgb.green*255),(int)(rgb.blue*255)];
    return [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",r,g,b,a,rgbHex];
}

#pragma mark - Hexidecimal Color

+ (UIColor *)slColorWithHex:(unsigned)hex
{
    return [self r:((hex&0xFF0000)>>16) g:((hex&0x00FF00)>>8) b:(hex&0x0000FF)];
}

+ (NSString *)hexStringByRemovingInvalidCharacters:(NSString *)hexString
{
    if (!SLTypeNonEmptyStringOrNil(hexString))
        return nil;
    static NSCharacterSet *invalidHexChars = nil;
    if (!invalidHexChars)
    {
        NSCharacterSet *validHexChars = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdef"];
        invalidHexChars = [validHexChars invertedSet];
    }
    return [[hexString componentsSeparatedByCharactersInSet:invalidHexChars] componentsJoinedByString:@""];
}

+ (UIColor *)slColorWithHexString:(NSString *)hexString
{
    if (!SLTypeNonEmptyStringOrNil(hexString))
        return nil;

    if ([hexString hasPrefix:@"#"])
		hexString = [hexString substringFromIndex:1];
	else if ([hexString hasPrefix:@"0x"])
		hexString = [hexString substringFromIndex:2];

    hexString = [hexString lowercaseString];

    if ([hexString isEqualToString:@"clear"])
        return [UIColor clearColor];
    if ([hexString isEqualToString:@"black"])
        return [UIColor blackColor];
    if ([hexString isEqualToString:@"white"])
        return [UIColor whiteColor];
    if ([hexString isEqualToString:@"red"])
        return [UIColor redColor];

    hexString = [self hexStringByRemovingInvalidCharacters:hexString];

    NSUInteger length = [hexString length];
	if (length != 3
        && length != 6
        && length != 8)
    {
		return nil;
	}

	if (length == 3)
    {
		NSString *r = [hexString substringWithRange:NSMakeRange(0, 1)];
		NSString *g = [hexString substringWithRange:NSMakeRange(1, 1)];
		NSString *b = [hexString substringWithRange:NSMakeRange(2, 1)];
		hexString = [NSString stringWithFormat:@"%@%@%@%@%@%@ff", r, r, g, g, b, b];
	}
    else if (length == 6)
    {
		hexString = [hexString stringByAppendingString:@"ff"];
    }

	CGFloat red = [[hexString substringWithRange:NSMakeRange(0, 2)] slColorHexValue] / 255.0f;
	CGFloat green = [[hexString substringWithRange:NSMakeRange(2, 2)] slColorHexValue] / 255.0f;
	CGFloat blue = [[hexString substringWithRange:NSMakeRange(4, 2)] slColorHexValue] / 255.0f;
	CGFloat alpha = [[hexString substringWithRange:NSMakeRange(6, 2)] slColorHexValue] / 255.0f;

	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)r:(int)r g:(int)g b:(int)b a:(CGFloat)a 
{
    return [UIColor colorWithRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:a];
}

+ (UIColor *)r:(int)r g:(int)g b:(int)b 
{
    return [self r:r g:g b:b a:1.0f];
}

#pragma mark - Color Math

- (UIColor *)slColorWithRGBShift:(int)offset
{
    @try {
        CGFloat r,g,b,a;
        CGFloat shift = offset / 255.f;
        if (![self getRed:&r green:&g blue:&b alpha:&a])
            return self;
        return [UIColor colorWithRed:MAX(0.0, MIN(1.0, r + shift))
                               green:MAX(0.0, MIN(1.0, g + shift))
                                blue:MAX(0.0, MIN(1.0, b + shift)) alpha:a];
    }
    @catch (NSException *exception) {
        return self;
    }
}

- (UIColor *)slColorByInterpolatingTo:(UIColor*)secondColor ratio:(double)ratio
{
    return [self slColorByBlendingWith:secondColor ratio:ratio blendAlpha:YES];
}

- (UIColor *)slColorByBlendingWith:(UIColor *)secondColor ratio:(double)ratio blendAlpha:(BOOL)blendAlpha
{
    if (ratio <= 0.001)
        return self;
    if (ratio >= 0.999)
        return secondColor;

    NSAssert(self.canProvideRGBComponents, @"Self must be a RGB color to use arithmatic operations");
    NSAssert(secondColor.canProvideRGBComponents, @"Color must be a RGB color to use arithmatic operations");

    CGFloat r1, g1, b1, a1;
    if (![self getRed:&r1 green:&g1 blue:&b1 alpha:&a1])
        return nil;

    CGFloat r2,g2,b2,a2;
    if (![secondColor getRed:&r2 green:&g2 blue:&b2 alpha:&a2])
        return nil;

    CGFloat r3 = (r2 - r1) * ratio + r1;
    CGFloat g3 = (g2 - g1) * ratio + g1;
    CGFloat b3 = (b2 - b1) * ratio + b1;
    CGFloat a3 = (blendAlpha) ? (a2 - a1) * ratio + a1 : 1;

    return [UIColor colorWithRed:r3 green:g3 blue:b3 alpha:a3];
}

+ (UIColor *)slColorInterpolatedForValue:(id)value colors:(NSArray *)colors boundaries:(NSArray *)boundaries gradient:(BOOL)useGradient
{
    if (!value || !colors || !colors.count)
    {
        return nil;
    }
    if (colors.count == 1)
    {
        return colors[0];
    }
    if (!boundaries || !boundaries.count)
    {
        return nil;
    }

    if (!useGradient)   // use discrete color interpolation (i.e. categorical colors)
    {
        if (boundaries.count != (colors.count - 1))
        {
            return nil;
        }
        for (NSInteger i=0; i < boundaries.count; i++) 
        {
            if ([value compare:boundaries[i]] == NSOrderedAscending) 
            {
                return colors[i];
            }
        }
        return [colors lastObject];
    }

    // use gradient interpolation

    if (boundaries.count != colors.count)
    {
        return nil;
    }
    
    // If lower than first boundary, return first color
    if ([value compare:boundaries[0]] == NSOrderedAscending)
    {
        return colors[0];
    }
    // If higher than last boundary, return last color
    if ([value compare:[boundaries lastObject]] == NSOrderedDescending ||
        [value compare:[boundaries lastObject]] == NSOrderedSame)
    {
        return [colors lastObject];
    }
    // Otherwise, return an interpolated gradient color
    for (NSInteger i=1; i < boundaries.count; i++) 
    {
        if ([value compare:boundaries[i]] == NSOrderedAscending) 
        {
            // So the mix should be between the (i-1)th and ith colors
            double range = [boundaries[i] doubleValue] - [boundaries[i-1] doubleValue];
            double ratio = ([value doubleValue] - [boundaries[i-1] doubleValue]) / range;
            UIColor *firstColor = colors[i-1];
            UIColor *secondColor = colors[i];
            return [firstColor slColorByInterpolatingTo:secondColor ratio:ratio];
        }
    }
    // Should never be able to get here...
    return nil;
}

- (UIColor *)slMultiplyHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness
{
    SLColorHSBComponents hsb = [self hsbComponents];

    hsb.hue *= hue;
    hsb.saturation *= saturation;
    hsb.brightness *= brightness;

    SLColorRGBComponents rgb = [UIColor SLColorRGBForHSB:hsb];

    return [UIColor colorWithRed:rgb.red green:rgb.green blue:rgb.blue alpha:rgb.alpha];
}

- (UIColor *)slAddHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness
{
    SLColorHSBComponents hsb = [self hsbComponents];

    hsb.hue += hue;
    hsb.saturation += saturation;
    hsb.brightness += brightness;

    SLColorRGBComponents rgb = [UIColor SLColorRGBForHSB:hsb];

    return [UIColor colorWithRed:rgb.red green:rgb.green blue:rgb.blue alpha:rgb.alpha];
}

- (UIColor*)slHighlight {
    return [self slMultiplyHue:1 saturation:.5 brightness:1.2];
}

- (UIColor*)slShadow
{
    return [self slMultiplyHue:1 saturation:.6 brightness:0.6];
}

- (CGFloat)slLuminance
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use luminance");

	SLColorRGBComponents rgb = [self rgbComponents];

	// http://en.wikipedia.org/wiki/Luma_(video)
	// Y = 0.2126 R + 0.7152 G + 0.0722 B

	return rgb.red*0.2126f + rgb.green*0.7152f + rgb.blue*0.0722f;
}

- (CGFloat)slBrightness
{
	SLColorHSBComponents hsb = [self hsbComponents];

	return hsb.brightness;
}

- (UIColor *)slColorWithBrightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
	SLColorHSBComponents hsb = [self hsbComponents];
	hsb.brightness = brightness;
    hsb.alpha = alpha;
    return [UIColor SLColorForHSB:hsb];
}

- (UIColor *)slColorWithBrightness:(CGFloat)brightness
{
	SLColorHSBComponents hsb = [self hsbComponents];
	hsb.brightness = brightness;
    return [UIColor SLColorForHSB:hsb];
}

- (UIColor *)slContrastingColor
{
	return (self.slLuminance > 0.5f) ? [UIColor blackColor] : [UIColor whiteColor];
}

- (UIColor *)slWhiteOrContrastingColor
{
	return (self.slLuminance > 0.8f) ? [UIColor blackColor] : [UIColor whiteColor];
}

// Pick the color that is 180 degrees away in hue
- (UIColor *)slComplementaryColor
{

	// Convert to HSB
	SLColorHSBComponents hsb = [self hsbComponents];

	// Pick color 180 degrees away
	hsb.hue += 180.0f;
	if (hsb.hue > 360.f)
        hsb.hue -= 360.0f;

    return [UIColor SLColorForHSB:hsb];
}

#pragma mark - Private Color Algebra

- (BOOL)canProvideRGBComponents
{
    switch (CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor)))
    {
        case kCGColorSpaceModelRGB:
        case kCGColorSpaceModelMonochrome:
            return YES;
        default:
            return NO;
    }
}

// Pick n pairs of colors, stepping in increasing steps away from this color around the wheel
- (NSArray*)slAnalogousColorsWithStepAngle:(CGFloat)stepAngle pairCount:(NSInteger)pairs
{
	SLColorHSBComponents hsb = [self hsbComponents];

	NSMutableArray *colors = [NSMutableArray arrayWithCapacity:pairs * 2];

	if (stepAngle < 0.0f)
		stepAngle *= -1.0f;

	for (NSInteger i = 1; i <= pairs; ++i) 
	{
		CGFloat a = fmodf(stepAngle * i, 360.0f);

		CGFloat h1 = fmodf(hsb.hue + a, 360.0f);
		CGFloat h2 = fmodf(hsb.hue + 360.0f - a, 360.0f);

        SLColorHSBComponents hsb1 = hsb;
        hsb1.hue = h1;
        hsb1.alpha = a;
        UIColor *color1 = [UIColor SLColorForHSB:hsb1];

        SLColorHSBComponents hsb2 = hsb;
        hsb2.hue = h2;
        hsb2.alpha = a;
        UIColor *color2 = [UIColor SLColorForHSB:hsb2];

        if (color1) {
            [colors addObject:color1];
        }
        if (color2) {
            [colors addObject:color2];
        }
	}
    
	return [colors copy];
}

#define MAX3(a,b,c) (a > b ? (a > c ? a : c) : (b > c ? b : c))
#define MIN3(a,b,c) (a < b ? (a < c ? a : c) : (b < c ? b : c))

+ (SLColorHSBComponents)SLColorHSBForRGB:(SLColorRGBComponents)rgb
{
	SLColorHSBComponents result;
    result.alpha = rgb.alpha;

    CGFloat min = MIN3(rgb.red, rgb.green, rgb.blue);
    CGFloat max = MAX3(rgb.red, rgb.green, rgb.blue);

    result.brightness = max;
    CGFloat delta = max - min;

    if ( max != 0 )
        result.saturation = delta / max;
    else {
        // r = g = b = 0    // s = 0, v is undefined
        result.saturation = 0;
        result.hue = SLColorUndefinedHue;
        return result;
    }
    if ( rgb.red == max )
        result.hue = ( rgb.green - rgb.blue ) / delta;    // between yellow & magenta
    else if ( rgb.green == max )
        result.hue = 2 + ( rgb.blue - rgb.red ) / delta;  // between cyan & yellow
    else
        result.hue = 4 + ( rgb.red - rgb.green ) / delta;  // between magenta & cyan
    result.hue *= 60;        // degrees
    if ( result.hue < 0 )
        result.hue += 360;

	return result;
}

+ (SLColorRGBComponents)SLColorRGBForHSB:(SLColorHSBComponents)hsb
{
	SLColorRGBComponents result;
    result.alpha = hsb.alpha;

    if (hsb.hue == SLColorUndefinedHue || hsb.saturation == 0)
	{
        // achromatic (grey)
		CGFloat v = hsb.brightness;

		result.red = v;
		result.green = v;
		result.blue = v;
	}
	else {
		CGFloat h = hsb.hue / 60.0f;
		CGFloat s = hsb.saturation;
		CGFloat b = hsb.brightness;

		NSInteger i = (NSInteger)floorf(h);
		CGFloat f = h - i; // factorial part of hue
		if (! (i & 1)) 
		{
			// i is even
			f = 1 - f;
		}

		CGFloat m = b * (1.0f - s);
		CGFloat n = b * (1.0f - s * f);

		switch (i) {
			case 6:
			case 0:
				result.red = b;
				result.green = n;
				result.blue = m;
				break;
			case 1:
				result.red = n;
				result.green = b;
				result.blue = m;
				break;
			case 2:
				result.red = m;
				result.green = b;
				result.blue = n;
				break;
			case 3:
				result.red = m;
				result.green = n;
				result.blue = b;
				break;
			case 4:
				result.red = n;
				result.green = m;
				result.blue = b;
				break;
			case 5:
				result.red = b;
				result.green = m;
				result.blue = n;
				break;
		}
	}

	return result;
}

- (SLColorRGBComponents)rgbComponents
{
    SLColorRGBComponents result;

	CGColorRef colorRef = [self CGColor];
	CGColorSpaceRef colorSpaceRef = CGColorGetColorSpace(colorRef);
	CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpaceRef);
	size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpaceRef);
	if (colorSpaceModel == kCGColorSpaceModelRGB && numberOfComponents == 3) {
		const CGFloat *components = CGColorGetComponents(colorRef);
		result.red = components[0];
		result.green = components[1];
		result.blue = components[2];
	}
	else if (colorSpaceModel == kCGColorSpaceModelMonochrome && numberOfComponents == 1) 
	{
		const CGFloat *components = CGColorGetComponents(colorRef);
		result.red = components[0];
		result.green = components[0];
		result.blue = components[0];
	}
	else
	{
		// unknown color space
		result.red = 0.0f;
		result.green = 0.0f;
		result.blue = 0.0f;
	}
    result.alpha = CGColorGetAlpha(colorRef);
	return result;
}

- (SLColorHSBComponents)hsbComponents
{
	return [UIColor SLColorHSBForRGB:[self rgbComponents]];
}

+ (UIColor *)SLColorForRGB:(SLColorRGBComponents)rgb
{
    return [UIColor colorWithRed:rgb.red green:rgb.green blue:rgb.blue alpha:rgb.alpha];
}

+ (UIColor *)SLColorForHSB:(SLColorHSBComponents)hsb
{
    SLColorRGBComponents rgb = [self SLColorRGBForHSB:hsb];
    return [UIColor colorWithRed:rgb.red green:rgb.green blue:rgb.blue alpha:rgb.alpha];
}

# pragma mark - HSL colors

- (UIColor *)slMultiplyHue:(CGFloat)hue saturation:(CGFloat)saturation lightness:(CGFloat)lightness
{
    SLColorHSBComponents hsl = [self hslComponents];

    hsl.hue *= hue;
    hsl.saturation *= saturation;
    hsl.brightness *= lightness;

    SLColorRGBComponents rgb = [self SLColorRGBForHSL:hsl];
    return [UIColor colorWithRed:rgb.red green:rgb.green blue:rgb.blue alpha:rgb.alpha];
}

- (SLColorHSBComponents)hslComponents
{
    SLColorRGBComponents rgb = [self rgbComponents];
    SLColorHSBComponents hslResult;
    hslResult.alpha = rgb.alpha;

    CGFloat r = rgb.red;
    CGFloat g = rgb.green;
    CGFloat b = rgb.blue;

    CGFloat h,s, l, v, m, vm, r2, g2, b2;
    h = 0;
    s = 0;

    v = MAX(r, g);
    v = MAX(v, b);
    m = MIN(r, g);
    m = MIN(m, b);

    l = (m+v)/2.0f;
    // too dark
    if (l <= 0.0){
        hslResult.hue = h;
        hslResult.saturation = s;
        hslResult.brightness = l;
        return hslResult;
    }

    vm = v - m;
    s = vm;

    if (s > 0.0f) {
        s/= (l <= 0.5f) ? (v + m) : (2.0 - v - m);
    }
    else {
        hslResult.hue = h;
        hslResult.saturation = s;
        hslResult.brightness = l;
        return hslResult;
    }

    r2 = (v - r)/vm;
    g2 = (v - g)/vm;
    b2 = (v - b)/vm;

    if (r == v) {
        h = (g == m ? 5.0f + b2 : 1.0f - g2);
    } else if (g == v) {
        h = (b == m ? 1.0f + r2 : 3.0 - b2);
    } else {
        h = (r == m ? 3.0f + g2 : 5.0f - r2);
    }

    h/=6.0f;

    hslResult.hue = h;
    hslResult.saturation = s;
    hslResult.brightness = l;
    return hslResult;
}

- (SLColorRGBComponents)SLColorRGBForHSL:(SLColorHSBComponents)hsl
{
    SLColorRGBComponents rgbResult;
    rgbResult.alpha = hsl.alpha;

    CGFloat	temp1, temp2;
    CGFloat	temp[3];
    NSInteger i;

    CGFloat h = hsl.hue;
    CGFloat s = hsl.saturation;
    CGFloat l = hsl.brightness;

    // Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
    if (s == 0.0) 
    {
        rgbResult.red = l;
        rgbResult.green = l;
        rgbResult.blue = l;
        return rgbResult;
    }

    // Test for luminance and compute temporary values based on luminance and saturation
    if(l < 0.5)
        temp2 = l * (1.0 + s);
    else
        temp2 = l + s - l * s;
    temp1 = 2.0 * l - temp2;

    // Compute intermediate values based on hue
    temp[0] = h + 1.0 / 3.0;
    temp[1] = h;
    temp[2] = h - 1.0 / 3.0;

    for (i = 0; i < 3; ++i) 
    {
        // Adjust the range
        if(temp[i] < 0.0)
            temp[i] += 1.0;
        if(temp[i] > 1.0)
            temp[i] -= 1.0;

        if (6.0 * temp[i] < 1.0)
            temp[i] = temp1 + (temp2 - temp1) * 6.0 * temp[i];
        else {
            if (2.0 * temp[i] < 1.0)
                temp[i] = temp2;
            else {
                if (3.0 * temp[i] < 2.0)
                    temp[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp[i]) * 6.0;
                else
                    temp[i] = temp1;
            }
        }
    }

    // Assign temporary values to R, G, B
    rgbResult.red = temp[0];
    rgbResult.green = temp[1];
    rgbResult.blue = temp[2];
    return rgbResult;
}

@end

BOOL SLColorGetRGBAComponents(UIColor *color, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha) {
    return [color getRed:red green:green blue:blue alpha:alpha];
}

UIColor *SLColorWithRGBShift(UIColor *color, int offset) {
    return [color slColorWithRGBShift:offset];
}

UIColor *SLColorWithRGBA(int r, int g, int b, CGFloat a) {
    return [UIColor r:r g:g b:b a:a];
}

UIColor *SLColorWithRGB(int r, int g, int b) {
    return [UIColor r:r g:g b:b];
}

UIColor *SLColorWithHex(unsigned hex) {
    return [UIColor slColorWithHex:hex];
}
