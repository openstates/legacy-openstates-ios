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

#define DEMOCRAT_STRING     NSLocalizedString(@"Democrat",@"")
#define REPUBLICAN_STRING   NSLocalizedString(@"Republican", @"")
#define INDEPENDENT_STRING   NSLocalizedString(@"Independent", @"")

@interface SLFParty()
- (id)initWithName:(NSString *)aName type:(SLFPartyType)aType;
- (NSString *)nameForType:(SLFPartyType)newType;
- (SLFPartyType)typeForName:(NSString *)newName;
@end

@implementation SLFParty
@synthesize name;
@synthesize type;

+ (SLFParty*)partyWithName:(NSString *)aName {
    return [[[SLFParty alloc] initWithName:aName type:-1] autorelease];
}

+ (SLFParty*)partyWithType:(SLFPartyType)aType {
    return [[[SLFParty alloc] initWithName:nil type:aType] autorelease];
}

- (id)initWithName:(NSString *)aName type:(SLFPartyType)aType {
    self = [super init];
    if (self) {
        if (IsEmpty(aName)) {
            self.type = aType;
            self.name = [self nameForType:aType];
        }
        else {
            if ([aName hasPrefix:DEMOCRAT_STRING]) // fixes "Democratic"
                aName = DEMOCRAT_STRING;
            self.name = aName;
            self.type = [self typeForName:aName];
        }
    }
    return self;
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

- (UIImage *)image {
    UIImage *icon = nil;
    switch (self.type) {
        case SLFPartyDemocrat:
            icon = [UIImage imageNamed:@"bluestar.png"];
            break;
        case SLFPartyRepublican:
            icon = [UIImage imageNamed:@"redstar.png"];
            break;
        default:
        case SLFPartyIndependent:
            icon = [UIImage imageNamed:@"silverstar.png"];
            break;
    }
    return icon;
}

- (NSNumber *)pinColorIndex {
    NSUInteger index;
    switch (self.type) {
        case SLFPartyDemocrat:
            index = SLFMapPinColorBlue;
            break;
        case SLFPartyRepublican:
            index = SLFMapPinColorRed;
            break;
        default:
        case SLFPartyIndependent:
            index = SLFMapPinColorGreen;
            break;
    }
    return [NSNumber numberWithInteger:index];
}

- (NSString *)nameForType:(SLFPartyType)newType {
    NSString *newName = nil;
    switch (newType) {
        case SLFPartyDemocrat:
            newName = DEMOCRAT_STRING;
            break;
        case SLFPartyRepublican:
            newName = REPUBLICAN_STRING;
            break;
        default:
        case SLFPartyIndependent:
            newName = INDEPENDENT_STRING;
            break;
    }
    return newName;
}

- (SLFPartyType)typeForName:(NSString *)newName {
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


- (void)dealloc {
    self.name = nil;
    [super dealloc];
}
@end
