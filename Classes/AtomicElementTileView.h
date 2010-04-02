/*

File: AtomicElementTileView.h
Abstract: Draws the small tile view displayed in the tableview rows.

Version: 1.7

*/

#import <UIKit/UIKit.h>

@class AtomicElement;

@interface AtomicElementTileView : UIView {
	AtomicElement *element;
}
 
@property (nonatomic, retain) AtomicElement *element;

+ (CGSize)preferredViewSize;

@end
