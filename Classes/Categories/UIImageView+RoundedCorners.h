//
//  UIImageView+RoundedCorners.h
//  Created by Greg Combs on 10/2/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <CoreGraphics/CoreGraphics.h>

@interface UIImageView (RoundedCorners)
- (void)roundTopLeftCorner;
- (void)roundBottomLeftCorner;
- (void)roundTopAndBottomLeftCorners;
- (void)roundCorners:(UIRectCorner)corners;
@end
