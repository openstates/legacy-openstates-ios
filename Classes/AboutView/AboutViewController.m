//
//  AboutViewController.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs All rights reserved.
//

// EXAMPLE WAS EPONYMS

#import "AboutViewController.h"
#import "UtilityMethods.h"
#import "MiniBrowserController.h"
#import "TexLegeAppDelegate.h"

@implementation AboutViewController

@synthesize delegate, projectWebsiteURL;


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"TextLege Info";
		// NSBundle Info.plist
		NSDictionary *infoPlistDict = [[NSBundle mainBundle] infoDictionary];
		self.projectWebsiteURL = [NSURL URLWithString:[infoPlistDict objectForKey:@"projectWebsite"]];
		
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.infoTextView flashScrollIndicators];
}


- (void)viewDidLoad {
	[super viewDidLoad];
	NSDictionary *infoPlistDict = [[NSBundle mainBundle] infoDictionary];
	self.versionLabel.text = [NSString stringWithFormat:@"Version %@", [infoPlistDict objectForKey:@"CFBundleVersion"]];
	
	NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"TexLegeStrings" ofType:@"plist"];
	NSDictionary *textDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
	self.infoTextView.text = [[textDict objectForKey:@"AboutText"] stringByAppendingFormat:@"\n%@", [textDict objectForKey:@"PartisanIndexText"]];

}

 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	 return YES; // UIInterfaceOrientationPortrait;
 }

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[self done:nil];
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void) done:(id)sender
{
	if (self.delegate && ![UtilityMethods isIPadDevice])
		[self.delegate modalViewControllerDidFinish:self];	
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark Alert View + Delegate
#pragma mark -

- (IBAction) weblink_click:(id) sender
{
	if ([UtilityMethods canReachHostWithURL:self.projectWebsiteURL]) {
		MiniBrowserController *mbc = [MiniBrowserController sharedBrowserWithURL:self.projectWebsiteURL];
		[mbc display:self];
	}
}


- (void)dealloc {
	self.projectWebsiteURL = nil;
	self.versionLabel = nil;
	self.projectWebsiteButton = nil;
	self.dismissButton = nil;
	self.infoTextView = nil;
	[super dealloc];
}

@synthesize infoTextView;
@synthesize versionLabel;
@synthesize projectWebsiteButton;
@synthesize dismissButton;
@end
