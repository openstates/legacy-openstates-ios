//
//  SLFAnalytics.h
//  Created by Greg Combs on 12/4/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


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
