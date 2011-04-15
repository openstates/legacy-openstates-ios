//
//  LegislatorObj.h
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "LegislatorObj.h"

@interface LegislatorObj (RestKit)
{
}

@property (nonatomic, readonly) NSString * districtMapURL;
@property (nonatomic, readonly) WnomObj *latestWnomScore;
@property (nonatomic, readonly) CGFloat latestWnomFloat;

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

