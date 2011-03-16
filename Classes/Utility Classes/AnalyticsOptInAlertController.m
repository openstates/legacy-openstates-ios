    //
//  AnalyticsOptInAlertController.m
//  TexLege
//
//  Created by Gregory Combs on 8/24/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "AnalyticsOptInAlertController.h"
#import "LocalyticsSession.h"
#import "UtilityMethods.h"

@implementation AnalyticsOptInAlertController
@synthesize currentAlert;

- (id)init {
	if (self=[super init]) {
	}
	return self;
}

- (void)updateOptInFromSettings {
	if ([self shouldPresentAnalyticsOptInAlert])	// we don't have a valid setting yet, wait till they get asked first
		return;
	[[NSUserDefaults standardUserDefaults] synchronize];	
	NSNumber *optInUserSetting = [[NSUserDefaults standardUserDefaults] objectForKey:kAnalyticsSettingsSwitch];
	if (!optInUserSetting)	// we didn't find a switch setting in the bundle??? shouldn't happen...
		optInUserSetting = [NSNumber numberWithBool:YES];
	BOOL didOptIn = [optInUserSetting boolValue];
	[[LocalyticsSession sharedLocalyticsSession] setOptIn:didOptIn];	
}


- (BOOL) shouldPresentAnalyticsOptInAlert {
	[[NSUserDefaults standardUserDefaults] synchronize];	
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

	self.currentAlert = [[[UIAlertView alloc] 
						 initWithTitle:[UtilityMethods texLegeStringWithKeyPath:@"Analytics.OptInTitle"]
						 message:[UtilityMethods texLegeStringWithKeyPath:@"Analytics.OptInText"]
						 delegate:self cancelButtonTitle:@"Deny" otherButtonTitles:@"Permit", nil] autorelease];
	self.currentAlert.tag = 6134;
	[self.currentAlert show];
	
}

- (void)dealloc {
	self.currentAlert = nil;
    [super dealloc];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 6134) {
		self.currentAlert = nil;
		
		NSInteger didOptIn = buttonIndex;
		if (didOptIn != 1 && didOptIn != 0) {
			if (didOptIn > 1)
				didOptIn = 1;
			else if (didOptIn < -1)
				didOptIn = -1;
		}
		if (didOptIn == 0) {
			[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"OPTED_OUT_OF_LOCALYTICS"];
		}
		[[LocalyticsSession sharedLocalyticsSession] setOptIn:didOptIn];

		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAnalyticsAskedForOptInKey];
		[[NSUserDefaults standardUserDefaults] setBool:(didOptIn == 1) forKey:kAnalyticsSettingsSwitch];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}


@end
