//
//  SLFParty.m
//  Created by Greg Combs on 10/17/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFParty.h"
#import "SLFMapPin.h"
#import "SLFAppearance.h"

SLFPartyType partyTypeForName(NSString *newName);
NSString * partyNameForType(SLFPartyType newType);

static Democrat * cachedDemocrat;
static Republican * cachedRepublican;
static NewProgressiveParty * cachedNewProgressiveParty;
static PopularDemocraticParty * cachedPopularDemocraticParty;
static Independent * cachedIndependent;
static UnknownParty * cachedUnknown;

@interface SLFParty()
@end

@implementation SLFParty
@synthesize name;
@synthesize type;
@synthesize color;
@synthesize image;
@synthesize pinColorIndex;

+ (SLFParty *)partyWithName:(NSString *)aName {
    return [SLFParty partyWithType:partyTypeForName(aName)];
}

+ (SLFParty *)partyWithType:(SLFPartyType)aType {
    if (aType == SLFPartyDemocrat)
        return [Democrat democrat];
    else if (aType == SLFPartyRepublican)
        return [Republican republican];
    else if (aType == SLFPartyNewProgressive)
        return [NewProgressiveParty newprogressiveparty];
    else if (aType == SLFPartyPopularDemocratic)
        return [PopularDemocraticParty populardemocraticparty];
    else if (aType == SLFPartyIndependent)
        return [Independent independent];
    return [UnknownParty unknownParty];
}

- (void)dealloc {
    self.name = nil;
    self.image = nil;
    self.color = nil;
    [super dealloc];
}

- (NSString *)initial {
    return [self.name substringToIndex:1];
}

- (NSString *)abbreviation {
    return [self.name substringToIndex:3];
}

- (NSString *)plural {
    return [self.abbreviation stringByAppendingString:@"s"];
}

@end

#define DEMOCRAT_STRING     NSLocalizedString(@"Democrat",@"")

@implementation Democrat
+ (Democrat *)democrat {
    if (!cachedDemocrat) {
        cachedDemocrat = [[Democrat alloc] init];
        cachedDemocrat.type = SLFPartyDemocrat;
        cachedDemocrat.name = DEMOCRAT_STRING;
        cachedDemocrat.color = [SLFAppearance partyBlue];
        cachedDemocrat.image = [UIImage imageNamed:@"bluestar"];
        cachedDemocrat.pinColorIndex = SLFMapPinColorBlue;
    }
    return cachedDemocrat;
}
@end

#define REPUBLICAN_STRING   NSLocalizedString(@"Republican", @"")

@implementation Republican
+ (Republican *)republican {
    if (!cachedRepublican) {
        cachedRepublican = [[Republican alloc] init];
        cachedRepublican.type = SLFPartyRepublican;
        cachedRepublican.name = REPUBLICAN_STRING;
        cachedRepublican.color = [SLFAppearance partyRed];
        cachedRepublican.image = [UIImage imageNamed:@"redstar"];
        cachedRepublican.pinColorIndex = SLFMapPinColorRed;
    }
    return cachedRepublican;
}
@end
#define NEWPROGRESSIVE_STRING   NSLocalizedString(@"New Progressive Party", @"")

@implementation NewProgressiveParty
+ (NewProgressiveParty *)newprogressiveparty {
    if (!cachedNewProgressiveParty) {
        cachedNewProgressiveParty = [[NewProgressiveParty alloc] init];
        cachedNewProgressiveParty.type = SLFPartyNewProgressive;
        cachedNewProgressiveParty.name = NEWPROGRESSIVE_STRING;
        cachedNewProgressiveParty.color = [SLFAppearance partyBlue];
        cachedNewProgressiveParty.image = [UIImage imageNamed:@"bluestar"];
        cachedNewProgressiveParty.pinColorIndex = SLFMapPinColorBlue;
    }
    return cachedNewProgressiveParty;
}
@end
#define POPULARDEMOCRATIC_STRING   NSLocalizedString(@"Popular Democratic Party", @"")

@implementation PopularDemocraticParty
+ (PopularDemocraticParty *)populardemocraticparty {
    if (!cachedPopularDemocraticParty) {
        cachedPopularDemocraticParty = [[PopularDemocraticParty alloc] init];
        cachedPopularDemocraticParty.type = SLFPartyPopularDemocratic;
        cachedPopularDemocraticParty.name = POPULARDEMOCRATIC_STRING;
        cachedPopularDemocraticParty.color = [SLFAppearance partyRed];
        cachedPopularDemocraticParty.image = [UIImage imageNamed:@"redstar"];
        cachedPopularDemocraticParty.pinColorIndex = SLFMapPinColorRed;
    }
    return cachedPopularDemocraticParty;
}
@end

#define INDEPENDENT_STRING   NSLocalizedString(@"Independent", @"")

@implementation Independent
+ (Independent *)independent {
    if (!cachedIndependent) {
        cachedIndependent = [[Independent alloc] init];
        cachedIndependent.type = SLFPartyIndependent;
        cachedIndependent.name = INDEPENDENT_STRING;
        cachedIndependent.color = [SLFAppearance partyGreen];
        cachedIndependent.image = [UIImage imageNamed:@"silverstar"];
        cachedIndependent.pinColorIndex = SLFMapPinColorGreen;
    }
    return cachedIndependent;
}
@end

#define UNKNOWN_STRING   @""

@implementation UnknownParty
+ (UnknownParty *)unknownParty {
    if (!cachedUnknown) {
        cachedUnknown = [[UnknownParty alloc] init];
        cachedUnknown.type = SLFPartyUnknown;
        cachedUnknown.name = UNKNOWN_STRING;
        cachedUnknown.color = [SLFAppearance partyWhite];
        cachedUnknown.image = [UIImage imageNamed:@"silverstar"];
        cachedUnknown.pinColorIndex = SLFMapPinColorGreen;
    }
    return cachedUnknown;
}

- (NSString *)initial {
    return UNKNOWN_STRING;
}

- (NSString *)abbreviation {
    return UNKNOWN_STRING;
}

- (NSString *)plural {
    return UNKNOWN_STRING;
}
@end


SLFPartyType partyTypeForName(NSString *newName) {
    SLFPartyType newType = SLFPartyUnknown;
    if (!IsEmpty(newName)) {
        NSString *loweredName = [newName lowercaseString];
        if ([@"democrat" isEqualToString:loweredName])
            newType = SLFPartyDemocrat;
        else if ([@"republican" isEqualToString:loweredName])
            newType = SLFPartyRepublican;
        else if ([@"independent" isEqualToString:loweredName])
            newType = SLFPartyIndependent;
        else if ([@"partido nuevo progresista" isEqualToString:loweredName])
            newType = SLFPartyNewProgressive;
        else if ([@"partido popular democrático" isEqualToString:loweredName])
            newType = SLFPartyPopularDemocratic;
    }
    return newType;
}

NSString* partyNameForType(SLFPartyType aType) {
    return [[SLFParty partyWithType:aType] name];
}


