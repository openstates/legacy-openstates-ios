//
//  SLToastManager+OpenStates.h
//  OpenStates
//
//  Created by Gregory Combs on 12/26/16.
//  Copyright © 2016 Gregory S. Combs. All rights reserved.
//

#import <SLToastKit/SLToastKit.h>

@interface SLToastManager (OpenStates)

+ (nullable instancetype)opstSharedManager;
+ (void)opstSetSharedManager:(nullable SLToastManager *)manager;

@end
