//
//  CommitteePositionObj.h
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@class LegislatorObj, CommitteeObj;

@interface CommitteePositionObj :  RKManagedObject
{
	NSNumber* committeePositionID;
	NSNumber * position;
	NSNumber * legislatorID;
	NSNumber * committeeId;
	NSString * updated;	
	LegislatorObj * legislator;
	CommitteeObj * committee;
}

@property (nonatomic, retain) NSNumber* committeePositionID;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) LegislatorObj * legislator;
@property (nonatomic, retain) NSNumber * legislatorID;
@property (nonatomic, retain) NSNumber * committeeId;
@property (nonatomic, retain) CommitteeObj * committee;
@property (nonatomic, retain) NSString * updated;

- (NSString *) positionString;
- (NSComparisonResult)comparePositionAndCommittee:(CommitteePositionObj *)p;

@end



