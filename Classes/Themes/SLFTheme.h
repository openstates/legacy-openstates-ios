//
//  SLFTheme.h
//  Created by Greg Combs on 9/22/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <RestKit/UI/UI.h>
#import "SLFAppearance.h"
#import "AlternatingCellMapping.h"
#import "SubtitleCellMapping.h"
#import "UIImage+OverlayColor.h"

static inline void SLFAlternateCellForIndexPath(UITableViewCell *cell, NSIndexPath * indexPath) {
    cell.backgroundColor = [SLFAppearance cellBackgroundLightColor];
    if (indexPath.row % 2 == 0)
        cell.backgroundColor = [SLFAppearance cellBackgroundDarkColor];
}

static inline UIBarButtonItem* SLFToolbarButton(UIImage *image, id target, SEL selector) {
    UIImage *normalImage = [image imageWithOverlayColor:[SLFAppearance tableBackgroundLightColor]];
    UIImage *selectedImage = [image imageWithOverlayColor:[SLFAppearance menuTextColor]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );    
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:selectedImage forState:UIControlStateHighlighted];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];    
    return [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
}
