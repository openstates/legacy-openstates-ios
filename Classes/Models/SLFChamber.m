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

#import "SLFChamber.h"
#import "SLFState.h"

@implementation SLFChamber
@synthesize stateID;
@synthesize state;
@synthesize type;
@synthesize term;
@synthesize title;
@synthesize name;
@synthesize shortName;
@synthesize knownTypes;

- (id)init {
    self = [super init];
    if (self) {
        self.knownTypes = [NSArray arrayWithObjects:
                           @"all",
                           @"lower",
                           @"upper",
                           @"joint",
                           @"executive", nil];
    }
    return self;
}

- (void)dealloc {
    self.knownTypes = nil;
    self.stateID = nil;
    self.state = nil;
    self.type = nil;
    self.term = nil;
    self.title = nil;
    self.name = nil;
    [super dealloc];
}

+ (SLFChamber *)chamberWithType:(NSString *)aType forState:(SLFState *)aState {
    SLFChamber *chamber = [[SLFChamber alloc] init];
    chamber.state = aState;  
    chamber.type = aType;
    
        /////////////////////////////////////////////
    return chamber;
}

- (NSInteger)typeValueForKnownType:(NSString *)newType {
    return [self.knownTypes indexOfObject:newType];
}

- (NSString *)knownTypeForTypeValue:(NSInteger)newVal {
    return [self.knownTypes objectAtIndex:newVal];
}

- (void)configureChamberInfoForTypeValue:(NSInteger)typeValue {
        //NSInteger typeValue = [self typeValueForKnownType:self.type];
    switch (typeValue) {
        case CHAMBER_LOWER:
            self.term = self.state.lowerChamberTerm;
            self.title = self.state.lowerChamberTitle;
            self.name = self.state.lowerChamberName;
            break;
        case CHAMBER_UPPER:
            self.term = self.state.upperChamberTerm;
            self.title = self.state.upperChamberTitle;
            self.name = self.state.upperChamberName;
            break;
        case CHAMBER_JOINT:
            self.term = self.nil;
            self.title = self.nil;
            self.name = @"Joint";
            break;
        case CHAMBER_EXEC:
            self.term = self.nil;
            self.title = @"Governor";
            self.name = @"Executive";
            break;
        default:
        case CHAMBER_ALL:
            self.term = nil;
            self.title = nil;
            self.name = @"All";
            break;
    }
}

- (NSString *)shortName {
    NSArray *words = [self.name componentsSeparatedByString:@" "];
    if ([words count] > 1 && [[words objectAtIndex:0] length] > 4) { // just to make sure we have a decent, single name
        return [words objectAtIndex:0];
    }
    return self.name;
}

- (NSString *)boundaryPrefix {
    return [NSString stringWithFormat:@"sld%@", [self.type substringToIndex:1]];    // sldl (lower) or sldu (upper)
}

- (NSString *)boundaryIDForDistrictName:(NSString *)districtName {
    NSAssert(districtName != NULL, @"District name cannot be empty.");
    NSString *miniName = [self.shortName lowercaseString];
    if ([miniName isEqualToString:@"senate"] || [miniName isEqualToString:@"house"])  // i.e. NOT "assembly"!
        miniName = [NSString stringWithFormat:@"state-%@", miniName];

    NSDictionary *boundaryIDComponents = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [self boundaryPrefix], @"boundaryPrefix",
                                          self.stateID, @"stateID",
                                          miniName, @"chamberName",
                                          districtName, @"districtID", nil];
    return RKMakePathWithObject(@":boundaryPrefix-:stateID-:chamberName-district-:districtID", boundaryIDComponents);    
}
@end
