//
//  SLFTheme.m
//  Created by Greg Combs on 9/22/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFTheme.h"

BOOL SLFAlternateCellForIndexPath(UITableViewCell *cell, NSIndexPath * indexPath) {
    cell.backgroundColor = [SLFAppearance cellBackgroundLightColor];
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [SLFAppearance cellBackgroundDarkColor];
        return YES;
    }
    return NO;
}

UIBarButtonItem* SLFToolbarButton(UIImage *image, id target, SEL selector) {
    UIImage *normalImage = [image imageWithOverlayColor:[SLFAppearance tableBackgroundLightColor]];
    UIImage *selectedImage = [image imageWithOverlayColor:[SLFAppearance menuTextColor]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );    
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:selectedImage forState:UIControlStateHighlighted];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];    
    return [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
}

UILabel *SLFStyledHeaderLabelWithTextAtOrigin(NSString *text, CGPoint origin){
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    static UIFont *defaultTextFont;
    if (!defaultTextFont)
        defaultTextFont = [SLFTitleFont(13) retain];
    label.font = defaultTextFont;
    label.text = text;
    label.textAlignment = UITextAlignmentRight;
    label.numberOfLines = 2;
    label.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:0.9];
    label.shadowColor = [[UIColor lightTextColor] colorWithAlphaComponent:0.7];
    label.shadowOffset = CGSizeMake(-1, 1);
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    CGSize labelSize = label.frame.size;
    label.frame = CGRectMake(origin.x, origin.y, labelSize.width, labelSize.height);
    return [label autorelease];
}

@implementation UIButton (SLFTintedButtons)

+ (UIButton *)buttonWithTitle:(NSString *)title orange:(BOOL)isOrange width:(CGFloat)width target:(id)target action:(SEL)action {
    NSString *normalPath = @"BarButtonGreenNormal";
    NSString *highlightPath = @"BarButtonGreenHighlight";
    if (isOrange) {
        normalPath = @"BarButtonNormal";
        highlightPath = @"BarButtonHighlight";
    }
    UIImage *normal = [[UIImage imageNamed:normalPath] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    UIImage *highlight = [[UIImage imageNamed:highlightPath] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    button.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    button.frame = CGRectMake(0, 0, width, 30);
    
    [button setBackgroundImage:normal forState:UIControlStateNormal];
    [button setBackgroundImage:highlight forState:UIControlStateHighlighted];
    return button;
}

@end

@implementation UIBarButtonItem (SLFTintedButtons)

- (id)initWithTitle:(NSString *)title orange:(BOOL)isOrange width:(CGFloat)width target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithTitle:title orange:isOrange width:width target:target action:action];
    return (self = [self initWithCustomView:button]);
}

@end