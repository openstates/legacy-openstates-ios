    //
//  AnalyticsOptInAlertController.m
//  Created by Gregory Combs on 8/24/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "AnalyticsOptInAlertController.h"
#import "LocalyticsSession.h"
#import "UtilityMethods.h"

@implementation AnalyticsOptInAlertController
@synthesize currentAlert;

- (id)init {
	if ((self=[super init])) {
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
						  initWithTitle:NSLocalizedStringFromTable(@"Permission To Use Analytics", @"AppAlerts", @"Title for alert asking for permission.")
						  message:NSLocalizedStringFromTable(@"TexLege can unobtrusively submit anonymous usage data (like launch time and features used) to the developer.  This is solely intended to improve app development, and will NEVER be used for advertising or marketing.  It submits no geographic or identifying information. Please consider enabling this service.  You may change this later in the Settings app.", @"AppAlerts", @"")
						  delegate:self 
						  cancelButtonTitle:NSLocalizedStringFromTable(@"Deny", @"StandardUI", @"Button label for the user to deny an app action.")
						  otherButtonTitles:NSLocalizedStringFromTable(@"Permit",@"StandardUI", @"Button label for the user to permit an app action."),nil] 
						 autorelease];
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
