//
//  SLFAlertView.m (Excerpted from "iOS Recipes" by The Pragmatic Bookshelf)
//  Created by Gregory Combs on 3/14/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFAlertView.h"

@interface SLFAlertView ()

@property (nonatomic, copy) SLFAlertBlock cancelBlock;
@property (nonatomic, copy) SLFAlertBlock otherBlock;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, copy) NSString *otherButtonTitle;

- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message 
        cancelTitle:(NSString *)cancelTitle 
        cancelBlock:(SLFAlertBlock)cancelBlock
         otherTitle:(NSString *)otherTitle
         otherBlock:(SLFAlertBlock)otherBlock;

@end

@implementation SLFAlertView

@synthesize cancelBlock;
@synthesize otherBlock;
@synthesize cancelButtonTitle;
@synthesize otherButtonTitle;

+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
          buttonTitle:(NSString *)buttonTitle {
    [self showWithTitle:title message:message
            cancelTitle:buttonTitle cancelBlock:nil
             otherTitle:nil otherBlock:nil];
}

+ (void)showWithTitle:(NSString *)title 
              message:(NSString *)message 
          cancelTitle:(NSString *)cancelTitle 
          cancelBlock:(SLFAlertBlock)cancelBlk
           otherTitle:(NSString *)otherTitle
           otherBlock:(SLFAlertBlock)otherBlk {
    [[[[self alloc] initWithTitle:title message:message
                      cancelTitle:cancelTitle cancelBlock:cancelBlk
                       otherTitle:otherTitle otherBlock:otherBlk]
      autorelease] show];                           
}

- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message 
        cancelTitle:(NSString *)cancelTitle 
        cancelBlock:(SLFAlertBlock)cancelBlk
         otherTitle:(NSString *)otherTitle
         otherBlock:(SLFAlertBlock)otherBlk {
		 
    if ((self = [super initWithTitle:title 
                             message:message
                            delegate:self
                   cancelButtonTitle:cancelTitle 
                   otherButtonTitles:otherTitle, nil])) {
				   
        if (cancelBlk == nil && otherBlk == nil) {
            self.delegate = nil;
        }
        self.cancelButtonTitle = cancelTitle;
        self.otherButtonTitle = otherTitle;
        self.cancelBlock = cancelBlk;
        self.otherBlock = otherBlk;
    }
    return self;
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:self.cancelButtonTitle]) {
        if (self.cancelBlock) self.cancelBlock();
    } else if ([buttonTitle isEqualToString:self.otherButtonTitle]) {
        if (self.otherBlock) self.otherBlock();
    }
}

- (void)dealloc {
    [cancelButtonTitle release], cancelButtonTitle = nil;
    [otherButtonTitle release], otherButtonTitle = nil;
    [cancelBlock release], cancelBlock = nil;
    [otherBlock release], otherBlock = nil;
    [super dealloc];
}

@end