//
//  SLFTheme.h
//  Created by Greg Combs on 9/22/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <RestKit/UI/UI.h>
#import "SLFAppearance.h"
#import "StyledCellMapping.h"
#import "UIImage+OverlayColor.h"

BOOL SLFAlternateCellForIndexPath(UITableViewCell *cell, NSIndexPath * indexPath); // Returns YES if resulting in dark background
UIBarButtonItem* SLFToolbarButton(UIImage *image, id target, SEL selector);
RKTableSection* SLFAddTableControllerSectionWithTitle(RKTableController *controller, NSString *title);
NSArray* SLFBarStyleButtonImageGradientsWithSizeAndBaseColorRGB(CGSize imageSize, int red, int blue, int green);

@interface UIButton (SLFTintedButtons)
+ (UIButton *)buttonWithTitle:(NSString *)title orange:(BOOL)isOrange width:(CGFloat)width target:(id)target action:(SEL)action;
@end

@interface UIBarButtonItem (SLFTintedButtons)
- (id)initWithTitle:(NSString *)title orange:(BOOL)isOrange width:(CGFloat)width target:(id)target action:(SEL)action;
@end
