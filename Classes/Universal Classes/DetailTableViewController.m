//
//  DetailTableViewController.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "DetailTableViewController.h"
#import "CommitteeObj.h"
#import "UtilityMethods.h"
#import "MiniBrowserController.h"

@interface DetailTableViewController(mymethods)

// these are private methods that outside classes need not use
- (void)loadWebViewFromMapPDF;
- (void)loadWebViewFromURL:(NSURL *)url;
- (void)loadLegislatorView;
- (void)loadCommitteeView;
@end

@implementation DetailTableViewController

@synthesize containerView;

//@synthesize mapImageView;
@synthesize mapFileName, webPDFView;
@synthesize webViewURL;
@synthesize legislator, legislatorView;
@synthesize committee, committeeView;


- (id)init {
	if (self = [super init]) {
		self.hidesBottomBarWhenPushed = NO;
		
		mapFileName = nil;
//		mapImageView = nil;
		webPDFView = nil;
		webViewURL = nil;

		legislatorView = nil;
		legislator = nil;
		committeeView = nil;
		committee = nil;
	}
	return self;
}

- (void)dealloc {
	[legislatorView release];
	[legislator release];

	[committeeView release];
	[committee release];

	[webPDFView release];
	[mapFileName release];
	//	[mapImageView release];
	[webViewURL release];

	[containerView release];

	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	[[self navigationController] popToRootViewControllerAnimated:YES];
	[legislatorView release];
	legislatorView = nil;
	[legislator release];
	legislator = nil;

	[committeeView release];
	committeeView = nil;
	[committee release];
	committee = nil;
	
	[webPDFView release];
	webPDFView = nil;
	[mapFileName release];
	mapFileName = nil;
	[webViewURL release];
	webViewURL = nil;
	[containerView release];
	containerView = nil;
	
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


#pragma mark -
#pragma mark Load Detail Views

- (void)loadView {	
	// create and store a container view

	UIView *localContainerView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.containerView = localContainerView;
	[localContainerView release];
	
	self.navigationController.toolbarHidden = YES;	

	
	if (legislator != nil) {
		containerView.backgroundColor = [UIColor whiteColor];
		[self loadLegislatorView];
	}
	if (committee != nil) {
		containerView.backgroundColor = [UIColor whiteColor];
		[self loadCommitteeView];
	}
	else if (mapFileName != nil) {
		containerView.backgroundColor = [UIColor whiteColor];
		[self loadWebViewFromMapPDF];
	}
	else if (webViewURL != nil) {
		containerView.backgroundColor = [UIColor whiteColor];
		[self loadWebViewFromURL:webViewURL];
	}	
	
}


- (void)loadWebViewFromMapPDF {
	
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
	NSString *pdfPath = [ NSString stringWithFormat:
						 @"%@/%@.app/%@",NSHomeDirectory(),appName, mapFileName ];
	
	NSURL *url = [ NSURL fileURLWithPath:pdfPath ];
	[ self loadWebViewFromURL:url ];
	
	
	/*	Right now we're using a simple WebView, but we may go back to custom drawing/scrolling...	
	 // create the map image view
	 MapImageView *localMapImageView = [[MapImageView alloc] initWithFrame:containerView.bounds];
	 self.mapImageView = localMapImageView;
	 [localMapImageView release];
	 
	 mapImageView.imageFile = mapFileName;	
	 [containerView addSubview:mapImageView];
	 mapImageView.viewController = self;
	 self.view = containerView;
	 */
}	


- (void)loadWebViewFromURL:(NSURL *)url {
	UIWebView *localWebView = [[UIWebView alloc] initWithFrame:containerView.bounds];
	self.webPDFView = localWebView;
	self.webPDFView.backgroundColor=[UIColor blackColor];
	
	self.webPDFView.scalesPageToFit = YES;
	self.webPDFView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	self.webPDFView.dataDetectorTypes = UIDataDetectorTypeAll;
	
	[localWebView release];
	
	NSURLRequest *request = [ NSURLRequest requestWithURL:url ];
	[ webPDFView loadRequest:request ];
	
	[containerView addSubview:webPDFView];
	self.view = containerView;
	
}	


- (void)loadLegislatorView {
	
	self.legislatorView = [[DirectoryDetailView alloc] initWithFrameAndLegislator:containerView.bounds 
																	   Legislator:self.legislator];
	
	// eventually it'll just be the name, once we add custom notes button...
	self.navigationItem.title = [NSString stringWithFormat:@"%@ %@",
											[self.legislator legProperName], [self.legislator districtPartyString]];
	self.legislatorView.delegate = self;
	self.legislatorView.detailController = self;
	
	[containerView addSubview:self.legislatorView];
	self.view = containerView;
	
}	

- (void)loadCommitteeView {
	
	self.committeeView = [[CommitteeDetailView alloc] initWithFrameAndCommittee:containerView.bounds 
																	   Committee:self.committee];
	
	// eventually it'll just be the name, once we add custom notes button...
	self.navigationItem.title = [self.committee description];
	self.committeeView.delegate = self;
	self.committeeView.detailController = self;
	
	[containerView addSubview:self.committeeView];
	self.view = containerView;
	
}	


// the user selected a row in the table.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {

	if (self.legislatorView != nil) {
		[self.legislatorView didSelectRowAtIndexPath:newIndexPath];		
	}
	if (self.committeeView != nil) {
		[self.committeeView didSelectRowAtIndexPath:newIndexPath];		
	}
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.legislatorView != nil) {
		return [self.legislatorView heightForRowAtIndexPath:indexPath];		
	}
	return 44.0f;
}

- (void) pushMapViewWithURL:(NSURL *)url {
	DetailTableViewController *detailController = [[DetailTableViewController alloc] init];
	
	detailController.webViewURL = url;
	
	// push the detail view controller onto the navigation stack to display it
	[[self navigationController] pushViewController:detailController animated:YES];
	
	[detailController release];
	
}

- (void) pushInternalBrowserWithURL:(NSURL *)url {
	if ([UtilityMethods canReachHostWithURL:url]) { // do we have a good URL/connection?
#if 0
		DrillDownWebController * controller = [[DrillDownWebController alloc] initWithWebRoot: url 
																					 andTitle:@"Loading..." andSplashImage:nil andViewController:self];
		[[self navigationController] pushViewController:controller animated: YES];
		
		[controller release];	
#endif
		MiniBrowserController *mbc = [MiniBrowserController sharedBrowserWithURL:url];
		[mbc display:self];
	}
}

- (void) showWebViewWithURL:(NSURL *)url {
	if ([url isFileURL]) {	// we don't implicitely "push" this one, since we might be a maps table.
		[self loadWebViewFromURL:url];
	}
	else  {
		[self pushInternalBrowserWithURL:url];
	}
}	


#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
	return YES;
}

@end
