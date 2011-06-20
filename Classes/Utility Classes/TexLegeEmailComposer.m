//
//  TexLegeEmailComposer.m
//  TexLege
//
//  Created by Gregory Combs on 8/10/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TexLegeEmailComposer.h"
#import "TexLegeAppDelegate.h"
#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "LocalyticsSession.h"

@interface TexLegeEmailComposer (Private)
- (void)presentMailFailureAlertViewWithTitle:(NSString*)failTitle message:(NSString *)failMessage;
@end

@implementation TexLegeEmailComposer

SYNTHESIZE_SINGLETON_FOR_CLASS(TexLegeEmailComposer);
@synthesize mailComposerVC, isComposingMail, currentAlert, currentCommander;


- (id) init
{
    if ((self = [super init]))
    {
		self.isComposingMail = NO;
		self.mailComposerVC = nil;
		self.currentAlert = nil;
		self.currentCommander = nil;
    }
    return self;
}

- (void)dealloc {
	self.mailComposerVC = nil;
	self.currentAlert = nil;
	self.currentCommander = nil;
    [super dealloc];
}

- (void)presentMailComposerTo:(NSString*)recipient subject:(NSString*)subject body:(NSString*)body commander:(UIViewController *)commander{
	if (!commander)
		return;
	
	self.currentCommander = commander;
	
	if (!body)
		body = @"";
	
	if ([recipient hasSuffix:@"texlege.com"])
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"EMAILING_TEXLEGE_SUPPORT"];
	else
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"EMAILING_OFFICIALS"];


	
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
		self.mailComposerVC = mc;
		[mc release];
		self.mailComposerVC.mailComposeDelegate = self;
		[self.mailComposerVC setSubject:subject];
		[self.mailComposerVC setToRecipients:[NSArray arrayWithObject:recipient]];
		[self.mailComposerVC setMessageBody:body isHTML:NO];
		[[self.mailComposerVC navigationBar] setTintColor:[TexLegeTheme navbar]];
		self.isComposingMail = YES;
				
		[self.currentCommander presentModalViewController:self.mailComposerVC animated:YES];

	}
	else {   // Mail functions are unavailable
		NSMutableString *message = [NSMutableString stringWithFormat:@"mailto:%@", recipient];
		if (subject && [subject length])
			[message appendFormat:@"&subject=%@", subject];
		if (body && [body length])
			[message appendFormat:@"&body=%@", body];
		NSURL *mailto = [NSURL URLWithString:[message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		
		if (![UtilityMethods openURLWithTrepidation:mailto])
			[self presentMailFailureAlertViewWithTitle:NSLocalizedStringFromTable(@"Cannot Open Mail Composer", @"AppAlerts", @"Error on email attempt")
											   message:NSLocalizedStringFromTable(@"There was an error while attempting to open an email composer.  Please check your network settings and try again",
																				  @"AppAlerts", @"Error on email attempt")];
	}
}

#pragma mark -
#pragma mark Mail Composer Delegate

- (void)mailComposeController:(MFMailComposeViewController*)mailController didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	
	if (result == MFMailComposeResultFailed) {
		[self presentMailFailureAlertViewWithTitle:NSLocalizedStringFromTable(@"Failure, Message Not Sent", @"AppAlerts", @"Error on email attempt.")
										   message:NSLocalizedStringFromTable(@"An error prevented successful transmission of your message. Check your email and network settings or try emailing manually.", @"AppAlerts", @"Error on email attempt")];
	}
	
	self.isComposingMail = NO;
	[self.currentCommander dismissModalViewControllerAnimated:YES];
	self.mailComposerVC = nil;
	self.currentCommander = nil;
}

#pragma mark -
#pragma mark Alert View

- (void)presentMailFailureAlertViewWithTitle:(NSString*)failTitle message:(NSString *)failMessage {
	self.currentAlert = [[[UIAlertView alloc] 
						 initWithTitle:failTitle
						 message:failMessage 
						 delegate:self 
						  cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"StandardUI", @"Cancelling some activity") 
						  otherButtonTitles:nil] autorelease];
	[self.currentAlert show];
	
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if ([alertView isEqual:self.currentAlert]) {
		self.currentAlert = nil;		
	}
}


@end
