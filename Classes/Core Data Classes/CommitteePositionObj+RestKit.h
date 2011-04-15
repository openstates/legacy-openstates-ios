//
//  CommitteePositionObj.h
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "CommitteePositionObj.h"

@interface CommitteePositionObj (RestKit)
{
}

- (NSString *) positionString;
- (NSComparisonResult) comparePositionAndCommittee:(CommitteePositionObj *)p;

@end



