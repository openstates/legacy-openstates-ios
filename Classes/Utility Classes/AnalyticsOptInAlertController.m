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

- (BOOL) shouldPresentAnalyticsOptInAlert {
	NSNumber *optInResponse = [[NSUserDefaults standardUserDefaults] objectForKey:kAnalyticsOptInKey];
	if (!optInResponse || [optInResponse integerValue] == -1)
		return YES;
	NSInteger optIn = [optInResponse integerValue];
	[[LocalyticsSession sharedLocalyticsSession] setOptIn:(optIn == 1)];
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
		
		NSInteger optIn = buttonIndex;
		if (optIn != 1 && optIn != 0) {
			debug_NSLog(@"Received an unknown button selection for analytics opt-in alert: %d", buttonIndex);
			if (optIn > 1)
				optIn = 1;
			else if (optIn < -1)
				optIn = -1;
			
		}
		
		[[LocalyticsSession sharedLocalyticsSession] setOptIn:optIn];

		NSNumber *optInNum = [NSNumber numberWithInteger:optIn];
		[[NSUserDefaults standardUserDefaults] setObject:optInNum forKey:kAnalyticsOptInKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}


@end
