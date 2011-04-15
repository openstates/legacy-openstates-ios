//
//  CommitteeObj.h
//  TexLege
//
//  Created by Gregory Combs on 1/22/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@class CommitteePositionObj;

@interface CommitteeObj :  RKManagedObject  
{
}

@property (nonatomic, retain) NSString * clerk_email;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * committeeType;
@property (nonatomic, retain) NSString * updated;
@property (nonatomic, retain) NSNumber * committeeId;
@property (nonatomic, retain) NSNumber * votesmartID;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * office;
@property (nonatomic, retain) NSString * clerk;
@property (nonatomic, retain) NSString * committeeName;
@property (nonatomic, retain) NSString * openstatesID;
@property (nonatomic, retain) NSString * txlonline_id;
@property (nonatomic, retain) NSString * committeeNameInitial;
@property (nonatomic, retain) NSNumber * parentId;
@property (nonatomic, retain) NSSet* committeePositions;

@end


@interface CommitteeObj (CoreDataGeneratedAccessors)
- (void)addCommitteePositionsObject:(CommitteePositionObj *)value;
- (void)removeCommitteePositionsObject:(CommitteePositionObj *)value;
- (void)addCommitteePositions:(NSSet *)value;
- (void)removeCommitteePositions:(NSSet *)value;

@end

