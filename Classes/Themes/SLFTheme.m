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

