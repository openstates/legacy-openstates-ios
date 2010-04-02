/*

File: AtomicElementView.h
Abstract: Displays the Atomic Element information in a large format tile.

Version: 1.7

*/

 
#import <UIKit/UIKit.h>

@class AtomicElement;
@class DetailTableViewController;

@interface AtomicElementView : UIView {
	AtomicElement *element;
	DetailTableViewController *viewController;
}

@property (nonatomic,retain) AtomicElement *element;
@property (nonatomic, assign) DetailTableViewController *viewController;

+ (CGSize)preferredViewSize;
- (UIImage *)reflectedImageRepresentationWithHeight:(NSUInteger)height;
@end
