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
#import "SLFAlertView.h"

@interface AnalyticsOptInAlertController ()

- (void)doOptIn:(BOOL)didOptIn;

@end

@implementation AnalyticsOptInAlertController

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

- (void)doOptIn:(BOOL)didOptIn {
	
	if (NO == didOptIn)
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"OPTED_OUT_OF_LOCALYTICS"];
	
	[[LocalyticsSession sharedLocalyticsSession] setOptIn:didOptIn];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setBool:YES forKey:kAnalyticsAskedForOptInKey];
	[defaults setBool:didOptIn forKey:kAnalyticsSettingsSwitch];
	[defaults synchronize];
}


- (BOOL) shouldPresentAnalyticsOptInAlert {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults synchronize];	
	BOOL hasAsked = [defaults boolForKey:kAnalyticsAskedForOptInKey];
	
	return (hasAsked == NO);
}

- (BOOL) presentAnalyticsOptInAlertIfNecessary {
	
	if ([self shouldPresentAnalyticsOptInAlert]) {

		[SLFAlertView showWithTitle:NSLocalizedStringFromTable(@"Permission To Use Analytics", @"AppAlerts", @"Title for alert asking for permission.") 
							message:NSLocalizedStringFromTable(@"This app can unobtrusively submit anonymous usage data (like launch time and features used) to the developer.  This is solely intended to improve app development, and will NEVER be used for advertising or marketing.  It submits no geographic or identifying information. Please consider enabling this service.  You may change this later in the Settings app.", @"AppAlerts", @"") 
						cancelTitle:NSLocalizedStringFromTable(@"Deny", @"StandardUI", @"Button label for the user to deny an app action.") 
						cancelBlock:^(void) {
							[self doOptIn:NO];
						}
						 otherTitle:NSLocalizedStringFromTable(@"Permit",@"StandardUI", @"Button label for the user to permit an app action.")
						 otherBlock:^(void) {
							 [self doOptIn:YES];
						 }];
		
		
		return YES;
	}
	return NO;
}

- (void)dealloc {
    [super dealloc];
}

@end
