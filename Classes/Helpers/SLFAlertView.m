//
//  SLFAlertView.m (Excerpted from "iOS Recipes" by The Pragmatic Bookshelf)
//  Created by Gregory Combs on 3/14/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFAlertView.h"
#import <Foundation/Foundation.h>

@interface SLFAlertView ()

@property (nonatomic, copy) SLFAlertBlock cancelBlock;
@property (nonatomic, copy) SLFAlertBlock otherBlock;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, copy) NSString *otherButtonTitle;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *shadowColor;
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
@synthesize fillColor = _fillColor;
@synthesize shadowColor = _shadowColor;

+ (void)showWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle {
    [self showWithTitle:title message:message cancelTitle:buttonTitle cancelBlock:nil otherTitle:nil otherBlock:nil];
}

+ (void)showWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle cancelBlock:(SLFAlertBlock)cancelBlk otherTitle:(NSString *)otherTitle otherBlock:(SLFAlertBlock)otherBlk {
    SLFAlertView *alert = [[SLFAlertView alloc] initWithTitle:title message:message cancelTitle:cancelTitle cancelBlock:cancelBlk otherTitle:otherTitle otherBlock:otherBlk];
    [alert show];
    //[alert autorelease];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle cancelBlock:(SLFAlertBlock)cancelBlk otherTitle:(NSString *)otherTitle otherBlock:(SLFAlertBlock)otherBlk {
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:otherTitle, nil];
    if (self) {
        if (cancelBlk == nil && otherBlk == nil) {
            self.delegate = nil;
        }
        self.cancelButtonTitle = cancelTitle;
        self.otherButtonTitle = otherTitle;
        self.cancelBlock = cancelBlk;
        self.otherBlock = otherBlk;
        self.shadowColor = [UIColor grayColor];
        self.fillColor = [UIColor blackColor];
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
    cancelButtonTitle = nil;
    otherButtonTitle = nil;
    cancelBlock = nil;
    otherBlock = nil;
}

@end
