//
//  CommitteeObj.h
//  TexLege
//
//  Created by Gregory Combs on 7/11/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "TexLegeDataObjectProtocol.h"

@class CommitteePositionObj, LegislatorObj;

@interface CommitteeObj :  NSManagedObject  <TexLegeDataObjectProtocol>
{
}

@property (nonatomic, retain) NSNumber * parentId;
@property (nonatomic, retain) NSNumber * committeeId;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * committeeName;
@property (nonatomic, retain) NSNumber * committeeType;
@property (nonatomic, retain) NSString * committeeNameInitial;
@property (nonatomic, retain) NSSet * committeePositions;
@property (nonatomic, retain) NSString * clerk;
@property (nonatomic, retain) NSString * clerk_email;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * office;

- (NSString *) typeString;
- (NSString *) description;
- (LegislatorObj *) chair;
- (LegislatorObj *) vicechair;
- (NSArray *) sortedMembers;


@end


@interface CommitteeObj (CoreDataGeneratedAccessors)
- (void)addCommitteePositionsObject:(CommitteePositionObj *)value;
- (void)removeCommitteePositionsObject:(CommitteePositionObj *)value;
- (void)addCommitteePositions:(NSSet *)value;
- (void)removeCommitteePositions:(NSSet *)value;

@end

