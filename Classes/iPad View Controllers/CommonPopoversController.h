//
//  CommonPopoversController.h
//  TexLege
//
//  Created by Gregory Combs on 8/9/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@class MenuPopoverViewController;

@interface CommonPopoversController : NSObject <UIPopoverControllerDelegate> {
}

+ (CommonPopoversController *)sharedCommonPopoversController;

@property (nonatomic,retain) UIPopoverController *masterListPopoverPC;
@property (nonatomic,retain) UIPopoverController *mainMenuPopoverPC;
@property (nonatomic,retain) IBOutlet MenuPopoverViewController *mainMenuPopoverVC;
@property (nonatomic,readonly) IBOutlet UIViewController *currentMasterViewController;
@property (nonatomic,readonly) IBOutlet UIViewController *currentDetailViewController;
@property (nonatomic) BOOL isOpening;


- (IBAction)resetPopoverMenus:(id)sender;

- (IBAction)displayMasterListPopover:(id)sender;
- (IBAction)dismissMasterListPopover:(id)sender;

- (IBAction)displayMainMenuPopover:(id)sender;
- (IBAction)dismissMainMenuPopover:(id)sender;
	
@end
