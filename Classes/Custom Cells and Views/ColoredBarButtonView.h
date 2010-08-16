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

@property (retain, nonatomic) UIColor *colorGrad1;
@property (retain, nonatomic) UIColor *colorGrad2;
@property (retain, nonatomic) UIColor *colorGrad3;
@property (retain, nonatomic) UIColor *colorGrad4;
@property (retain, nonatomic) UIColor *colorGrad5;

//@property (nonatomic, retain) NSString *title;

- (UIImage *)imageFromUIView;
- (void)setColorGrad:(UIColor *)value atIndex:(NSInteger)index;

@end
