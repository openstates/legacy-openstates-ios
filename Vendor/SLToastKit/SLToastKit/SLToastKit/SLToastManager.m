//
//  SLToastManager.m
//  SLToastKit
//
//  Created by Gregory Combs on 7/10/16.
//  Copyright (C) 2016 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.
//

#import "SLToastManager.h"
#import "SLToast.h"
#import "SLToastView.h"
#import "SLTypeCheck.h"
#import "SLToastObserver.h"

@interface SLToastManager()<SLToastObserver>
@property (nonatomic,copy,nonnull) NSString *managerId;
@property (nonatomic,copy) NSMutableOrderedSet<SLToast *> *store;
@property (nonatomic,strong) SLToastView *toastView;

#if SLToast_Use_Nag_Limiter == 1
@property (nonatomic,assign,getter=isDismissedRecently) BOOL dismissedRecently;
@property (nonatomic,weak) NSTimer *nagLimitTimer;
#endif

@end

@implementation SLToastManager


- (instancetype)initWithManagerId:(NSString *)managerId parentView:(UIView *)parentView
{
    self = [super init];
    if (self)
    {
        if (!SLTypeNonEmptyStringOrNil(managerId))
            managerId = @"DefaultInfoPanelManager";
        _managerId = [managerId copy];
        _parentView = parentView;
        UIWindow *parentWindow = SLValueIfClass(UIWindow, parentView);
        if (parentWindow)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(willChangeStatusBarFrame:)
                                                         name:UIApplicationWillChangeStatusBarFrameNotification
                                                       object:nil];
        }
        _store = [[NSMutableOrderedSet alloc] init];
    }
    return self;
}

- (void)willChangeStatusBarFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (!userInfo)
        return;
    NSValue *frameValue = userInfo[UIApplicationStatusBarFrameUserInfoKey];
    if (!frameValue)
        return;
    CGRect statusBarFrame = [frameValue CGRectValue];
    self.statusBarFrame = statusBarFrame;
    self.toastView.statusBarFrame = statusBarFrame;
}

- (instancetype)init
{
    self = [self initWithManagerId:@"" parentView:nil];
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_toastView)
        _toastView.toastManager = nil;

#if SLToast_Use_Nag_Limiter == 1
    if (_nagLimitTimer)
        [_nagLimitTimer invalidate];
    _nagLimitTimer = nil;
#endif
}

- (NSUInteger)totalToastCount
{
    return self.store.count;
}

- (NSUInteger)activeToastCount
{
    NSUInteger toastCount = 0;
    for (SLToast *toast in self.store)
    {
        switch (toast.status) {
            case SLToastStatusQueued:
            case SLToastStatusShowing:
                toastCount++;
                break;
            case SLToastStatusUnknown:
            case SLToastStatusSkipped:
            case SLToastStatusFinished:
                break;
        }
        if (toast.status != SLToastStatusQueued
            && toast.status != SLToastStatusFinished)
        {
            toast.status = SLToastStatusUnknown;
        }
    }
    return toastCount;
}

- (nullable SLToast *)currentToast
{
    SLToast *viewToast = self.toastView.toast;
    if (viewToast)
    {
        if (viewToast.status == SLToastStatusShowing
            || viewToast.status == SLToastStatusQueued)
        {
            return viewToast;
        }
    }

    SLToast *foundToast = nil;
    for (SLToast *toast in self.store)
    {
        if (toast.status == SLToastStatusShowing)
        {
            foundToast = toast;
            break;
        }
    }
    return foundToast;
}

- (void)setParentView:(UIView *)parentView
{
    UIView *oldView = _parentView;
    _parentView = parentView;
    if (!parentView)
        return;
    if (oldView && [oldView isEqual:parentView])
        return;
    if (self.activeToastCount == 0)
        return;
    [self showToastViewIfPossible];
}

- (BOOL)addToast:(nonnull SLToast *)toast
{
    if (!SLValueIfClass(SLToast, toast))
        return NO;

    [self.store addObject:toast];

    toast.status = SLToastStatusQueued;
    BOOL success = YES;

    UIView *parentView = self.parentView;
    if (!parentView)
        return success; // we've queued it and will show once we have a parentView

    success = [self showToastViewIfPossible];

    return success;
}

- (BOOL)addToastWithIdentifier:(nonnull NSString *)identifier type:(SLToastType)type title:(nullable NSString *)title subtitle:(nullable NSString *)subtitle image:(nullable UIImage *)image duration:(NSTimeInterval)duration
{
    SLToast *toast = [SLToast toastWithIdentifier:identifier type:type title:title subtitle:subtitle image:image duration:duration];
    if (!toast)
        return NO;
    return [self addToast:toast];
}

- (BOOL)removeToast:(nonnull SLToast *)toast
{
    if (!SLValueIfClass(SLToast, toast))
        return NO;
    NSUInteger index = [self.store indexOfObject:toast];
    if (index == NSNotFound || self.store.count <= index)
        return NO;
    [self.store removeObjectAtIndex:index];
    if (toast.status == SLToastStatusQueued)
        toast.status = SLToastStatusUnknown;
    return YES;
}

- (nullable SLToast *)pullNext
{
    __block SLToast *toast = nil;

    if (self.store.count)
    {
        NSMutableArray<SLToast *> *toastsToRemove = [[NSMutableArray alloc] init];

        //NSMutableIndexSet *toastsToRemove = [NSMutableIndexSet indexSet];
        [self.store enumerateObjectsUsingBlock:^(SLToast * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (toast.status == SLToastStatusSkipped)
            {
                [toastsToRemove addObject:obj];
                return;  // keep iterating until we find one that isn't skipped
            }
            else
            {
                toast = [obj copy];
                [toastsToRemove addObject:obj];
                *stop = YES;
                return;
            }
        }];

        if (!toastsToRemove.count)
            return toast;

        [self.store removeObjectsInArray:toastsToRemove];
    }

    return toast;
}

- (BOOL)showToastViewIfPossible
{
    if (!self.activeToastCount)
        return NO;

    SLToastView *toastView = self.toastView;
    if (toastView
        && toastView.superview
        && toastView.toast
        && toastView.toast.status == SLToastStatusShowing)
    {
        if (!toastView.toastManager)
            toastView.toastManager = self;
        return YES;
    }

    UIView *parentView = self.parentView;
    if (!parentView)
        return NO; // At least, *not yet*. We've already queued it and will show once we have a parentView

    UIWindow *parentAsWindow = SLValueIfClass(UIWindow, parentView);

    SLToast *toast = [self pullNext];
    if (!toast)
        return NO; // should we log an error or exception? This should be impossible.

    SLToastView *(^showToastViewBlock)(UIView *parentView, SLToast *toast) = nil;

    if (parentAsWindow)
    {
        CGRect statusBarFrame = self.statusBarFrame;
        showToastViewBlock = ^(UIView *parentView, SLToast *toast)
        {
            return [SLToastView showToastInWindow:(UIWindow *)parentView statusBarFrame:statusBarFrame toast:toast];
        };
    }
    else
    {
        showToastViewBlock = ^(UIView *parentView, SLToast *toast)
        {
            return [SLToastView showToastInView:parentView toast:toast];
        };
    }

    if (!toastView)
    {
        toastView = showToastViewBlock(parentView,toast);
        if (toastView)
        {
            toastView.toastManager = self;
            self.toastView = toastView;
            return YES;
        }
    }

    if (!toastView.superview)
    {
        
//#if SLToast_Use_Nag_Limiter == 1
        // was dismissed??
//        if (!self.isDismissedRecently ||
//            toast.type == SLToastTypeError)
//#endif
//        {
            toastView = showToastViewBlock(parentView,toast);
            if (toastView)
            {
                toastView.toastManager = self;
                self.toastView = toastView;
                return YES;
            }
//        }
    }

    if (!toastView.toastManager)
        toastView.toastManager = self;
    toastView.statusBarFrame = self.statusBarFrame;
    return [toastView showToast:toast];
}

- (void)userDismissedToast:(SLToast *)toast
{
    
#if SLToast_Use_Nag_Limiter == 1

    if (toast && toast.duration <= 0)
    {
        /* if the toast *required* user interactino to dismiss it, (i.e. errors)
           don't count it as a "nag" worthy of limiting and don't force-skip
           subsequent "non-essential" toasts. */
        return;
    }
    
    self.dismissedRecently = YES;

    NSMutableOrderedSet *onlyEssential = [[NSMutableOrderedSet alloc] init];
    
    for (SLToast *toast in self.queue)
    {
        if (toast.status == SLToastStatusShowing
            || toast.status == SLToastStatusSkipped
            || toast.status == SLToastStatusFinished)
        {
            continue;
        }
        
        if (toast.type >= SLToastTypeWarning)
            [onlyEssential addObject:toast];
        else
            toast.status = SLToastStatusSkipped;
    }
    
    if (self.nagLimitTimer)
        [self.nagLimitTimer invalidate];

    self.store = onlyEssential;
    
    __weak typeof(self) weakSelf = self;
    self.nagLimitTimer = [NSTimer scheduledTimerWithTimeInterval:7 repeats:NO block:^(NSTimer * _Nonnull timer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf)
            return;
        strongSelf.dismissedRecently = NO;
    }];
    
#else
    if (toast)
    {
        toast.status = SLToastStatusSkipped; // ??
    }
#endif
    
}

#if SLToast_Use_Nag_Limiter == 1

- (void)resetNagLimiter
{
    self.dismissedRecently = NO;
    
    if (self.nagLimitTimer)
        [self.nagLimitTimer invalidate];
    self.nagLimitTimer = nil;
}

#endif

@end
