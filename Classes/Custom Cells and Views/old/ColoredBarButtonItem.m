//
//  ColoredBarButtonItem.m
//  TexLege
//
//  Created by Gregory Combs on 8/15/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "ColoredBarButtonItem.h"
#import "ColoredBarButtonView.h"

@implementation ColoredBarButtonItem

+ (UIBarButtonItem *)coloredBarButtonItemGreen:(BOOL)green {
	
	// create a button that we'll use to store our custom button images (and all their states)
	CGRect buttonRect = CGRectMake(0, 0, 70, kMyViewHeight);
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

	//set the frame of the button to the size of the image (YOU MUST DO THIS OTHERWISE IT WON'T RESPOND TO CLICKS)
	button.frame = CGRectMake(0, 0, 70, kMyViewHeight);
	button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	//[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.f];
	
	ColoredBarButtonView *coloredView1 = [[ColoredBarButtonView alloc] initWithFrame:buttonRect];
	coloredView1.green = green;
	coloredView1.selected = NO;
	UIImage *buttonImage1 = [coloredView1 imageFromUIView];
	[button setBackgroundImage:buttonImage1 forState:UIControlStateNormal];
	[button setTitle:@"Chickens" forState:UIControlStateNormal];
	
	
	ColoredBarButtonView *coloredView2 = [[ColoredBarButtonView alloc] initWithFrame:buttonRect];
	coloredView2.green = green;
	coloredView2.selected = YES;
	UIImage *buttonImage2 = [coloredView2 imageFromUIView];
	[button setBackgroundImage:buttonImage2 forState:UIControlStateHighlighted];
	[button setTitle:@"Beat It" forState:UIControlStateHighlighted];

	
	//[coloredView1 release];
	[coloredView2 release];
	
	
	//create a UIBarButtonItem with the button as a custom view
	UIBarButtonItem *customBarItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
		
	return customBarItem;
}

@end
