//
//  TexLegeInfoController.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs All rights reserved.
//

// EXAMPLE WAS EPONYMS

#import "TexLegeInfoController.h"
#import "UtilityMethods.h"
#import "MiniBrowserController.h"
#import "TexLegeAppDelegate.h"
#import "CommonPopoversController.h"

@implementation TexLegeInfoController

@synthesize delegate;
@synthesize infoTextView;
@synthesize versionLabel;
@synthesize dismissButton;



- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"TextLege Info";
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.infoTextView flashScrollIndicators];
	//[[CommonPopoversController sharedCommonPopoversController] resetPopoverMenus:self];
}


- (void)viewDidLoad {
	[super viewDidLoad];
	NSDictionary *infoPlistDict = [[NSBundle mainBundle] infoDictionary];
	self.versionLabel.text = [NSString stringWithFormat:@"Version %@", [infoPlistDict objectForKey:@"CFBundleVersion"]];
	
	NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"TexLegeStrings" ofType:@"plist"];
	NSDictionary *textDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
	self.infoTextView.text = [[textDict objectForKey:@"AboutText"] stringByAppendingFormat:@"\n%@", [textDict objectForKey:@"PartisanIndexText"]];

}

- (void)viewDidUnload {
	self.versionLabel = nil;
	self.infoTextView = nil;
	[super viewDidUnload];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[self done:nil];
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	 return YES; // UIInterfaceOrientationPortrait;
 }

- (void) done:(id)sender
{
	if (self.delegate && ![UtilityMethods isIPadDevice])
		[self.delegate modalViewControllerDidFinish:self];	
}


#pragma mark -
#pragma mark Popovers and Split Views

- (NSString *)popoverButtonTitle {
	return @"Resources";
}

- (void)dealloc {
	
	self.projectWebsiteURL = nil;
	self.versionLabel = nil;
	self.projectWebsiteButton = nil;
	self.dismissButton = nil;
	self.infoTextView = nil;
	[super dealloc];
}
@end
