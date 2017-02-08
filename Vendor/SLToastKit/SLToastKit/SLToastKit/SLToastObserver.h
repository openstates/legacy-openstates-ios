//
//  SLToastObserver.h
//  SLToastKit
//
//  Created by Greg Combs on 12/24/16.
//  Copyright (C) 2016 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.
//

#import <Foundation/Foundation.h>

@class SLToast;

@protocol SLToastObserver <NSObject>

@required

- (void)userDismissedToast:(nonnull SLToast *)toast;

@end
