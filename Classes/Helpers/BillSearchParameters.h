//
//  BillSearchParameters.h
//  Created by Greg Combs on 11/6/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

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
