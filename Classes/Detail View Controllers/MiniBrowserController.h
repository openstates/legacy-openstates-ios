//
//  MiniBrowserController.h
//  TexLege
//

#import <UIKit/UIKit.h>

@class LinkObj;
@interface MiniBrowserController : UIViewController <UIWebViewDelegate, UISplitViewControllerDelegate>
{
}

@property BOOL m_loadingInterrupted;
@property (retain) NSURLRequest *m_urlRequestToLoad;
@property (retain) IBOutlet UIActivityIndicatorView *m_activity;
@property (retain) IBOutlet UILabel					*m_loadingLabel;
@property (retain) NSArray *m_normalItemList;
@property (retain) NSArray *m_loadingItemList;
@property BOOL m_shouldDisplayOnViewLoad;
@property (assign,setter=display:) id m_parentCtrl;
@property (setter=setAuthCallback:) SEL m_authCallback;

@property (nonatomic,retain) IBOutlet UIToolbar *m_toolBar;
@property (nonatomic,retain) IBOutlet UIWebView *m_webView;
@property (nonatomic) BOOL m_shouldUseParentsView;
@property (nonatomic) BOOL m_shouldStopLoadingOnHide;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *m_backButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *m_reloadButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *m_fwdButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *m_doneButton;
@property (nonatomic,retain) NSURL *m_currentURL;
@property (nonatomic,retain) UIColor *sealColor;
@property (nonatomic,retain) LinkObj *link;
@property (nonatomic) BOOL m_shouldHideDoneButton;
@property (nonatomic) BOOL isSharedBrowser;

+ (MiniBrowserController *)sharedBrowser;
+ (MiniBrowserController *)sharedBrowserWithURL:(NSURL *)urlOrNil;

- (void)display:(id)parentController;

@property (nonatomic, retain) UIPopoverController *masterPopover;

- (IBAction)closeButtonPressed:(id)button;
- (IBAction)backButtonPressed:(id)button;
- (IBAction)fwdButtonPressed:(id)button;
- (IBAction)refreshButtonPressed:(id)button;
- (IBAction)openInSafari:(id)button;

- (void)loadURL:(NSURL *)url;
- (void)LoadRequest:(NSURLRequest *)urlRequest;
- (void)stopLoading;
- (void)removeDoneButton;

- (void)setAuthCallback:(SEL)callback;
- (void)authCompleteCallback;

@end
