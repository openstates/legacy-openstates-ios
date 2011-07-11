//
//  TexLegeNavBar.m
//  Created by Gregory Combs on 2/5/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//
//	Fixes an annoying bug in iOS 4.2.x that incorrectly deletes and ignores tintColor after opening in a popover/splitview

#import "TexLegeNavBar.h"
#import "TexLegeTheme.h"

@implementation TexLegeNavBar

- (void)setTintColor:(UIColor *)tintColor
{
	// Bug workaround. 
	
	[super setTintColor:[self tintColor]];
}

@end
