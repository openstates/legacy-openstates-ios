//
//  ColoredBarButtonItem.h
//  TexLege
//
//  Created by Gregory Combs on 8/15/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ColoredBarButtonItem : UIBarButtonItem {

}

+ (UIBarButtonItem *)coloredBarButtonItemGreen:(BOOL)green title:(NSString *)newTitle;
+ (UIBarButtonItem *)coloredBarButtonItemGreen:(BOOL)green fromButton:(UIBarButtonItem *)otherButton;

@end
