//
//  SLFParty.m
//  Created by Greg Combs on 10/17/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
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
static Independent * cachedIndependent;

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
    return [Independent independent];
}

- (void)dealloc {
    self.name = nil;
    self.image = nil;
    self.pinColorIndex = nil;
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
        cachedDemocrat.pinColorIndex = [NSNumber numberWithInteger:SLFMapPinColorBlue];
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
        cachedDemocrat.name = REPUBLICAN_STRING;
        cachedRepublican.color = [SLFAppearance partyRed];
        cachedRepublican.image = [UIImage imageNamed:@"redstar"];
        cachedRepublican.pinColorIndex = [NSNumber numberWithInteger:SLFMapPinColorRed];
    }
    return cachedRepublican;
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
        cachedIndependent.pinColorIndex = [NSNumber numberWithInteger:SLFMapPinColorGreen];
    }
    return cachedIndependent;
}
@end

SLFPartyType partyTypeForName(NSString *newName) {
    SLFPartyType newType = SLFPartyIndependent;
    if (!IsEmpty(newName)) {
        NSString *loweredName = [newName lowercaseString];
        if ([[DEMOCRAT_STRING lowercaseString] isEqualToString:loweredName])
            newType = SLFPartyDemocrat;
        else if ([[REPUBLICAN_STRING lowercaseString] isEqualToString:loweredName])
            newType = SLFPartyRepublican;
    }
    return newType;
}

NSString* partyNameForType(SLFPartyType aType) {
    return [[SLFParty partyWithType:aType] name];
}


