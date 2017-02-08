//
//  SLToastView.h
//  SLToastKit
//
//  Created by Gregory Combs on 7/10/16.
//  Copyright (C) 2016 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.
//

#import <UIKit/UIKit.h>
#import <SLToastKit/SLToast.h>

@class SLToastManager;

NS_ASSUME_NONNULL_BEGIN

@interface SLToastView : UIView

+ (nullable instancetype)showToastInView:(UIView *)parentView
                                   toast:(SLToast *)toast;

+ (nullable instancetype)showToastInWindow:(UIWindow *)parentWindow
                            statusBarFrame:(CGRect)statusBarFrame
                                     toast:(SLToast *)toast;

- (BOOL)showToast:(SLToast *)toast;

+ (nullable instancetype)toastViewWithFrame:(CGRect)frame toast:(SLToast *)toast;

@property (nonatomic,strong,nullable,readonly) SLToast *toast;
@property (nonatomic,weak) SLToastManager *toastManager;
@property (nonatomic,assign) CGRect statusBarFrame; // If the parentView is a UIWindow, we'll need this

@end

NS_ASSUME_NONNULL_END

