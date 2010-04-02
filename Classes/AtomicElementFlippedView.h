/*

File: AtomicElementFlippedView.h
Abstract: Displays the Atomic Element information with a link to Wikipedia.

Version: 1.7

*/

#import <UIKit/UIKit.h>
#import "AtomicElementView.h"

@interface AtomicElementFlippedView : AtomicElementView {
	UIButton *wikipediaButton;
}
 
@property (nonatomic,retain) UIButton *wikipediaButton;
 

@end
