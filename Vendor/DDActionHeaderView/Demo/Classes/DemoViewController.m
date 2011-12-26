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

@synthesize actionHeaderView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.actionHeaderView = [[[DDActionHeaderView alloc] initWithFrame:self.view.bounds] autorelease];
	
    // Set title
    self.actionHeaderView.titleLabel.text = @"Tap DDActionHeaderView Action Picker";
	
    // Create action items, have to be UIView subclass, and set frame position by yourself.
    UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [facebookButton addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
    [facebookButton setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
    facebookButton.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    facebookButton.imageEdgeInsets = UIEdgeInsetsMake(13.0f, 13.0f, 13.0f, 13.0f);
    facebookButton.center = CGPointMake(25.0f, 25.0f);
    
    UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
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
    self.actionHeaderView.items = [NSArray arrayWithObjects:facebookButton, twitterButton, mailButton, nil];	
	
    [self.view addSubview:self.actionHeaderView];
}

- (void)itemAction:(id)sender {
    // Reset action picker
    [self.actionHeaderView shrinkActionPicker];
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
}


- (void)dealloc {
    [actionHeaderView release];
	
    [super dealloc];
}

@end
