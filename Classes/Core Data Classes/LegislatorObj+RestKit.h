//
//  LegislatorObj.h
//  Created by Gregory Combs on 7/10/09.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LegislatorObj.h"

@interface LegislatorObj (RestKit)
{
}

@property (nonatomic, readonly) NSString * districtMapURL;

- (NSComparisonResult)compareMembersByName:(LegislatorObj *)p;
- (NSString *) partyShortName;
- (NSString *) legTypeShortName;
- (NSString *)  chamberName;
- (NSString *) legProperName;
- (NSString *) districtPartyString;
- (NSString *) fullName;
- (NSString *) fullNameLastFirst;
- (NSString *) website;
- (NSString *) shortNameForButtons;
- (NSString *) labelSubText;
- (NSInteger) numberOfDistrictOffices;
- (NSInteger) numberOfStaffers;
- (NSString *) tenureString;
- (NSArray *) sortedCommitteePositions;
- (NSArray *) sortedStaffers;
@end

