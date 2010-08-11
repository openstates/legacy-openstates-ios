//
//  TexLegeEmailComposer.h
//  TexLege
//
//  Created by Gregory Combs on 8/10/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "SynthesizeSingleton.h"
#import "Constants.h"

@interface TexLegeEmailComposer : NSObject <MFMailComposeViewControllerDelegate,UIAlertViewDelegate>
{

}
@property (nonatomic, retain) IBOutlet MFMailComposeViewController *mailComposerVC;
@property (nonatomic, retain) IBOutlet UIAlertView *currentAlert;
@property (nonatomic) BOOL isComposingMail;

+ (TexLegeEmailComposer *)sharedTexLegeEmailComposer;
- (void)presentMailComposerTo:(NSString*)recipient subject:(NSString*)subject body:(NSString*)body;


@end
