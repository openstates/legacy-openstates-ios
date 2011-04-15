//
//  CommitteePositionObj.h
//  TexLege
//
//  Created by Gregory Combs on 1/22/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@class CommitteeObj;
@class LegislatorObj;

@interface CommitteePositionObj :  RKManagedObject  
{
}

@property (nonatomic, retain) NSString * updated;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * legislatorID;
@property (nonatomic, retain) NSNumber * committeePositionID;
@property (nonatomic, retain) NSNumber * committeeId;
@property (nonatomic, retain) CommitteeObj * committee;
@property (nonatomic, retain) LegislatorObj * legislator;

@end



