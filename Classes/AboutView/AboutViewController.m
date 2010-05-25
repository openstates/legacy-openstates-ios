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

@implementation AboutViewController

@synthesize delegate, infoPlistDict, projectWebsiteURL;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if(self) {
		
		// NSBundle Info.plist
		self.infoPlistDict = [[NSBundle mainBundle] infoDictionary];		// !! could use the supplied NSBundle or the mainBundle on nil
		self.projectWebsiteURL = [NSURL URLWithString:[infoPlistDict objectForKey:@"projectWebsite"]];
	}
	return self;	
}

- (void)viewDidLoad {
	self.view = infoView;		// do we need this?
//    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];      

	//projectWebsiteButton.autoresizingMask = UIViewAutoresizingNone;

	// version
	NSString *version = [NSString stringWithFormat:@"Version %@", [infoPlistDict objectForKey:@"CFBundleVersion"]];
	[versionLabel setText:version];
	
}


- (IBAction)done {
	[self.delegate aboutViewControllerDidFinish:self];	
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
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark Alert View + Delegate
// alert with one button
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
#pragma mark -

- (IBAction) weblink_click:(id) sender
{
	NSURL * url = [NSURL URLWithString:@"http://www.texlege.com/"];
	[UtilityMethods openURLWithTrepidation:url];
#if 0
	if ([UtilityMethods canReachHostWithURL:url]) {
		UIViewController *tempController = self.parentViewController;
		[self done:button];
		MiniBrowserController *mbc = [MiniBrowserController sharedBrowserWithURL:url];
		[mbc display:tempController];
	}
#endif
}


- (void)dealloc {
	self.infoPlistDict = nil;
	self.projectWebsiteURL = nil;

	// IBOutlets
	[infoView release];
	
	[versionLabel release];
	
	[projectWebsiteButton release];
	[dismissButton release];

	[super dealloc];
}


@synthesize versionLabel;
@synthesize infoView;
@synthesize projectWebsiteButton;
@synthesize dismissButton;
@end
