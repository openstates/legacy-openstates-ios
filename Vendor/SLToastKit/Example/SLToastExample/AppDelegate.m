//
//  AppDelegate.m
//  SLToastKit
//
//  Created by Gregory Combs on 7/10/16.
//  Copyright (C) 2016 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import "AppDelegate.h"
@import SLToastKit;

@interface AppDelegate ()
@property (nonatomic,strong) SLToastManager *toastManager;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    SLToastManager *toastMgr = [[SLToastManager alloc] initWithManagerId:@"exampleToaster" parentView:self.window];
    toastMgr.statusBarFrame = [application statusBarFrame]; // important -- when parentView is a window
    self.toastManager = toastMgr;
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    SLToastManager *toastMgr = self.toastManager;
    if (toastMgr)
    {
        toastMgr.statusBarFrame = [application statusBarFrame];
        
#if SLToast_Use_Nag_Limiter == 1
        [toastMgr resetNagLimiter];
#endif
        
    }
    [self triggerSomeToasts];
}

- (void)triggerSomeToasts
{

    [self simulateBenignToasts];
    [self simulateMalignantToast];
}

- (void)simulateBenignToasts
{
    NSLog(@"simulating an activity toast ...");
    [self.toastManager addToastWithIdentifier:@"ExampleActivity"
                                        type:SLToastTypeActivity
                                       title:@"Processing Some Events"
                                    subtitle:@"It'll only take a few seconds"
                                       image:nil
                                    duration:4];

    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf)
            return;
        
        SLToastManager *toastMgr = strongSelf.toastManager;
        
        NSLog(@"simulating an informational toast ...");
        [toastMgr addToastWithIdentifier:@"ExampleInfo"
                                   type:SLToastTypeInfo
                                  title:@"Reviewing Results"
                               subtitle:@"Almost done"
                                  image:nil
                               duration:3];
        
        NSLog(@"simulating a success ...");
        [toastMgr addToastWithIdentifier:@"ExampleCompletion"
                                   type:SLToastTypeSuccess
                                  title:@"I think we're done"
                               subtitle:@"Yep ... pretty sure"
                                  image:nil
                               duration:3];
        
        NSLog(@"simulating a warning ...");
        [toastMgr addToastWithIdentifier:@"ExampleWarning"
                                   type:SLToastTypeWarning
                                  title:@"Sensing a disturbance"
                               subtitle:@"Hold up; something seems dodgy"
                                  image:nil
                               duration:3];
    });
}

- (void)simulateMalignantToast
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf)
            return;
        NSLog(@"simulating an error ...");
        [strongSelf.toastManager addToastWithIdentifier:@"ExampleError"
                                             type:SLToastTypeError
                                            title:@"Found something bad"
                                         subtitle:@"Hard to describe how awful it is. I mean, it's just terrible.  'Terrible!', I say.  I hope you find the cause and a fix, because I'm totally at a loss for words.  Tons of sympathy for you though.  Cheers."
                                            image:nil
                                         duration:-1];

        [strongSelf simulateAllClear];
    });
}

- (void)simulateAllClear
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf)
            return;
        NSLog(@"simulating an all-clear...");
        
        [strongSelf.toastManager addToastWithIdentifier:@"ExampleNevermind"
                                                   type:SLToastTypeSuccess
                                                  title:@"On second thought, nevermind ..."
                                               subtitle:@"We're good. Celebrate."
                                                  image:nil
                                               duration:4];
        
    });
}

@end
