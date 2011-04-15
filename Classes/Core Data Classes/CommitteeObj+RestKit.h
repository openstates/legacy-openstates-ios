//
//  CommitteeObj.h
//  TexLege
//
//  Created by Gregory Combs on 7/11/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "CommitteeObj.h"
@class LegislatorObj;

@interface CommitteeObj (RestKit)
{
}
- (NSString *) typeString;
- (NSString *) description;
- (LegislatorObj *) chair;
- (LegislatorObj *) vicechair;
- (NSArray *) sortedMembers;

@end


