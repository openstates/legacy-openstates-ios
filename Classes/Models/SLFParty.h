//
//  SLFParty.h
//  Created by Greg Combs on 10/17/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

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
@property (nonatomic,retain) UIImage *image;
@property (nonatomic,assign) NSUInteger pinColorIndex;
@property (nonatomic,retain) UIColor *color;
@property (nonatomic,readonly) NSString *plural;
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

