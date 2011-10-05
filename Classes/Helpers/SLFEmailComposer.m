//
//  SLFEmailComposer.m
//  Created by Gregory Combs on 8/10/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <RestKit/RestKit.h>
#import "SLFEmailComposer.h"
#import "SLFAlertView.h"

@implementation SLFEmailComposer

@synthesize mailComposerVC, isComposingMail, currentCommander;

+ (id)sharedSLFEmailComposer
{
	static dispatch_once_t pred;
	static SLFEmailComposer *foo = nil;
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}

- (id) init
{
    if ((self = [super init]))
    {
		isComposingMail = NO;
		mailComposerVC = nil;
		currentCommander = nil;
    }
    return self;
}

- (void)dealloc {
	self.mailComposerVC = nil;
	self.currentCommander = nil;
    [super dealloc];
}

- (BOOL)isNetworkAvailableForURL:(NSURL *)url {
    if (![RKObjectManager sharedManager].isOnline)
        return NO;
    if (![[UIApplication sharedApplication] canOpenURL:url])
        return NO;
    return YES;
}

- (void)presentMailComposerTo:(NSString*)recipient 
					  subject:(NSString*)subject 
						 body:(NSString*)body 
					commander:(UIViewController *)commander{
	if (!commander)
		return;
	
	self.currentCommander = commander;
	
	if (!body)
		body = @"";
	
	if ([MFMailComposeViewController canSendMail]) {
		
		self.isComposingMail = YES;

		MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
		self.mailComposerVC = mc;
		
		mc.mailComposeDelegate = self;
		[mc setSubject:subject];
		[mc setToRecipients:[NSArray arrayWithObject:recipient]];
		[mc setMessageBody:body isHTML:NO];
				
		[self.currentCommander presentModalViewController:mc animated:YES];
		
		[mc release];

	}
	else {   // Mail functions are unavailable
		NSMutableString *message = [NSMutableString stringWithFormat:@"mailto:%@", recipient];
		if (!IsEmpty(subject))
			[message appendFormat:@"&subject=%@", subject];
		
		if (!IsEmpty(body))
			[message appendFormat:@"&body=%@", body];
		
		NSURL *mailto = [NSURL URLWithString:[message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		
		if ( ![self isNetworkAvailableForURL:mailto] ) {
			[SLFAlertView showWithTitle:NSLocalizedStringFromTable(@"Cannot Open Mail Composer", @"AppAlerts", @"Error on email attempt")
								message:NSLocalizedStringFromTable(@"There was an error while attempting to open an email composer.  Please check your network settings and try again", @"AppAlerts", @"Error on email attempt")
							buttonTitle:NSLocalizedStringFromTable(@"Cancel", @"StandardUI", @"Button cancelling some activity")];
            return;
		}			
        [[UIApplication sharedApplication] openURL:mailto];
	}
}

#pragma mark -
#pragma mark Mail Composer Delegate

- (void)mailComposeController:(MFMailComposeViewController*)mailController 
		  didFinishWithResult:(MFMailComposeResult)result 
						error:(NSError*)error {
	
	if (result == MFMailComposeResultFailed) {
		
		[SLFAlertView showWithTitle:NSLocalizedStringFromTable(@"Failure, Message Not Sent", @"AppAlerts", @"Error on email attempt.")
							message:NSLocalizedStringFromTable(@"An error prevented successful transmission of your message. Check your email and network settings or try emailing manually.", @"AppAlerts", @"Error on email attempt")
						buttonTitle:NSLocalizedStringFromTable(@"Cancel", @"StandardUI", @"Button cancelling some activity")];
		
	}
	
	[self.currentCommander dismissModalViewControllerAnimated:YES];
	self.mailComposerVC = nil;
	self.currentCommander = nil;
	self.isComposingMail = NO;

}


@end
