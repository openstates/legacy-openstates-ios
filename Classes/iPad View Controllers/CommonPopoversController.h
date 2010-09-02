//
//  CommonPopoversController.h
//  TexLege
//
//  Created by Gregory Combs on 8/9/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@interface CommonPopoversController : NSObject <UIPopoverControllerDelegate> {
}

+ (CommonPopoversController *)sharedCommonPopoversController;

@property (nonatomic,retain) UIPopoverController *masterListPopoverPC;
@property (nonatomic) BOOL isOpening;


- (IBAction)resetPopoverMenus:(id)sender;

- (IBAction)displayMasterListPopover:(id)sender;
- (IBAction)dismissMasterListPopover:(id)sender;

@end
