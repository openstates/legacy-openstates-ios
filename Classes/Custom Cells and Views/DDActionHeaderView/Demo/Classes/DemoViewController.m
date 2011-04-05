//
//  DemoViewController.m
//  Demo
//
//  Created by digdog on 11/4/10.
//  Copyright 2010 Ching-Lan 'digdog' HUANG. All rights reserved.
//

#import "DemoViewController.h"
#import "DDActionHeaderView.h"

@implementation DemoViewController

@synthesize actionHeaderView, starButton;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.actionHeaderView = [[DDActionHeaderView alloc] initWithFrame:self.view.bounds];
	
	// Set title
	self.actionHeaderView.titleLabel.text = @"Committee Substitute for Senate Bill 512";
	
	// Create action items, have to be UIView subclass, and set frame position by yourself.
    self.starButton = [UIButton buttonWithType:UIButtonTypeCustom];
#if 0
	[starButton addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
#else
    [starButton addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchDown];
#endif
    [starButton setImage:[UIImage imageNamed:@"starButtonLargeOff"] forState:UIControlStateNormal];
    [starButton setImage:[UIImage imageNamed:@"starButtonLargeOn"] forState:UIControlStateHighlighted];
//	starButton.adjustsImageWhenHighlighted = NO;
    starButton.frame = CGRectMake(0.0f, 0.0f, 66.0f, 66.0f);
    //starButton.imageEdgeInsets = UIEdgeInsetsMake(13.0f, 13.0f, 13.0f, 13.0f);
    starButton.center = CGPointMake(25.0f, 25.0f);
    
/*    UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [twitterButton addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
    [twitterButton setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
    twitterButton.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    twitterButton.imageEdgeInsets = UIEdgeInsetsMake(13.0f, 13.0f, 13.0f, 13.0f);
    twitterButton.center = CGPointMake(75.0f, 25.0f);
    
    UIButton *mailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mailButton addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
    [mailButton setImage:[UIImage imageNamed:@"mail"] forState:UIControlStateNormal];
    mailButton.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    mailButton.imageEdgeInsets = UIEdgeInsetsMake(13.0f, 13.0f, 13.0f, 13.0f);
    mailButton.center = CGPointMake(125.0f, 25.0f);
	
	// Set action items, and previous items will be removed from action picker if there is any.
    self.actionHeaderView.items = [NSArray arrayWithObjects:starButton, twitterButton, mailButton, nil];	
*/	
    self.actionHeaderView.items = [NSArray arrayWithObjects:starButton, nil];	
	[self.view addSubview:self.actionHeaderView];
}

- (void)itemAction:(id)sender {
#if 0
	// We're turning this off for now, we don't need the extended action menu, yet.
	// Reset action picker
	//		[self.actionHeaderView shrinkActionPicker];
#else
	if (sender && [sender isEqual:starButton]) {
		starButton.tag = !starButton.tag;
		if (starButton.tag) {
			[starButton setImage:[UIImage imageNamed:@"starButtonLargeOff"] forState:UIControlStateHighlighted];
			[starButton setImage:[UIImage imageNamed:@"starButtonLargeOn"] forState:UIControlStateNormal];
		}
		else {
			[starButton setImage:[UIImage imageNamed:@"starButtonLargeOff"] forState:UIControlStateNormal];
			[starButton setImage:[UIImage imageNamed:@"starButtonLargeOn"] forState:UIControlStateHighlighted];
			
		}
	}
#endif	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.actionHeaderView = nil;
	self.starButton = nil;
}


- (void)dealloc {
	[actionHeaderView release];
	self.starButton = nil;
	
    [super dealloc];
}

@end
