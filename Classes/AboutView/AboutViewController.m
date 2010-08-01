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
		self.title = @"About TexLege";
		// NSBundle Info.plist
		NSDictionary *infoPlistDict = [[NSBundle mainBundle] infoDictionary];
		self.projectWebsiteURL = [NSURL URLWithString:[infoPlistDict objectForKey:@"projectWebsite"]];
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.textView flashScrollIndicators];
}


- (void)viewDidLoad {
	[super viewDidLoad];
	NSDictionary *infoPlistDict = [[NSBundle mainBundle] infoDictionary];
	self.versionLabel.text = [NSString stringWithFormat:@"Version %@", [infoPlistDict objectForKey:@"CFBundleVersion"]];	

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
	[self.delegate modalViewControllerDidFinish:self];	
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark Alert View + Delegate
/* alert with one button
- (void) alertViewWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:nil];

	[alert show];
	[alert release];
}

// alert with 2 buttons
- (void) alertViewWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle otherTitle:(NSString *)otherTitle
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:otherTitle, nil];
	[alert show];
	[alert release];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex
{
}
 */
#pragma mark -

- (IBAction) weblink_click:(id) sender
{
	if ([UtilityMethods isIPadDevice]) {
		if ([UtilityMethods canReachHostWithURL:self.projectWebsiteURL]) {
			TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
			UIViewController *tempController = (self.splitViewController) ? appDelegate.currentDetailViewController: appDelegate.currentMasterViewController;				
			[self done:sender];	
			MiniBrowserController *mbc = [MiniBrowserController sharedBrowserWithURL:self.projectWebsiteURL];
			[mbc display:tempController];
		}
	}
	else
		[UtilityMethods openURLWithTrepidation:self.projectWebsiteURL];
}


- (void)dealloc {
	self.projectWebsiteURL = nil;
	self.infoView = nil;
	self.versionLabel = nil;
	self.projectWebsiteButton = nil;
	self.dismissButton = nil;
	self.textView = nil;
	[super dealloc];
}

@synthesize textView;
@synthesize versionLabel;
@synthesize infoView;
@synthesize projectWebsiteButton;
@synthesize dismissButton;
@end
