//
//  StartupSplashViewManager.h
//  TexLege
//
//  Created by Gregory Combs on 8/13/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SynthesizeSingleton.h"

@interface StartupSplashViewManager : NSObject {
}

@property (nonatomic,retain) IBOutlet UIView *splashView;
@property (nonatomic,retain) IBOutlet UIViewController *masterVC;

+ (StartupSplashViewManager *)sharedStartupSplashViewManager;
@end
