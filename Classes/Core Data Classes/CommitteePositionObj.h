//
//  CommitteePositionObj.h
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import <CoreData/CoreData.h>

@class LegislatorObj, CommitteeObj;

@interface CommitteePositionObj :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) LegislatorObj * legislator;
@property (nonatomic, retain) NSNumber * legislatorID;
@property (nonatomic, retain) CommitteeObj * committee;

- (NSString *) positionString;
- (NSComparisonResult)comparePositionAndCommittee:(CommitteePositionObj *)p;

@end



