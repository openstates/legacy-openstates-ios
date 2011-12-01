//
//  SLFParty.h
//  Created by Greg Combs on 10/17/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    SLFPartyIndependent = 0,
    SLFPartyDemocrat,
    SLFPartyRepublican
} SLFPartyType;

@interface SLFParty : NSObject
+ (SLFParty *)partyWithName:(NSString *)aName;
+ (SLFParty *)partyWithType:(SLFPartyType)aType;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,assign) SLFPartyType type;
@property (nonatomic,retain) UIImage *image;
@property (nonatomic,assign) NSUInteger pinColorIndex;
@property (nonatomic,retain) UIColor *color;
@property (nonatomic,readonly) NSString *initial;
@property (nonatomic,readonly) NSString *abbreviation;
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

