//
//  SLFParty.m
//  Created by Greg Combs on 10/17/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


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
@synthesize abbreviation;
@synthesize initial;
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
    self.abbreviation = nil;
    self.initial = nil;
    self.name = nil;
    self.image = nil;
    self.color = nil;
    [super dealloc];
}

- (NSString *)plural {
    return [self.abbreviation stringByAppendingString:@"s"];
}

@end

#define DEMOCRAT_STRING     NSLocalizedString(@"Democrat",@"")
#define DEMOCRAT_INIT_STRING     NSLocalizedString(@"D",@"")
#define DEMOCRAT_ABREVIATION_STRING     NSLocalizedString(@"Dem",@"")
@implementation Democrat
+ (Democrat *)democrat {
    if (!cachedDemocrat) {
        cachedDemocrat = [[Democrat alloc] init];
        cachedDemocrat.type = SLFPartyDemocrat;
        cachedDemocrat.initial = DEMOCRAT_INIT_STRING;
        cachedDemocrat.abbreviation = DEMOCRAT_ABREVIATION_STRING;
        cachedDemocrat.name = DEMOCRAT_STRING;
        cachedDemocrat.color = [SLFAppearance partyBlue];
        cachedDemocrat.image = [UIImage imageNamed:@"bluestar"];
        cachedDemocrat.pinColorIndex = SLFMapPinColorBlue;
    }
    return cachedDemocrat;
}
@end

#define REPUBLICAN_STRING   NSLocalizedString(@"Republican", @"")
#define REPUBLICAN_INIT_STRING     NSLocalizedString(@"R",@"")
#define REPUBLICAN_ABREVIATION_STRING     NSLocalizedString(@"Rep",@"")
@implementation Republican
+ (Republican *)republican {
    if (!cachedRepublican) {
        cachedRepublican = [[Republican alloc] init];
        cachedRepublican.type = SLFPartyRepublican;
        cachedRepublican.name = REPUBLICAN_STRING;
        cachedRepublican.initial = REPUBLICAN_INIT_STRING;
        cachedRepublican.abbreviation = REPUBLICAN_ABREVIATION_STRING;
        cachedRepublican.color = [SLFAppearance partyRed];
        cachedRepublican.image = [UIImage imageNamed:@"redstar"];
        cachedRepublican.pinColorIndex = SLFMapPinColorRed;
    }
    return cachedRepublican;
}
@end

#define NEWPROGRESSIVE_STRING   NSLocalizedString(@"New Progressive Party", @"")
#define NEWPROGRESSIVE_INIT_STRING   NSLocalizedString(@"PNP", @"")
#define NEWPROGRESSIVE_ABREVIATION_STRING   NSLocalizedString(@"PNP", @"")
@implementation NewProgressiveParty
+ (NewProgressiveParty *)newprogressiveparty {
    if (!cachedNewProgressiveParty) {
        cachedNewProgressiveParty = [[NewProgressiveParty alloc] init];
        cachedNewProgressiveParty.type = SLFPartyNewProgressive;
        cachedNewProgressiveParty.name = NEWPROGRESSIVE_STRING;
        cachedNewProgressiveParty.initial = NEWPROGRESSIVE_INIT_STRING;
        cachedNewProgressiveParty.abbreviation = NEWPROGRESSIVE_ABREVIATION_STRING;
        cachedNewProgressiveParty.color = [SLFAppearance partyBlue];
        cachedNewProgressiveParty.image = [UIImage imageNamed:@"bluestar"];
        cachedNewProgressiveParty.pinColorIndex = SLFMapPinColorBlue;
    }
    return cachedNewProgressiveParty;
}
@end

#define POPULARDEMOCRATIC_STRING   NSLocalizedString(@"Popular Democratic Party", @"")
#define POPULARDEMOCRATIC_INIT_STRING   NSLocalizedString(@"PPD", @"")
#define POPULARDEMOCRATIC_ABREVIATION_STRING   NSLocalizedString(@"PPD", @"")
@implementation PopularDemocraticParty
+ (PopularDemocraticParty *)populardemocraticparty {
    if (!cachedPopularDemocraticParty) {
        cachedPopularDemocraticParty = [[PopularDemocraticParty alloc] init];
        cachedPopularDemocraticParty.type = SLFPartyPopularDemocratic;
        cachedPopularDemocraticParty.name = POPULARDEMOCRATIC_STRING;
        cachedPopularDemocraticParty.initial = POPULARDEMOCRATIC_INIT_STRING;
        cachedPopularDemocraticParty.abbreviation = POPULARDEMOCRATIC_ABREVIATION_STRING;
        cachedPopularDemocraticParty.color = [SLFAppearance partyRed];
        cachedPopularDemocraticParty.image = [UIImage imageNamed:@"redstar"];
        cachedPopularDemocraticParty.pinColorIndex = SLFMapPinColorRed;
    }
    return cachedPopularDemocraticParty;
}
@end

#define INDEPENDENT_STRING   NSLocalizedString(@"Independent", @"")
#define INDEPENDENT_INIT_STRING   NSLocalizedString(@"Ind", @"")
#define INDEPENDENT_ABREVIATION_STRING   NSLocalizedString(@"I", @"")
@implementation Independent
+ (Independent *)independent {
    if (!cachedIndependent) {
        cachedIndependent = [[Independent alloc] init];
        cachedIndependent.type = SLFPartyIndependent;
        cachedIndependent.name = INDEPENDENT_STRING;
        cachedIndependent.initial = INDEPENDENT_INIT_STRING;
        cachedIndependent.abbreviation = INDEPENDENT_ABREVIATION_STRING;
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
        cachedUnknown.initial = UNKNOWN_STRING;
        cachedUnknown.abbreviation = UNKNOWN_STRING;
        cachedUnknown.name = UNKNOWN_STRING;
        cachedUnknown.color = [SLFAppearance partyWhite];
        cachedUnknown.image = [UIImage imageNamed:@"silverstar"];
        cachedUnknown.pinColorIndex = SLFMapPinColorGreen;
    }
    return cachedUnknown;
}

- (NSString *)plural {
    return UNKNOWN_STRING;
}
@end


SLFPartyType partyTypeForName(NSString *newName) {
    if (!IsEmpty(newName)) {
        NSString *loweredName = [newName lowercaseString];
        if ([@"democrat" isEqualToString:loweredName])
            return SLFPartyDemocrat;
        else if ([@"republican" isEqualToString:loweredName])
            return SLFPartyRepublican;
        else if ([@"independent" isEqualToString:loweredName])
            return SLFPartyIndependent;
        else if ([@"partido nuevo progresista" isEqualToString:loweredName])
            return SLFPartyNewProgressive;
        else if ([@"partido popular democrático" isEqualToString:loweredName])
            return SLFPartyPopularDemocratic;
    }
    return SLFPartyUnknown;
}

NSString* partyNameForType(SLFPartyType aType) {
    return [[SLFParty partyWithType:aType] name];
}


