//
//  BillSearchParameters.h
//  Created by Greg Combs on 11/6/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


@class SLFState;
@class SLFChamber;
@class SLFBill;
@interface BillSearchParameters : NSObject

+ (NSString *)pathForBill:(SLFBill *)bill;
+ (NSString *)pathForBill:(NSString *)billID state:(NSString *)stateID session:(NSString *)session;

+ (NSString *)pathForText:(NSString *)text state:(NSString *)stateID session:(NSString *)session chamber:(NSString *)chamber;
+ (NSString *)pathForText:(NSString *)text chamber:(NSString *)chamber;

+ (NSString *)pathForSubject:(NSString *)subject state:(NSString *)stateID session:(NSString *)session chamber:(NSString *)chamber;
+ (NSString *)pathForSubject:(NSString *)subject chamber:(NSString *)chamber;
+ (NSString *)pathForSubjectsWithState:(SLFState *)state chamber:(NSString *)chamber;

+ (NSString *)pathForSponsor:(NSString *)sponsorID state:(NSString *)stateID session:(NSString *)session;
+ (NSString *)pathForSponsor:(NSString *)sponsorID;

+ (NSString *)pathForUpdatedSinceDaysAgo:(NSInteger)daysAgo state:(NSString *)stateID;
@end
