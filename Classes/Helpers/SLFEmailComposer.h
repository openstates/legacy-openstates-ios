//
//  SLFEmailComposer.h
//  Created by Gregory Combs on 8/10/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <MessageUI/MessageUI.h>

@interface SLFEmailComposer : NSObject <MFMailComposeViewControllerDelegate>
@property (nonatomic) BOOL isComposingMail;
+ (SLFEmailComposer *)sharedComposer;
- (void)presentMailComposerTo:(NSString*)recipient subject:(NSString*)subject body:(NSString*)body parent:(UIViewController *)parent;
- (void)presentAppSupportComposerFromParent:(UIViewController *)parent;
@end
