//
//  SLFDrawingExtensions.h
//  Created by Greg Combs on 11/18/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

@interface SLFDrawing : NSObject
    // Used to determine gradient direction
+ (void)getStartPoint:(CGPoint*)startRef endPoint:(CGPoint *)endRef withAngle:(CGFloat)angle inRect:(CGRect)rect;
+ (UIBezierPath *)tableHeaderBorderPathWithFrame:(CGRect)frame;
@end

@interface UIImage (SLFExtensions)
+ (UIImage *)imageFromView:(UIView *)view;
- (UIImage *)glossyImageOverlay;
@end

@interface UIButton (SLFExtensions)
+ (UIButton *)buttonForImage:(UIImage *)iconImage withFrame:(CGRect)rect glossy:(BOOL)glossy;
@end

@interface NSString (SLFDrawing)
- (CGRect)rectWithFont:(UIFont *)font origin:(CGPoint)origin;
- (CGSize)drawWithFont:(UIFont *)font origin:(CGPoint)origin;
@end