/*

File: AtomicElementTableViewCell.h
Abstract: Draws the tableview cell and lays out the subviews.

Version: 1.7

*/

#import <UIKit/UIKit.h>

@class AtomicElement;
@class AtomicElementTileView;


@interface AtomicElementTableViewCell : UITableViewCell {
	AtomicElement *element;
	AtomicElementTileView *elementTileView;
	UILabel *labelView;
}
 
@property (nonatomic,retain) AtomicElement *element;
@property (nonatomic,retain) AtomicElementTileView *elementTileView;
@property (nonatomic,retain) UILabel *labelView;

@end
