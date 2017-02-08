//
//  SLToastManager.h
//  SLToastKit
//
//  Created by Gregory Combs on 7/10/16.
//  Copyright (C) 2016 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.
//

#import <UIKit/UIKit.h>
#import "SLToast.h"

@interface SLToastManager : NSObject

- (nonnull instancetype)initWithManagerId:(nonnull NSString *)managerId parentView:(nullable UIView *)parentView NS_DESIGNATED_INITIALIZER;

@property (nonatomic,assign) CGRect statusBarFrame; // you should provide this if parentView is a UIWindow
@property (nonatomic,copy,readonly,nonnull) NSString *managerId;
@property (nonatomic,weak,nullable) UIView *parentView;

/**
 *  A convenience for instantiating an SLToast then calling addToast:
 */
- (BOOL)addToastWithIdentifier:(nonnull NSString *)identifier type:(SLToastType)type title:(nullable NSString *)title subtitle:(nullable NSString *)subtitle image:(nullable UIImage *)image duration:(NSTimeInterval)duration;

- (BOOL)addToast:(nonnull SLToast *)toast;
- (BOOL)removeToast:(nonnull SLToast *)toast;
- (nullable SLToast *)pullNext;

/**
 *  The number of toast items pending in the queue, as well
 *  as the toast currently presenting to the user (if any).
 */
@property (nonatomic,readonly) NSUInteger activeToastCount;

/**
 *  The total number of toast items in the manager's queue.
 *  NOTE: Thie calculation will include dormant toast that 
 *  have already been shown/finished/dismissed as well as
 *  those still pending in the queue, waiting for showtime.
 */
@property (nonatomic,readonly) NSUInteger totalToastCount;

#if defined(SLToast_Use_Nag_Limiter) && SLToast_Use_Nag_Limiter == 1
- (void)resetNagLimiter;
#endif

@end
