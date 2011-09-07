//
//  SLFChamber.m
//  Created by Gregory Combs on 9/3/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <Foundation/Foundation.h>

@class SLFState;
@interface SLFChamber : NSObject
@property (nonatomic,retain) SLFState *state;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSNumber *term;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,readonly) NSString *shortName;
@property (nonatomic,copy) NSString *stateID;
@property (nonatomic,copy) NSArray *knownTypes;

+ (SLFChamber *)chamberWithType:(NSString *)aType forState:(SLFState *)aState;
- (NSString *)boundaryCodeForDistrictName:(NSString *)districtName;
@end


enum kChamberTypeIndex {
    CHAMBER_ALL = 0,      // all
    CHAMBER_LOWER,                  // lower
    CHAMBER_UPPER,                 // upper
	CHAMBER_JOINT,                  // joint
	CHAMBER_EXEC               // executive
};
