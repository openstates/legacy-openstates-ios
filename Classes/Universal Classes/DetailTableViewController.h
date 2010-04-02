/*

File: DetailTableViewController.h
Abstract: Controller that manages the full tile view of the atomic information,
creating the reflection, and the flipping of the tile.


*/

 
#import <UIKit/UIKit.h>

//#import "MapImageView.h"

@class AtomicElement;
@class AtomicElementView;
@class AtomicElementFlippedView;


@interface DetailTableViewController : UIViewController {
	AtomicElement *element;
	
	AtomicElementView *atomicElementView;
	AtomicElementFlippedView *atomicElementFlippedView;
	
	UIImageView *reflectionView;
	UIView *containerView;	
	UIButton *flipIndicatorButton;	
	BOOL frontViewIsVisible;
	
	NSString *mapFileName;
//	MapImageView *mapImageView;
	
	UIWebView *webPDFView;

}

@property (assign) BOOL frontViewIsVisible;
@property (nonatomic,retain) AtomicElement *element;
@property (nonatomic,retain) UIView *containerView;
@property (nonatomic,retain) AtomicElementView *atomicElementView;
@property (nonatomic,retain) UIImageView *reflectionView;
@property (nonatomic,retain) AtomicElementFlippedView *atomicElementFlippedView;
@property (nonatomic,retain) UIButton *flipIndicatorButton;

//@property (nonatomic,retain) MapImageView *mapImageView;
@property (nonatomic,retain) NSString *mapFileName;
@property (nonatomic,retain) UIWebView *webPDFView;


- (void)flipCurrentView;
- (void)transitionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;


@end
