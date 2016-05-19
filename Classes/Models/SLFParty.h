//
//  SLFParty.h
//  Created by Greg Combs on 10/17/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <Foundation/Foundation.h>

typedef enum {
    SLFPartyUnknown = -1,
    SLFPartyIndependent = 0,
    SLFPartyDemocrat = 1,
    SLFPartyRepublican = 2,
    SLFPartyNewProgressive = 3,
    SLFPartyPopularDemocratic = 4
} SLFPartyType;

@interface SLFParty : NSObject
+ (SLFParty *)partyWithName:(NSString *)aName;
+ (SLFParty *)partyWithType:(SLFPartyType)aType;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *initial;
@property (nonatomic,copy) NSString *abbreviation;
@property (nonatomic,assign) SLFPartyType type;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,assign) NSUInteger pinColorIndex;
@property (nonatomic,strong) UIColor *color;
@property (weak, nonatomic,readonly) NSString *plural;
@end

@interface Democrat : SLFParty
+ (Democrat*)democrat;
@end

@interface Republican : SLFParty
+ (Republican*)republican;
@end

@interface Independent : SLFParty
+ (Independent*)independent;
@end

@interface UnknownParty : SLFParty
+ (UnknownParty*)unknownParty;
@end

@interface NewProgressiveParty : SLFParty
+ (UnknownParty*)newprogressiveparty;
@end

@interface PopularDemocraticParty : SLFParty
+ (UnknownParty*)populardemocraticparty;
@end

