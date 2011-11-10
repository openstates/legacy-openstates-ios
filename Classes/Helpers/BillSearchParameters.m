//
//  BillSearchParameters.m
//  Created by Greg Combs on 11/6/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "BillSearchParameters.h"
#import "SLFDataModels.h"
#import <RestKit/Network/NSObject+URLEncoding.h>

NSString* validOrEmptyParameter(NSString *parameter);
NSString* validSessionParameter(NSString *session);

@interface BillSearchParameters()
@end

@implementation BillSearchParameters

+ (BillSearchParameters *)billSearchParameters {
    return [[[BillSearchParameters alloc] init] autorelease];
}

- (NSString *)pathForBill:(NSString *)billID state:(SLFState *)state session:(NSString *)session {
	NSParameterAssert((state != NULL) && (billID != NULL) && (session != NULL));
	NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
										state.stateID, @"state",
										session, @"session",
										SUNLIGHT_APIKEY, @"apikey", 
                                        billID, @"bill", nil];
    return RKMakePathWithObject(@"/bills/:state/:session/:bill?:apikey", queryParams);
}

- (NSString *)pathForBill:(SLFBill *)bill {
	NSParameterAssert((bill != NULL) && (bill.state != NULL) && (bill.billID != NULL) && (bill.session != NULL));
    return [RKMakePathWithObject(@"/bills/:stateID/:session/:billID?apikey=", bill) stringByAppendingString:SUNLIGHT_APIKEY];
}

- (NSString *)pathForText:(NSString *)text state:(SLFState *)state session:(NSString *)session chamber:(NSString *)chamber {
	NSParameterAssert((state != NULL));
    text = [validOrEmptyParameter(text) uppercaseString];
	NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										validSessionParameter(session), @"search_window",
										state.stateID, @"state",
										SUNLIGHT_APIKEY, @"apikey", 
                                        text, @"q", nil];
	if (chamber && ![chamber isEqualToString:@"all"])
		[queryParams setObject:chamber forKey:@"chamber"];
    return RKPathAppendQueryParams(@"/bills", queryParams);
}

- (NSString *)pathForText:(NSString *)text chamber:(NSString *)chamber {
    SLFState *state = SLFSelectedState();
	if (!state)
		return nil;
    NSString *session = SLFSelectedSessionForState(state);
	return [self pathForText:text state:state session:session chamber:chamber];
}

- (NSString *)pathForSubject:(NSString *)subject state:(SLFState *)state session:(NSString *)session chamber:(NSString *)chamber {
	NSCParameterAssert((state != NULL));
    subject = validOrEmptyParameter(subject);
	NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										validSessionParameter(session), @"search_window",
										state.stateID, @"state",
										SUNLIGHT_APIKEY, @"apikey",
                                        subject, @"subject", nil];
	if (chamber && ![chamber isEqualToString:@"all"])
		[queryParams setObject:chamber forKey:@"chamber"];
    return RKPathAppendQueryParams(@"/bills", queryParams);
}

- (NSString *)pathForSubject:(NSString *)subject chamber:(NSString *)chamber {
    SLFState *state = SLFSelectedState();
	if (!state)
		return nil;
	NSString *session = SLFSelectedSessionForState(state);
	return [self pathForSubject:subject state:state session:session chamber:chamber];
}

- (NSString *)pathForSponsor:(NSString *)sponsorID state:(SLFState *)state session:(NSString *)session {
	NSCParameterAssert( (sponsorID != NULL) && (state != NULL) );
	NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
								 state.stateID, @"state",
								 validSessionParameter(session), @"search_window",
								 SUNLIGHT_APIKEY, @"apikey",
								 sponsorID, @"sponsor_id",
								 @"sponsors,bill_id,title,session,state,type,update_at,subjects", @"fields", nil];
	return RKPathAppendQueryParams(@"/bills", queryParams);
}

- (NSString *)pathForSponsor:(NSString *)sponsorID {
    SLFState *state = SLFSelectedState();
	if (!state || IsEmpty(sponsorID))
		return nil;
	NSString *session = SLFSelectedSessionForState(state);
    return [self pathForSponsor:sponsorID state:state session:session];
}

@end

NSString* validOrEmptyParameter(NSString *parameter) {
    if (IsEmpty(parameter))
		parameter = @"";
    return parameter;
}

NSString* validSessionParameter(NSString *session) {
    if (IsEmpty(session))
        return @"session";
    return [NSString stringWithFormat:@"session:%@", [session URLEncodedString]];
}


