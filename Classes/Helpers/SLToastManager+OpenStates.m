//
//  SLToastManager+OpenStates.m
//  OpenStates
//
//  Created by Gregory Combs on 12/26/16.
//  Copyright © 2016 Gregory S. Combs. All rights reserved.
//

#import "SLToastManager+OpenStates.m"
#import <SLToastKit/SLToastKit.h>

static SLToastManager *_opstSharedToastManager;

@implementation SLToastManager (OpenStates)

+ (instancetype)opstSharedManager
{
    return _opstSharedToastManager;
}

+ (void)opstSetSharedManager:(SLToastManager *)manager
{
    _opstSharedToastManager = manager;
}

@end
