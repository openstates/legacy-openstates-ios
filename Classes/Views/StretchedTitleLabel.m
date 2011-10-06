//
//  StretchedTitleLabel.m
//  Created by Greg Combs on 10/6/11.
//
//  Crap by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "StretchedTitleLabel.h"
#import <CoreText/CoreText.h>
#import "SLFTheme.h"

@interface StretchedTitleLabel()
- (NSAttributedString *)illuminatedString:(NSString *)text atLocation:(NSInteger)location;
@end

@implementation StretchedTitleLabel
@synthesize attributedText;

- (void)dealloc {
    [attributedText release]; attributedText = nil;
    [super dealloc];
}

- (void)setAttributedText:(NSAttributedString *)newAttributedText {
    if (attributedText != newAttributedText) {
        [attributedText release];
        attributedText = [newAttributedText copy];
        [self setNeedsDisplay];  
    }    
}

- (void)setAttributedTextWithString:(NSString *)string illuminatedAtLocation:(NSInteger)location {
    self.attributedText = [self illuminatedString:string atLocation:location];
}

- (void)drawRect:(CGRect)rect {
	if (self.attributedText == nil) 
		return;   
	CGContextRef context = UIGraphicsGetCurrentContext(); 		
	CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef) self.attributedText);
    CGRect imageBounds = CTLineGetImageBounds(line, context);
    CGFloat width = imageBounds.size.width;
    CGFloat height = imageBounds.size.height;
    
    CGFloat horizPadding = 15;
    CGFloat vertPadding = 30;
    width += horizPadding;
    height += vertPadding;
    float sx = self.bounds.size.width / width;
    float sy = self.bounds.size.height / height;
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 1, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextScaleCTM(context, sx, sy);
    CGContextSetTextPosition(context, -imageBounds.origin.x + horizPadding/2, -imageBounds.origin.y + vertPadding/2);
    CTLineDraw(line, context);
	CGContextRestoreGState(context);	
	CFRelease(line);	
}

- (NSAttributedString *)illuminatedString:(NSString *)text atLocation:(NSInteger)location {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:30];
    int len = [text length];

    NSString *colorNameKey = (NSString*)(kCTForegroundColorAttributeName);
    NSString *fontNameKey = (NSString*)(kCTFontAttributeName);
    NSMutableAttributedString *mutaString = [[[NSMutableAttributedString alloc] initWithString:text] autorelease];
    [mutaString addAttribute:colorNameKey value:(id)[SLFAppearance menuSelectedTextColor].CGColor range:NSMakeRange(0, len)];
    [mutaString addAttribute:colorNameKey value:(id)[SLFAppearance menuTextColor].CGColor range:NSMakeRange(location-1, 1)];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    CTFontRef ctFont2 = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize*1.4, NULL);
    [mutaString addAttribute:fontNameKey value:(id)ctFont range:NSMakeRange(0, len)];
    [mutaString addAttribute:fontNameKey value:(id)ctFont2 range:NSMakeRange(location-1, 1)];
    CFRelease(ctFont);
    CFRelease(ctFont2);
    return mutaString;
}
@end

StretchedTitleLabel *CreateOpenStatesTitleLabelForFrame(CGRect rect) {
    StretchedTitleLabel *titleLabel = [[StretchedTitleLabel alloc] initWithFrame:rect];
    [titleLabel setAttributedTextWithString:@"O P E N : S T A T E S" illuminatedAtLocation:9];
    return titleLabel;
}
