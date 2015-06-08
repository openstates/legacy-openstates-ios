//
//  StatesPopoverManager.h
//  Created by Greg Combs on 11/13/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <Foundation/Foundation.h>
#import "StatesViewController.h"

@class StatesPopoverManager;
@protocol StatesPopoverDelegate <NSObject>
@required
- (void)statePopover:(StatesPopoverManager *)statePopover didSelectState:(SLFState *)newState;
@optional
- (void)statePopoverDidCancel:(StatesPopoverManager *)statePopover;
@end

@interface StatesPopoverManager : NSObject <StateMenuSelectionDelegate, UIPopoverControllerDelegate>
+ (StatesPopoverManager *)showFromOrigin:(id)origin delegate:(id<StatesPopoverDelegate>)delegate;
- (void)dismissPopover:(BOOL)animated;
@end
                                
