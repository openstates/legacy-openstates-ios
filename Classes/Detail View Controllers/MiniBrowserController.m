//
//  MiniBrowserController.m
//  TexLege
//

#import "TexLegeAppDelegate.h"
#import "MiniBrowserController.h"
#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "TexLegeEmailComposer.h"
#import "LinkObj+RestKit.h"
#import "LinksMasterViewController.h"
#import "LocalyticsSession.h"
#import "TexLegeCoreDataUtils.h"

@interface MiniBrowserController (Private)
	- (void)animate;
	- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
	- (void)enableBackButton:(BOOL)enable;
	- (void)enableFwdButton:(BOOL)enable;
	- (void)stopLoadingAnimation:(id)sender;
	- (void)startLoadingAnimation:(id)sender;
@end

enum
{
	eTAG_BACK    = 999,
	eTAG_RELOAD  = 998,
	eTAG_FORWARD = 997,
	eTAG_CLOSE   = 996,
	eTAG_STOP    = 995,
	eTAG_SAFARI  = 994,
	eTAG_EMAILURL= 993,
};

@implementation MiniBrowserController

@synthesize m_urlRequestToLoad, m_loadingItemList, m_activity, m_loadingLabel, isSharedBrowser;
@synthesize dataObjectID;
@synthesize m_toolBar, m_webView, m_shouldStopLoadingOnHide;
@synthesize m_backButton, m_reloadButton, m_fwdButton, m_doneButton;
@synthesize m_shouldUseParentsView;
@synthesize m_currentURL;
@synthesize sealColor;
@synthesize m_loadingInterrupted, m_normalItemList, m_shouldDisplayOnViewLoad, m_parentCtrl, m_authCallback;
@synthesize masterPopover, m_shouldHideDoneButton, userAgent;

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
		s_browser.m_shouldHideDoneButton = NO;
		s_browser.isSharedBrowser = YES;
		
		s_browser.m_webView.scalesPageToFit = YES;
		[s_browser.view setNeedsDisplay];
	}
	s_browser.m_shouldHideDoneButton = NO;

	if ( nil != urlOrNil )
	{
		[s_browser loadURL:urlOrNil];
	}
	
	// let the caller take care of making this window visible...
	
	return s_browser;
}

- (NSString *)nibName {
	return @"MiniBrowserView";
}

- (id) initWithNibName:(NSString *)nib bundle:(NSBundle *)bundle {
	if (self = [super initWithNibName:nib bundle:bundle]) {
		UIImage *sealImage = [UIImage imageNamed:@"seal.png"];
		self.sealColor = [UIColor colorWithPatternImage:sealImage];		
		
		self.modalPresentationStyle = UIModalPresentationCurrentContext; //UIModalPresentationFullScreen;
		m_shouldStopLoadingOnHide = YES;
		m_loadingInterrupted = NO;
		m_urlRequestToLoad = nil;
		//m_activity = nil;
		//m_loadingLabel = nil;
		m_parentCtrl = nil;
		self.isSharedBrowser = NO;
		m_shouldUseParentsView = NO;
		m_shouldDisplayOnViewLoad = NO;
		m_shouldHideDoneButton = YES;
		self.m_normalItemList = nil;
		m_loadingItemList = nil;
		m_authCallback = nil;
		self.dataObjectID = nil;
		[self enableBackButton:NO];
		[self enableFwdButton:NO];
		
	}
	return self;
}

- (void)awakeFromNib {
	
	[super awakeFromNib];
	UIImage *sealImage = [UIImage imageNamed:@"seal.png"];
	self.sealColor = [UIColor colorWithPatternImage:sealImage];		
	
	self.modalPresentationStyle = UIModalPresentationCurrentContext; //UIModalPresentationFullScreen;
	m_shouldStopLoadingOnHide = YES;
	m_loadingInterrupted = NO;
	m_urlRequestToLoad = nil;
	//m_activity = nil;
	//m_loadingLabel = nil;
	self.isSharedBrowser = NO;
	m_parentCtrl = nil;
	m_shouldUseParentsView = NO;
	m_shouldDisplayOnViewLoad = NO;
	m_shouldHideDoneButton = YES;
	self.m_normalItemList = nil;
	m_loadingItemList = nil;
	m_authCallback = nil;
	self.dataObjectID = nil;
	[self enableBackButton:NO];
	[self enableFwdButton:NO];
	
	
}

- (void)didReceiveMemoryWarning 
{
	[self stopLoading]; // should we do more, like just close up shop?
	if (m_parentCtrl && [m_parentCtrl modalViewController])
		[m_parentCtrl dismissModalViewControllerAnimated:YES];

	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc 
{
	self.userAgent = nil;
	self.sealColor = nil;
	self.m_currentURL = nil;
	self.m_doneButton = nil;
	self.m_normalItemList = nil;
	if (m_urlRequestToLoad) [m_urlRequestToLoad release];
	if (m_loadingItemList) [m_loadingItemList release];
	self.masterPopover = nil;
	self.dataObjectID = nil;
	[super dealloc];
}

- (id)dataObject {
	return self.link;
}

- (void)setDataObject:(id)newObj {
	[self setLink:newObj];
}

#pragma mark -
#pragma mark Popovers and Split Views
/*
- (NSString *)popoverButtonTitle {
	return @"Resources";
}
*/
	
- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
	//debug_NSLog(@"Entering portrait, showing the button: %@", [aViewController class]);
    barButtonItem.title = @"Resources";
    [self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
    self.masterPopover = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	//debug_NSLog(@"Entering landscape, hiding the button: %@", [aViewController class]);
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    self.masterPopover = nil;
}

- (void) splitViewController:(UISplitViewController *)svc popoverController: (UIPopoverController *)pc
   willPresentViewController: (UIViewController *)aViewController
{
	if ([UtilityMethods isLandscapeOrientation]) {
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"ERR_POPOVER_IN_LANDSCAPE"];
	}
}	

#pragma mark -
#pragma mark UIToolBar buttons

- (void)normalizeToolbarButtons {
	// get the current list of buttons
	if (self.m_normalItemList)
		self.m_normalItemList = nil;
	
	NSMutableArray *alteredButtonList = [[NSMutableArray alloc] initWithArray:m_toolBar.items];
	if (m_shouldHideDoneButton) {
		for (UIBarButtonItem *button in m_toolBar.items) {
			if (button.tag == eTAG_CLOSE) {
				[alteredButtonList removeObject:button];
				break;
			}
		}
	}

	self.m_normalItemList = [NSArray arrayWithArray:alteredButtonList];
	[alteredButtonList release];	
	
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
		if (self.m_loadingItemList)
			self.m_loadingItemList = nil;
		
		self.m_loadingItemList = tmpArray;
		[tmpArray release];
	}
	
}

- (void)removeDoneButton {
	NSMutableArray * buttons = [[NSMutableArray alloc] initWithArray:self.m_toolBar.items];
	[buttons removeObject:self.m_doneButton];
	[self.m_toolBar setItems:buttons animated:NO];		
	[buttons release], buttons = nil;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	[super viewDidLoad];

	if ([UtilityMethods isIPadDevice]) {
		[self.m_webView setBackgroundColor:[UIColor clearColor]];
		[self.m_webView setOpaque:NO];
		self.view.backgroundColor = self.sealColor;
	}
	else {
		self.hidesBottomBarWhenPushed = YES;

		[self.m_webView setBackgroundColor:[TexLegeTheme backgroundLight]];
		[self.m_webView setOpaque:YES];
		self.view.backgroundColor = [TexLegeTheme backgroundLight];
	}
	self.m_toolBar.tintColor = [TexLegeTheme navbar];

	//[m_activity stopAnimating];
	//[m_loadingLabel setHidden:YES];
	
	[self normalizeToolbarButtons];
	
	if ( self.m_shouldDisplayOnViewLoad )
	{
		self.m_shouldDisplayOnViewLoad = NO;
		[m_parentCtrl presentModalViewController:self animated:YES];
	}
}

- (void)viewDidUnload {
/*
 self.m_webView = nil;
	self.m_toolBar = nil;
	self.m_loadingLabel = nil;
	self.m_backButton = nil;
	self.m_reloadButton = nil;
	self.m_fwdButton = nil;
	self.m_doneButton = nil;
	self.m_loadingItemList = nil;
	self.m_normalItemList = nil;
	self.masterPopover = nil;
*/
	[super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (m_shouldHideDoneButton)
	{
		[self removeDoneButton];
		[self normalizeToolbarButtons];
	}
	
	if ([UtilityMethods isIPadDevice] && !self.link && !self.isSharedBrowser && ![UtilityMethods isLandscapeOrientation])  {
		TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
		LinksMasterViewController *masterVC = [appDelegate linksMasterVC];
		if (!masterVC)
			return;
		
		if (!masterVC.selectObjectOnAppear)
			masterVC.selectObjectOnAppear = [masterVC firstDataObject];

		self.link = masterVC.selectObjectOnAppear;	
	}	
}


- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
	
	if ( self.m_urlRequestToLoad != nil )
	{
		[self LoadRequest:m_urlRequestToLoad];
		self.m_urlRequestToLoad = nil;
	}
	else if ( self.m_loadingInterrupted )
	{
		[self.m_webView reload];
	}
	self.m_loadingInterrupted = NO;
	
	[self enableBackButton:self.m_webView.canGoBack];
	[self enableFwdButton:self.m_webView.canGoForward];	
}


- (void)viewWillDisappear:(BOOL)animated 
{
	[self stopLoadingAnimation:nil];

	if ( self.m_shouldStopLoadingOnHide )
	{
		if ( self.m_webView.loading )
			self.m_loadingInterrupted = YES;
		[self stopLoading];
	}
	[super viewWillDisappear:animated];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	// Return YES for supported orientations
	return YES;
}


-(id)m_parentCtrl {
	return m_parentCtrl;
}

- (void)display:(id)parentController
{
	m_parentCtrl = parentController;
	m_authCallback = nil;
	if ( self.m_webView != nil )
	{
		//GREG!!!!
		[m_parentCtrl presentModalViewController:self animated:YES];
		//[self animate];
	}
	else
	{	// when would this ever happen????
		m_shouldDisplayOnViewLoad = YES;
		[self.view setNeedsDisplay];
	}
}


- (IBAction)closeButtonPressed:(id)button
{
	// dismiss the view
	if (m_parentCtrl /*&& [m_parentCtrl modalViewController]*/)
		[m_parentCtrl dismissModalViewControllerAnimated:YES];
	else
		[self.parentViewController dismissModalViewControllerAnimated:YES];
	//[self animate];
}


- (IBAction)backButtonPressed:(id)button
{
	if ( self.m_webView.canGoBack ) [self.m_webView goBack];
}


- (IBAction)fwdButtonPressed:(id)button
{
	if ( self.m_webView.canGoForward ) [self.m_webView goForward];
}


- (IBAction)refreshButtonPressed:(id)button
{
	if ( self.m_webView.loading )
	{
		[self stopLoading];
	}
	else 
	{
		[self.m_webView reload];
	}
}

- (IBAction)openInSafari:(id)button {
	if (self.m_currentURL) {
		[UtilityMethods openURLWithTrepidation:self.m_currentURL];
	}
}

- (IBAction)emailURL:(id)button {
	if (self.m_currentURL) {
		NSString *body = [NSString stringWithFormat:[UtilityMethods texLegeStringWithKeyPath:@"MailComposer.EmailingLinkText"],
						  self.m_currentURL.absoluteString];
		[[TexLegeEmailComposer sharedTexLegeEmailComposer] presentMailComposerTo:@"someone@example.com" 
																		 subject:[UtilityMethods texLegeStringWithKeyPath:@"MailComposer.EmailingLinkTitle"] 
																			body:body 
																	   commander:self];
	}
}

- (LinkObj *)link {
	LinkObj *anObject = nil;
	if (self.dataObjectID) {
		@try {
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.sortOrder == %@", self.dataObjectID];
			anObject = [TexLegeCoreDataUtils dataObjectWithPredicate:predicate entityName:@"LinkObj"];
		}
		@catch (NSException * e) {
		}
	}
	return anObject;
}

- (void)setLink:(LinkObj *)anObject {
	if (self.masterPopover)
		[self.masterPopover dismissPopoverAnimated:YES];
	
	self.dataObjectID = nil;
	if (anObject) {
		self.dataObjectID = [anObject sortOrder];

		if ([anObject.url isEqualToString:@"mailto:support@texlege.com"])
			[[TexLegeEmailComposer sharedTexLegeEmailComposer] presentMailComposerTo:@"support@texlege.com" 
																			 subject:@"TexLege Support Question" 
																				body:@"" 
																		   commander:[[TexLegeAppDelegate appDelegate] detailNavigationController]];
		else {
			// if we add escapes, we'll wind up junking our existing "safe" url string.  We do this since we don't allow editing links anymore.  
			//NSURL *aURL = [UtilityMethods safeWebUrlFromString:link.url];
			NSURL *aURL = [anObject actualURL];
			if (aURL && [TexLegeReachability canReachHostWithURL:aURL alert:YES]) { // got a network connection
				[self loadURL:aURL];
			}
			self.title = anObject.label;
		}
	}
	
}

- (void)loadURL:(NSURL *)url
{
	if (!url)
		return;
	
	self.m_currentURL = url;
	
	self.m_loadingInterrupted = NO;
	
	// cancel any transaction currently taking place
	if ( self.m_webView.loading ) [m_webView stopLoading];
	
	if ( [self.view isHidden] )
	{
		self.m_urlRequestToLoad = [[[NSURLRequest alloc] initWithURL:url] autorelease];
	}
	else
	{
		[self.m_webView loadRequest:[NSURLRequest requestWithURL:url 
													 cachePolicy:NSURLRequestUseProtocolCachePolicy 
												 timeoutInterval:90.0]];
	}
}


- (void)LoadRequest:(NSURLRequest *)urlRequest
{	
	self.m_loadingInterrupted = NO;
	
	// cancel any transaction currently taking place
	if ( self.m_webView.loading ) [self.m_webView stopLoading];
		
	if ( [self.view isHidden] )
	{
		self.m_urlRequestToLoad = urlRequest;
	}
	else
	{
		[self.m_webView loadRequest:urlRequest];
	}
}


- (void)stopLoading
{
	if ( self.m_webView.loading )
	{
		[self.m_webView stopLoading];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[self.m_activity stopAnimating];
		[self.m_loadingLabel setHidden:YES];
	}
}

- (SEL)m_authCallback {
	return m_authCallback;
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
	if (m_authCallback && m_parentCtrl)
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
	TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
	//debug_NSLog(@"Parent view %@", [m_parentCtrl view]);
	//debug_NSLog(@"my tabbar %@", [m_parentCtrl tabBarController].view);
	//debug_NSLog(@"Parent 1st nav view %@", [[[m_parentCtrl navigationController].viewControllers objectAtIndex:0] view]);
	
	UIView *topView = nil;
	if ( self.m_shouldUseParentsView )
	{
		topView = [m_parentCtrl view];
		if ( topView == nil )
		{
			if ([UtilityMethods isIPadDevice])
				topView = appDelegate.detailNavigationController.view;
			else
				topView = appDelegate.tabBarController.view;
				
		}
	}
	else
	{
		if ([UtilityMethods isIPadDevice])
			topView = appDelegate.detailNavigationController.view;
		else
			topView = appDelegate.tabBarController.view;
		
	}
	
	if (topView) {
		[topView retain];
		
		//debug_NSLog(@"%@", [topView description]);
		
		self.m_shouldUseParentsView = NO;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5f];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
		UIViewAnimationTransition flipTrans;
		
		if ( [self.view superview] ) // This happens when they click done: and we need to go back to the main view
		{
			//if ([UtilityMethods isLandscapeOrientation])
			//	flipTrans = UIViewAnimationTransitionCurlUp;
			//else
			flipTrans = UIViewAnimationTransitionFlipFromLeft;
			
			[UIView setAnimationTransition:flipTrans forView:topView cache:NO];
			[self.view removeFromSuperview];
		}
		else	// This happens when we first open the web view
		{
			//if ([UtilityMethods isLandscapeOrientation])
			//	flipTrans = UIViewAnimationTransitionCurlDown;
			//else
			flipTrans = UIViewAnimationTransitionFlipFromRight;
			
			[UIView setAnimationTransition:flipTrans forView:topView cache:NO];
			
			[self.view setFrame:[topView bounds]];
			[topView addSubview:self.view];
		}
		
		[UIView commitAnimations];
		
		[topView release];
	}
	
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
}


- (void)enableBackButton:(BOOL)enable
{
	[self.m_backButton setEnabled:enable];
}


- (void)enableFwdButton:(BOOL)enable
{
	[self.m_fwdButton setEnabled:enable];
}


#pragma mark UIWebViewDelegate Methods 

- (void)startLoadingAnimation:(id)sender {
	@try {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		if (self.m_activity)
			[self.m_activity startAnimating];
		if (self.m_loadingLabel)
			[self.m_loadingLabel setHidden:NO];
		if (self.m_webView)
		[self.m_webView setAlpha:0.75f];	
	}
	@catch (NSException * e) {
	}
}


- (void)stopLoadingAnimation:(id)sender {
	@try {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		if (self.m_activity)
			[self.m_activity stopAnimating];
		if (self.m_loadingLabel)
			[self.m_loadingLabel setHidden:YES];
		if (self.m_webView)
			[self.m_webView setAlpha:1.0f];	
	}
	@catch (NSException * e) {
	}
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	// notify of an error?
	if (m_toolBar && m_normalItemList)
		[self.m_toolBar setItems:m_normalItemList animated:NO];
	
	[self stopLoadingAnimation:nil];
	
	NSString *errorMsg = nil;
	NSString *errorTitle = nil;
    if (error && [[error domain] isEqualToString:NSURLErrorDomain]) {
        switch ([error code]) {
            case NSURLErrorCannotFindHost:
            case NSURLErrorCannotConnectToHost:
				errorTitle = [UtilityMethods texLegeStringWithKeyPath:@"Reachability.NoHostTitle"] ;
                errorMsg = [UtilityMethods texLegeStringWithKeyPath:@"Reachability.NoHostText"] ;
                break;
            case NSURLErrorNotConnectedToInternet:
				errorTitle = [UtilityMethods texLegeStringWithKeyPath:@"Reachability.NoInternetTitle"] ;
                errorMsg = [UtilityMethods texLegeStringWithKeyPath:@"Reachability.NoInternetText"] ;
                break;
            default:
                break;
        }
		if (!IsEmpty(errorMsg) && !IsEmpty(errorTitle)) {
			UIAlertView *alert = [[ UIAlertView alloc ] 
								  initWithTitle:errorTitle 
								  message:errorMsg  
								  delegate:nil 
								  cancelButtonTitle: @"Cancel" 
								  otherButtonTitles:nil, nil];
			
			[ alert show ];		
			[ alert release ];
		}
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	[self.m_toolBar setItems:self.m_loadingItemList animated:NO];
		
	//[self startLoadingAnimation:webView];
	
	// always start loading - we're not real restrictive here...
	return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{

	[self.m_toolBar setItems:self.m_normalItemList animated:NO];
	
	[self stopLoadingAnimation:webView];

	[self.m_webView setBackgroundColor:[TexLegeTheme backgroundLight]];

	[self enableBackButton:self.m_webView.canGoBack];
	[self enableFwdButton:self.m_webView.canGoForward];
	
	// set the navigation bar title based on URL
	NSString *docTitle = [self.m_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	if (!IsEmpty(docTitle))
		self.title = docTitle;
	else if (self.link)
		self.title = self.link.label;
	
	static NSString* js = @""
    "function bkModifyBaseTargets()"
	"{"
		"var allBases = window.document.getElementsByTagName('base');"
		"if (allBases)"
		"{"
			"for (var i = 0; i < allBases.length; i++)"
			"{"
				"base = allBases[i];"
				"target = base.getAttribute('target');"
				"if (target)"
				"{"
					"base.setAttribute('target', '_self');"
				"}"
			"}"
		"}"
    "}";
	[self.m_webView stringByEvaluatingJavaScriptFromString: js];
    [self.m_webView stringByEvaluatingJavaScriptFromString: @"bkModifyBaseTargets()"];
	
	if (self.m_webView.request && !self.userAgent) {
		//debug_NSLog(@"%@", [self.m_webView.request allHTTPHeaderFields]);
		self.userAgent = [self.m_webView.request valueForHTTPHeaderField:@"User-Agent"];
		if (self.userAgent) {
			//debug_NSLog(@"User Agent: %@", userAgent);
			NSDictionary *userAgentDict = [NSDictionary dictionaryWithObject:self.userAgent forKey:@"userAgent"];
			[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"BROWSER_USER_AGENT" attributes:userAgentDict];
		}
	}
	
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[self startLoadingAnimation:webView];
	
	for (UIBarButtonItem *item in m_toolBar.items) {
		if (item.tag == eTAG_EMAILURL || item.tag == eTAG_SAFARI)
			item.enabled = ([m_currentURL.absoluteString hasPrefix:@"http"] || 
							[m_currentURL.absoluteString hasPrefix:@"ftp"] );
	}
		
	self.title = @"Loading...";
}

@end
