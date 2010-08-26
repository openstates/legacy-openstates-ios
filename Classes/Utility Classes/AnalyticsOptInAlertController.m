    //
//  AnalyticsOptInAlertController.m
//  TexLege
//
//  Created by Gregory Combs on 8/24/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "AnalyticsOptInAlertController.h"
#import "LocalyticsSession.h"

@implementation AnalyticsOptInAlertController
@synthesize optInText, currentAlert;

- (id)init {
	if (self=[super init]) {
		
		NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"TexLegeStrings" ofType:@"plist"];
		NSDictionary *textDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
		self.optInText = [textDict objectForKey:@"AnalyticsOptInText"];
		
	}
	return self;
}

- (void)updateOptInFromSettings {
	if ([self shouldPresentAnalyticsOptInAlert])	// we don't have a valid setting yet, wait till they get asked first
		return;
	
	NSNumber *optInUserSetting = [[NSUserDefaults standardUserDefaults] objectForKey:kAnalyticsSettingsSwitch];
	if (!optInUserSetting)	// we didn't find a switch setting in the bundle??? shouldn't happen...
		optInUserSetting = [NSNumber numberWithBool:YES];
	BOOL didOptIn = [optInUserSetting boolValue];
	[[LocalyticsSession sharedLocalyticsSession] setOptIn:didOptIn];	
}


- (BOOL) shouldPresentAnalyticsOptInAlert {
	BOOL hasAsked = [[NSUserDefaults standardUserDefaults] boolForKey:kAnalyticsAskedForOptInKey];
	if (!hasAsked)
		return YES;
	return NO;
}

- (BOOL) presentAnalyticsOptInAlertIfNecessary {
	if ([self shouldPresentAnalyticsOptInAlert]) {
		[self presentAnalyticsOptInAlert];
		return YES;
	}
	return NO;
}

- (void)presentAnalyticsOptInAlert {

	self.currentAlert = [[UIAlertView alloc] 
						 initWithTitle:@"Permission To Use Analytics"
						 message:self.optInText
						 delegate:self cancelButtonTitle:@"Deny" otherButtonTitles:@"Permit", nil];
	[self.currentAlert show];
	
}

- (void)dealloc {
	self.currentAlert = nil;
	self.optInText = nil;
    [super dealloc];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if ([alertView isEqual:self.currentAlert]) {
		self.currentAlert = nil;
		self.optInText = nil;
		
		NSInteger didOptIn = buttonIndex;
		if (didOptIn != 1 && didOptIn != 0) {
			debug_NSLog(@"Received an unknown button selection for analytics opt-in alert: %d", buttonIndex);
			if (didOptIn > 1)
				didOptIn = 1;
			else if (didOptIn < -1)
				didOptIn = -1;
			
		}
		
		[[LocalyticsSession sharedLocalyticsSession] setOptIn:didOptIn];

		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAnalyticsAskedForOptInKey];
		[[NSUserDefaults standardUserDefaults] setBool:(didOptIn == 1) forKey:kAnalyticsSettingsSwitch];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}


@end
