//
//  SLFAlertView.h (Excerpted from "iOS Recipes" by The Pragmatic Bookshelf)
//  Created by Gregory Combs on 3/14/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

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
