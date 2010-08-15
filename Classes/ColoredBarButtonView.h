//
//	ColoredBarButtonView.h
//	Green Button
//
//	Created by Gregory Combs on 8/14/10
//

#import <UIKit/UIKit.h>

extern const CGFloat kMyViewWidth;
extern const CGFloat kMyViewHeight;

@interface ColoredBarButtonView : UIView

@property (nonatomic) BOOL green, selected;
@property (nonatomic, retain) NSString *title;
@end
