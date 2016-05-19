//
//  SLFChamber.m
//  Created by Gregory Combs on 9/3/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <Foundation/Foundation.h>

extern NSString * const SLFChamberUpperType;
extern NSString * const SLFChamberLowerType;

@class SLFState;
@interface SLFChamber : NSObject
@property (nonatomic,strong) SLFState *state;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSNumber *term;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *name;
@property (weak, nonatomic,readonly) NSString *formalName;
@property (weak, nonatomic,readonly) NSString *shortName;
@property (nonatomic,copy) NSString *stateID;
@property (nonatomic,copy) NSString *titleAbbreviation;
@property (nonatomic,copy) NSString *initial;
@property (weak, nonatomic,readonly) SLFChamber *opposingChamber;
@property (nonatomic,readonly) BOOL isUpperChamber;

+ (SLFChamber *)chamberWithType:(NSString *)aType forState:(SLFState *)aState;
+ (NSString *)chamberTypeForSearchScopeIndex:(NSInteger)scopeIndex;
+ (NSArray *)chamberSearchScopeTitlesWithState:(SLFState *)state;
@end

@interface UpperChamber : SLFChamber
+ (UpperChamber*)upperForState:(SLFState *)aState;
@end

@interface LowerChamber : SLFChamber
+ (LowerChamber*)lowerForState:(SLFState *)aState;
@end
