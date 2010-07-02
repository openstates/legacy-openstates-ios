//
//  MiniBrowserController.m
//  TexLege
//

#import "TexLegeAppDelegate.h"
#import "MiniBrowserController.h"
#import "UtilityMethods.h"

@interface MiniBrowserController (Private)
	- (void)animate;
	- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
	- (void)enableBackButton:(BOOL)enable;
	- (void)enableFwdButton:(BOOL)enable;
@end

enum
{
	eTAG_BACK    = 999,
	eTAG_RELOAD  = 998,
	eTAG_FORWARD = 997,
	eTAG_CLOSE   = 996,
	eTAG_STOP    = 995,
};


@implementation MiniBrowserController

@synthesize m_toolBar, m_webView, m_shouldStopLoadingOnHide;
@synthesize m_backButton, m_reloadButton, m_fwdButton;
@synthesize m_shouldUseParentsView;

static MiniBrowserController *s_browser = nil;


+ (MiniBrowserController *)sharedBrowser
{
	return [self sharedBrowserWithURL:nil];
}


+ (MiniBrowserController *)sharedBrowserWithURL:(NSURL *)urlOrNil
{
	if ( s_browser == nil )
	{
		s_browser = [[MiniBrowserController alloc] initWithNibName:@"MiniBrowserView" bundle:nil];
		//s_browser.m_webView.detectsPhoneNumbers = YES;
		s_browser.m_webView.scalesPageToFit = YES;
		[s_browser.view setNeedsDisplay];
	}
	
	if ( nil != urlOrNil )
	{
		[s_browser loadURL:urlOrNil];
	}
	
	// let the caller take care of making this window visible...
	
	return s_browser;
}


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		m_shouldStopLoadingOnHide = YES;
		m_loadingInterrupted = NO;
		m_urlRequestToLoad = nil;
		//m_activity = nil;
		//m_loadingLabel = nil;
		m_parentCtrl = nil;
		m_shouldUseParentsView = NO;
		m_shouldDisplayOnViewLoad = NO;
		m_normalItemList = nil;
		m_loadingItemList = nil;
		m_authCallback = nil;
		[self enableBackButton:NO];
		[self enableFwdButton:NO];
	}
	return self;
}


- (void)didReceiveMemoryWarning 
{
	[self stopLoading]; // should we do more, like just close up shop?
	//[m_parentCtrl dismissModalViewControllerAnimated:YES];

	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc 
{
	if (m_urlRequestToLoad) [m_urlRequestToLoad release];
	if (m_normalItemList) [m_normalItemList release];
	if (m_loadingItemList) [m_loadingItemList release];
	[super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	//[m_activity stopAnimating];
	//[m_loadingLabel setHidden:YES];
	
	// get the current list of buttons
	m_normalItemList = [[NSArray alloc] initWithArray:m_toolBar.items];
	
	// generate a list of buttons to display while loading
	// (this enables a stop button)
	{
		NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:[m_normalItemList count]];
		for (id bbi in m_toolBar.items )
		{
			UIBarButtonItem *button = (UIBarButtonItem *)bbi;
			if ( eTAG_RELOAD == [button tag] )
			{
				UIBarButtonItem *stopButton = [[UIBarButtonItem alloc] 
													initWithBarButtonSystemItem:UIBarButtonSystemItemStop 
													target:self action:@selector(refreshButtonPressed:)];
				[stopButton setTag:eTAG_STOP];
				[tmpArray addObject:stopButton];
				[stopButton release];
			}
			else
			{
				[tmpArray addObject:bbi];
			}
		}
		m_loadingItemList = (NSArray *)tmpArray;
	}
	
	if ( m_shouldDisplayOnViewLoad )
	{
		m_shouldDisplayOnViewLoad = NO;
		[m_parentCtrl presentModalViewController:self animated:YES];
	}
}



- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
	
	if ( m_urlRequestToLoad != nil )
	{
		[self LoadRequest:m_urlRequestToLoad];
		[m_urlRequestToLoad release]; m_urlRequestToLoad = nil;
	}
	else if ( m_loadingInterrupted )
	{
		[m_webView reload];
	}
	m_loadingInterrupted = NO;
	
	[self enableBackButton:m_webView.canGoBack];
	[self enableFwdButton:m_webView.canGoForward];
}


- (void)viewWillDisappear:(BOOL)animated 
{
	if ( m_shouldStopLoadingOnHide )
	{
		if ( m_webView.loading )
		{
			m_loadingInterrupted = YES;
		}
		[self stopLoading];
	}
	
	[super viewWillDisappear:animated];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	// Return YES for supported orientations
	return YES;
}


- (void)display:(id)parentController
{
	m_parentCtrl = parentController;
	m_authCallback = nil;
	if ( m_webView != nil )
	{
		//[m_parentCtrl presentModalViewController:self animated:NO];
		[self animate];
	}
	else
	{
		m_shouldDisplayOnViewLoad = YES;
		[self.view setNeedsDisplay];
	}
}


- (IBAction)closeButtonPressed:(id)button
{
	// dismiss the view
	//[m_parentCtrl dismissModalViewControllerAnimated:YES];
	[self animate];
}


- (IBAction)backButtonPressed:(id)button
{
	if ( m_webView.canGoBack ) [m_webView goBack];
}


- (IBAction)fwdButtonPressed:(id)button
{
	if ( m_webView.canGoForward ) [m_webView goForward];
}


- (IBAction)refreshButtonPressed:(id)button
{
	if ( m_webView.loading )
	{
		[self stopLoading];
	}
	else 
	{
		[m_webView reload];
	}
}


- (void)loadURL:(NSURL *)url
{
	if ( url == nil ) return;
	
	m_loadingInterrupted = NO;
	
	// cancel any transaction currently taking place
	if ( m_webView.loading ) [m_webView stopLoading];
	
	if ( [self.view isHidden] )
	{
		[m_urlRequestToLoad release];
		m_urlRequestToLoad = [[NSURLRequest alloc] initWithURL:url];
	}
	else
	{
		[m_webView loadRequest:[NSURLRequest requestWithURL:url]];
	}
}


- (void)LoadRequest:(NSURLRequest *)urlRequest
{
	m_loadingInterrupted = NO;
	
	// cancel any transaction currently taking place
	if ( m_webView.loading ) [m_webView stopLoading];
	
	if ( [self.view isHidden] )
	{
		// do it this goofy way just in case (url == m_urlRequestToLoad)
		[urlRequest retain];
		[m_urlRequestToLoad release];
		m_urlRequestToLoad = [[NSURLRequest alloc] initWithURL:[urlRequest URL]];
		[urlRequest release];
	}
	else
	{
		[m_webView loadRequest:urlRequest];
	}
}


- (void)stopLoading
{
	if ( m_webView.loading )
	{
		[m_webView stopLoading];
		[m_activity stopAnimating];
		[m_loadingLabel setHidden:YES];
	}
}


- (void)setAuthCallback:(SEL)callback
{
	m_authCallback = callback;
}


- (void)authCompleteCallback
{
	// remove ourself from the view stack
	// once authentication is complete
	if ( [self.view superview] )
	{
		[self animate];
	}
	
	// do the auth-callback if requested
	if ( nil != m_authCallback )
	{
		if ( [m_parentCtrl respondsToSelector:m_authCallback] )
		{
			[m_parentCtrl performSelector:m_authCallback];
		}
	}
}


#pragma mark MiniBrowserController Private

- (void)animate
{
	TexLegeAppDelegate *appDelegate = (TexLegeAppDelegate *)[[UIApplication sharedApplication] delegate];
	//NSLog(@"Parent view %@", [m_parentCtrl view]);
	//NSLog(@"my tabbar %@", [m_parentCtrl tabBarController].view);
	//NSLog(@"Parent 1st nav view %@", [[[m_parentCtrl navigationController].viewControllers objectAtIndex:0] view]);
	
	UIView *topView = nil;
	if ( m_shouldUseParentsView )
	{
		topView = [m_parentCtrl view];
		if ( topView == nil )
		{
			if (appDelegate.splitViewController)
				topView = [[appDelegate.splitViewController.viewControllers objectAtIndex:1] view];
			else 
				topView = appDelegate.tabBarController.view;
		}
	}
	else
	{
		if (appDelegate.splitViewController)
			topView = [[appDelegate.splitViewController.viewControllers objectAtIndex:1] view];
		else 
			topView = appDelegate.tabBarController.view;
		

		//topView = appDelegate.tabBarController.view;
	}
	
	if (topView) [topView retain];
	
	NSLog(@"%@", [topView description]);
	
	m_shouldUseParentsView = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
	
	if ( [self.view superview] )
	{
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:topView cache:NO];
		[self.view removeFromSuperview];
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
	}
	else
	{
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:topView cache:NO];
		
		[self.view setFrame:[topView bounds]];
		[topView addSubview:self.view];
		
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
	}
	
	[UIView commitAnimations];
	
	if (topView) [topView release];

}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
}


- (void)enableBackButton:(BOOL)enable
{
	[m_backButton setEnabled:enable];
}


- (void)enableFwdButton:(BOOL)enable
{
	[m_fwdButton setEnabled:enable];
}


#pragma mark UIWebViewDelegate Methods 


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	// notify of an error?
	[m_toolBar setItems:m_normalItemList animated:NO];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	[m_toolBar setItems:m_loadingItemList animated:NO];
	
	[m_activity startAnimating];
	[m_loadingLabel setHidden:NO];
	[m_webView setAlpha:0.75f];
	
	// always start loading - we're not real restrictive here...
	return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[m_toolBar setItems:m_normalItemList animated:NO];
	[m_activity stopAnimating];
	[m_loadingLabel setHidden:YES];
	[m_webView setAlpha:1.0f];
	
	[self enableBackButton:m_webView.canGoBack];
	[self enableFwdButton:m_webView.canGoForward];
	
	// set the navigation bar title based on URL
	NSArray *urlComponents = [[[webView.request URL] absoluteString] componentsSeparatedByString:@"/"];
	if ( [urlComponents count] > 0 )
	{
		NSString *str = [urlComponents objectAtIndex:([urlComponents count]-1)];
		NSRange dot = [str rangeOfString:@"."];
		if ( dot.length > 0 )
		{
			self.title = [str substringToIndex:dot.location];
		}
		else
		{
			self.title = str;
		}
	}
	else
	{
		self.title = @"...";
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[m_activity startAnimating];
	[m_loadingLabel setHidden:NO];
	[m_webView setAlpha:0.75f];
	
	self.title = @"loading...";
}


@synthesize m_loadingInterrupted;
@synthesize m_urlRequestToLoad;
@synthesize m_activity;
@synthesize m_loadingLabel;
@synthesize m_normalItemList;
@synthesize m_loadingItemList;
@synthesize m_shouldDisplayOnViewLoad;
@synthesize m_parentCtrl;
@synthesize m_authCallback;
@end
