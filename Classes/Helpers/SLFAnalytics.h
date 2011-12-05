//
//  SLFAnalytics.h
//  Created by Greg Combs on 12/4/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <Foundation/Foundation.h>

@protocol SLFAnalyticsAdapter <NSObject>
@required
- (void)beginTracking;
- (void)endTracking;
- (void)pauseTracking;
- (void)resumeTracking;
- (void)tagEvent:(NSString *)event attributes:(NSDictionary *)attributes;
- (void)tagEnvironmentVariables:(NSDictionary *)variables;
- (void)setOptIn:(BOOL)optedIn;
- (BOOL)isOptedIn;
@end

@interface SLFAnalytics : NSObject
+ (id)sharedAnalytics;
- (void)beginTracking;
- (void)endTracking;
- (void)pauseTracking;
- (void)resumeTracking;
- (void)tagEvent:(NSString *)event;
- (void)tagEvent:(NSString *)event attributes:(NSDictionary *)attributes;
- (void)tagEnvironmentVariables:(NSDictionary *)variables;
- (void)setOptIn:(BOOL)optedIn;
- (BOOL)isOptedIn;
@end
