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

+ (SLFChamber *)chamberWithType:(NSString *)aType forState:(SLFState *)aState {
    SLFChamber *chamber = [[SLFChamber alloc] init];
    chamber.state = aState;  
    chamber.type = aType;
    if ([aType isEqualToString:@"lower"]) {
        chamber.term = aState.lowerChamberTerm;
        chamber.title = aState.lowerChamberTitle;
        chamber.name = aState.lowerChamberName;
    }
    else {
        chamber.term = aState.upperChamberTerm;
        chamber.title = aState.upperChamberTitle;
        chamber.name = aState.upperChamberName;
    }
    return chamber;
}

- (void)dealloc {
    self.stateID = nil;
    self.state = nil;
    self.type = nil;
    self.term = nil;
    self.title = nil;
    self.name = nil;
    [super dealloc];
}

- (NSString *)shortName {
    NSArray *words = [self.name componentsSeparatedByString:@" "];
    if ([words count] > 1 && [[words objectAtIndex:0] length] > 4) { // just to make sure we have a decent, single name
        return [words objectAtIndex:0];
    }
    return self.name;
}
@end
