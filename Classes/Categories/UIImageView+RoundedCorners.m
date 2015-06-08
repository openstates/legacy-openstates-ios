//
//  UIImageView+RoundedCorners.m
//  Created by Greg Combs on 10/2/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "UIImageView+RoundedCorners.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImageView (RoundedCorners)
- (void)roundCorners:(UIRectCorner)corners
{
    CGRect maskRect = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:maskRect byRoundingCorners:corners cornerRadii:CGSizeMake(10.0, 10.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = maskRect;
    maskLayer.path = maskPath.CGPath;
    self.clipsToBounds = YES;
    self.layer.mask = maskLayer;
    [maskLayer release];
}

- (void)roundTopLeftCorner {
    [self roundCorners:UIRectCornerTopLeft];
}

- (void)roundBottomLeftCorner {
    [self roundCorners:UIRectCornerBottomLeft];
}

- (void)roundTopAndBottomLeftCorners {
    [self roundCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft)];
}

@end
