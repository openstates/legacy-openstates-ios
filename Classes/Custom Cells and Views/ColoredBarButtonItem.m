//
//  ColoredBarButtonItem.m
//  Created by Gregory Combs on 8/15/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "ColoredBarButtonItem.h"
#import "ColoredBarButtonView.h"

@implementation ColoredBarButtonItem

+ (UIBarButtonItem *)coloredBarButtonItemGreen:(BOOL)green title:(NSString *)newTitle {
	
	// create a button that we'll use to store our custom button images (and all their states)
	CGRect buttonRect = CGRectMake(0, 0, 70, 30);
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

	//set the frame of the button to the size of the image (YOU MUST DO THIS OTHERWISE IT WON'T RESPOND TO CLICKS)
	button.frame = CGRectMake(0, 0, 70, 30);
	button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	//[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.f];
	
	ColoredBarButtonView *coloredView1 = [[ColoredBarButtonView alloc] initWithFrame:buttonRect];
	coloredView1.green = green;
	//coloredView1.selected = NO;
	UIImage *buttonImage1 = [coloredView1 imageFromUIView];
	[button setBackgroundImage:buttonImage1 forState:UIControlStateNormal];
	[button setTitle:newTitle forState:UIControlStateNormal];
	
	
	//[button setTitle:@"Beat It" forState:UIControlStateHighlighted];

	
	[coloredView1 release];
	
	
	//create a UIBarButtonItem with the button as a custom view
	UIBarButtonItem *customBarItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
		
	return customBarItem;
}

+ (UIBarButtonItem *)coloredBarButtonItemGreen:(BOOL)green fromButton:(UIBarButtonItem *)otherButton {
	NSString *aTitle = otherButton.title;
	SEL selector = otherButton.action;
	id target = otherButton.target;
	CGFloat width = otherButton.width;
	UIBarButtonItem *newButton = [ColoredBarButtonItem coloredBarButtonItemGreen:green title:aTitle];
	newButton.width = width;
	newButton.action = selector;
	newButton.target = target;
	return newButton;
}

@end
