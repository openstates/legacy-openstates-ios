    //
//  UISearchDisplayController+NoHideNav.m
//  TexLege
//
//  Created by Gregory Combs on 8/3/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "UISearchDisplayController+NoHideNav.h"


@implementation UISearchDisplayControllerNoHideNav

- (void)setActive:(BOOL)visible animated:(BOOL)animated;
{
    if(self.active == visible) return;
    [self.searchContentsController.navigationController setNavigationBarHidden:YES animated:NO];
    [super setActive:visible animated:animated];
    [self.searchContentsController.navigationController setNavigationBarHidden:NO animated:NO];
    if (visible) {
        [self.searchBar becomeFirstResponder];
    } else {
        [self.searchBar resignFirstResponder];
    }   
}


@end
