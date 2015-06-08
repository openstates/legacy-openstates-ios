//
//  SLFAlertView.h (Excerpted from "iOS Recipes" by The Pragmatic Bookshelf)
//  Created by Gregory Combs on 3/14/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


typedef void(^SLFAlertBlock)(void);

@interface SLFAlertView : UIAlertView {}

+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
          buttonTitle:(NSString *)buttonTitle;

+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message 
          cancelTitle:(NSString *)cancelTitle 
          cancelBlock:(SLFAlertBlock)cancelBlock
           otherTitle:(NSString *)otherTitle
           otherBlock:(SLFAlertBlock)otherBlock;

@end
