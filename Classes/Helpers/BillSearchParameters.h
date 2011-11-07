//
//  BillSearchParameters.h
//  Created by Greg Combs on 11/6/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <RestKit/RestKit.h>

@class SLFState;
@class SLFChamber;
@interface BillSearchParameters : NSObject

+ (BillSearchParameters *)billSearchParameters;

- (NSString *)pathForText:(NSString *)text state:(SLFState *)state session:(NSString *)session chamber:(NSString *)chamber;
- (NSString *)pathForText:(NSString *)text chamber:(NSString *)chamber;

- (NSString *)pathForSubject:(NSString *)subject state:(SLFState *)state session:(NSString *)session chamber:(NSString *)chamber;
- (NSString *)pathForSubject:(NSString *)subject chamber:(NSString *)chamber;

- (NSString *)pathForSponsor:(NSString *)sponsorID state:(SLFState *)state session:(NSString *)session;
- (NSString *)pathForSponsor:(NSString *)sponsorID;

@end
